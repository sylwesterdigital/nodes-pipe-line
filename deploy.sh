#!/usr/bin/env bash
set -euo pipefail

# --- config ---
USER="root"                 # change this
HOST="studio333.art"           # or server IP/hostname
PORT=333
REMOTE_DIR="/var/www/dots"

# --- deploy index.html using rsync over SSH port 333 ---
rsync -avz \
  -e "ssh -p ${PORT}" \
  ./index.html \
  "${USER}@${HOST}:${REMOTE_DIR}/index.html"

echo "Deployed index.html to ${HOST}:${REMOTE_DIR}/"
