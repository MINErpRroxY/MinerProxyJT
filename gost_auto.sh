#!/bin/bash

# 1. 安装 screen 和必要工具
apt update && apt install -y screen wget

# 2. 下载并解压 GOST
if [ ! -f "gost" ]; then
    wget https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz
    gzip gost-linux-amd64-2.11.5.gz -d
    mv gost-linux-amd64-2.11.5 gost
    chmod +x gost
fi

# 3. 提升系统高并发连接限制 (可选，建议加上)
ulimit -n 65535

# 4. 在 screen 窗口中执行核心任务
# -dmS 会创建一个处于断开模式的后台窗口，窗口名为 gost
screen -dmS gost bash -c '
# 启动落地端监听 (8443)
nohup ./gost -L=relay+mwss://:8443 >> /var/log/gost_server.log 2>&1 &

# 等待2秒确保服务端启动
sleep 2

# 启动中转转发 (1314)
nohup ./gost -L=tcp://:1314/156.245.239.142:1314 -F=relay+mwss://127.0.0.1:8443 >> /var/log/gost_client.log 2>&1 &

# 保持 screen 窗口不退出，方便后续进入查看
exec bash
'

echo "==============================================="
echo "部署完成！gost screen 窗口后台运行。"
echo "==============================================="
