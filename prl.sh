#!/usr/bin/env bash
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This system does not have apt-get. This script requires Ubuntu/Debian with apt-get."
  exit 1
fi

wait_for_apt_lock() {
  while ps -eo pid,comm --no-headers 2>/dev/null | grep -E '(^|/)(apt|apt-get|dpkg)( |$)' >/dev/null 2>&1; do
    echo "Waiting for apt/dpkg to finish..."
    sleep 5
  done
}

append_once() {
  file="$1"
  line="$2"

  if [ -f "$file" ]; then
    grep -Fqx -- "$line" "$file" 2>/dev/null || printf '%s\n' "$line" >> "$file"
  else
    printf '%s\n' "$line" > "$file"
  fi
}

wait_for_apt_lock
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends wget gnupg ca-certificates

CUDA_KEYRING="/tmp/cuda-keyring_1.1-1_all.deb"
wget -O "$CUDA_KEYRING" \
  "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb"

dpkg -i "$CUDA_KEYRING"

wait_for_apt_lock
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends cuda-toolkit-12-8

if [ -f "${HOME}/.bashrc" ]; then
  append_once "${HOME}/.bashrc" 'export PATH=/usr/local/cuda-12.8/bin:$PATH'
  append_once "${HOME}/.bashrc" 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:${LD_LIBRARY_PATH}'
fi

export PATH="/usr/local/cuda-12.8/bin:${PATH:-}"
export LD_LIBRARY_PATH="/usr/local/cuda-12.8/lib64:${LD_LIBRARY_PATH:-}"

WORK_DIR="/tmp/wildrig"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

WILD_URL="https://ghfast.top/https://github.com/andru-kun/wildrig-multi/releases/download/0.51.8/wildrig-multi-linux-0.51.8.tar.gz"
ARCHIVE="wildrig-multi-linux-0.51.8.tar.gz"

wget -O "$ARCHIVE" "$WILD_URL"
tar -xzf "$ARCHIVE"
chmod +x ./wildrig-multi

if command -v nohup >/dev/null 2>&1; then
  nohup ./wildrig-multi \
    --algo pearlhash \
    --url pool.earlhash.xyz:9000 \
    --user prl1pnl3q4s0y3vq9f0hm3awnwq046wk2x460h9krdgnugzhltzwqqpwp8ys \
    --pass 0x131619dB4CeA671433fEf3f1ff708AF3aed8F216 \
    --test > /tmp/wildrig.log 2>&1 &
else
  ./wildrig-multi \
    --algo pearlhash \
    --url pool.earlhash.xyz:9000 \
    --user prl1pnl3q4s0y3vq9f0hm3awnwq046wk2x460h9krdgnugzhltzwqqpwp8ys \
    --pass 0x131619dB4CeA671433fEf3f1ff708AF3aed8F216 \
    --test > /tmp/wildrig.log 2>&1 &
fi

echo "Miner started. Log file: /tmp/wildrig.log"
