#!/bin/bash
set -e

echo "=== 0. 等待系统后台 apt 进程释放锁 ==="
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "系统正在进行后台更新，等待 5 秒..."
    sleep 5
done

echo "=== 1. 安装基础依赖与 OpenCL 运行库 ==="
apt update
apt install -y wget gnupg ocl-icd-libopencl1

echo "=== 2. 配置 CUDA 环境变量 ==="
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc

echo "=== 3. 下载并解压 Wildrig-Multi ==="
wget https://ghfast.top/https://github.com/andru-kun/wildrig-multi/releases/download/0.51.8/wildrig-multi-linux-0.51.8.tar.gz -O wildrig-multi-linux-0.51.8.tar.gz
tar -zxvf wildrig-multi-linux-0.51.8.tar.gz

echo "=== 4. 后台启动 Wildrig-Multi ==="
nohup ./wildrig-multi --algo pearlhash --url pool.pearlhash.xyz:9000 --url hk.pearlhash.net:9000 --user prl1pnl34q7s0y33vq9f0hm3awnwq046w7k2x460h9krgunugzxltzwqqpwp8ys@nock=0x131619dB4Cea671433fEf3f1ff708AF3aed8F216 --1 test > wildrig.log 2>&1 &

echo "=== 脚本执行完毕，程序已在后台运行 ==="