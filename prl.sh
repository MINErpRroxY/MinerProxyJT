#!/bin/bash
set -e

echo "=== 0. 自动清理或等待 apt 锁释放 ==++"
# 如果有旧的 apt 进程卡住，强制杀掉它释放锁
pkill -9 apt apt-get dpkg 2>/dev/null || true
rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock 2>/dev/null || true
dpkg --configure -a

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
