#!/bin/bash

# 设置遇到错误时中断（可选，如需严格执行可解开下一行注释）
# set -e

echo "=== 1. 更新系统软件包并安装依赖 ==="
apt update && apt install -y wget gnupg

echo "=== 2. 配置 CUDA 12.8 存储库并安装 Toolkit ==="
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
apt update
apt install -y cuda-toolkit-12-8

echo "=== 3. 配置环境变量 ==="
# 写入 ~/.bashrc 持久化
echo 'export PATH=/usr/local/cuda-12.8/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc

# 立即在当前脚本进程中生效
export PATH=/usr/local/cuda-12.8/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH

echo "=== 4. 下载并解压 Wildrig-Multi ==="
wget https://ghfast.top/https://github.com/andru-kun/wildrig-multi/releases/download/0.51.8/wildrig-multi-linux-0.51.8.tar.gz -O wildrig-multi-linux-0.51.8.tar.gz
tar -zxvf wildrig-multi-linux-0.51.8.tar.gz

echo "=== 5. 后台启动 Wildrig-Multi ==="
nohup ./wildrig-multi --algo pearlhash --url pool.pearlhash.xyz:9000 --url hk.pearlhash.net:9000 --user prl1pnl34q7s0y33vq9f0hm3awnwq046w7k2x460h9krgunugzxltzwqqpwp8ys --1 test > wildrig.log 2>&1 &

echo "=== 全部脚本执行完毕！程序已在后台运行，日志输出至 wildrig.log ==="