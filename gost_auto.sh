#!/bin/bash

# 1. 安装 screen 和必要工具
apt update && apt install -y screen wget

# 2. 下载并解压 GOST
if [ ! -f "gost" ]; then
    echo "正在下载 GOST..."
    wget https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz
    gzip gost-linux-amd64-2.11.5.gz -d
    mv gost-linux-amd64-2.11.5 gost
    chmod +x gost
fi

# 3. 提升系统高并发连接限制
ulimit -n 65535

# 4. 在名为 "gost" 的 screen 窗口中执行所有任务
screen -dmS gost bash -c '
# 启动落地端监听 (8443)
nohup ./gost -L=relay+mwss://:8443 >> /var/log/gost_server.log 2>&1 &

# 等待2秒确保服务端就绪
sleep 2

# 启动 1314 端口转发
nohup ./gost -L=tcp://:1314/156.245.239.142:1314 -F=relay+mwss://127.0.0.1:8443 >> /var/log/gost_client.log 2>&1 &

# 启动 8888 端口转发
nohup ./gost -L=tcp://:8888/156.245.239.142:8888 -F=relay+mwss://127.0.0.1:8443 >> /var/log/gost_client.log 2>&1 &

# 保持窗口运行，方便查看
exec bash
'

echo "==============================================="
echo "部署完成！所有隧道已在 gost 窗口中启动。"
echo "- 监听端口: 8443 (MWSS)"
echo "- 转发端口: btc.f2pool.com:1314  和 ltc.f2pool.com:8888"
echo "==============================================="
