#!/bin/bash
set -e

REPO_URL="https://github.com/sadrazkh/CloakTraffic.git"
INSTALL_DIR="$HOME/CloakTraffic"

echo "🚀 Cloning repo..."
if [ -d "$INSTALL_DIR" ]; then
    cd "$INSTALL_DIR"
    git pull
else
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

echo "🛠️ Running setup script..."
chmod +x "$INSTALL_DIR/install.sh"
sudo "$INSTALL_DIR/install.sh"
