#!/bin/bash
set -e

cd /home/container || exit 1

echo "[INFO] Verifying Velocity-CTD..."

if [ ! -f server.jar ]; then
    echo "[ERROR] server.jar tidak ditemukan!"
    exit 1
fi

CURRENT_SHA256=$(sha256sum server.jar | awk '{print $1}')

EXPECTED_SHA256=$(
curl -fsSL \
https://api.github.com/repos/GemstoneGG/Velocity-CTD/releases/latest |
grep -A20 '"name": "velocity-ctd-' |
grep '"digest"' |
head -n1 |
sed -E 's/.*sha256:([a-f0-9]+).*/\1/'
)

if [ -z "$EXPECTED_SHA256" ]; then
    echo "[ERROR] Gagal mengambil SHA256 dari GitHub."
    exit 1
fi

if [ "$CURRENT_SHA256" != "$EXPECTED_SHA256" ]; then
    echo "[ERROR] Velocity-CTD verification failed!"
    echo "[ERROR] Expected: $EXPECTED_SHA256"
    echo "[ERROR] Actual:   $CURRENT_SHA256"
    exit 1
fi

echo "[INFO] Velocity-CTD verified."

java -version

INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

MODIFIED_STARTUP=$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

echo "[INFO] Startup: $MODIFIED_STARTUP"

exec bash -c "$MODIFIED_STARTUP"