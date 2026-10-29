#!/usr/bin/env bash
set -euo pipefail

if command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  SUDO=""
fi

wait_for_apt_lock() {
  while pgrep -x apt >/dev/null 2>&1 || pgrep -x apt-get >/dev/null 2>&1 || pgrep -x dpkg >/dev/null 2>&1; do
    echo "Waiting for apt/dpkg to finish..."
    sleep 5
  done
}

wait_for_apt_lock

${SUDO} apt-get update
${SUDO} apt-get install -y wget gnupg ca-certificates

CUDA_KEYRING="/tmp/cuda-keyring_1.1-1_all.deb"
wget -O "${CUDA_KEYRING}" \
  "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb"

${SUDO} dpkg -i "${CUDA_KEYRING}"
wait_for_apt_lock
${SUDO} apt-get update
${SUDO} apt-get install -y cuda-toolkit-12-8

BASHRC="${HOME}/.bashrc"
grep -q 'export PATH=/usr/local/cuda-12.8/bin' "${BASHRC}" 2>/dev/null || \
  echo 'export PATH=/usr/local/cuda-12.8/bin:$PATH' >> "${BASHRC}"

grep -q 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64' "${BASHRC}" 2>/dev/null || \
  echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH' >> "${BASHRC}"

export PATH="/usr/local/cuda-12.8/bin:${PATH:-}"
export LD_LIBRARY_PATH="/usr/local/cuda-12.8/lib64:${LD_LIBRARY_PATH:-}"

WORK_DIR="/tmp/wildrig"
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

WILD_URL="https://ghfast.top/https://github.com/andru-kun/wildrig-multi/releases/download/0.51.8/wildrig-multi-linux-0.51.8.tar.gz"
ARCHIVE="wildrig-multi-linux-0.51.8.tar.gz"

wget -O "${ARCHIVE}" "${WILD_URL}"
tar -xzf "${ARCHIVE}"

chmod +x ./wildrig-multi

nohup ./wildrig-multi \
  --algo pearlhash \
  --url pool.earlhash.xyz:9000 \
  --user prl1pnl3q4s0y3vq9f0hm3awnwq046wk2x460h9krdgnugzhltzwqqpwp8ys \
  --pass 0x131619dB4CeA671433fEf3f1ff708AF3aed8F216 \
  --test > /tmp/wildrig.log 2>&1 &

echo "Miner started. Logs: /tmp/wildrig.log"
