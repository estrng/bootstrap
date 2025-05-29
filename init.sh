#!/usr/bin/env bash
set -e

CLI_VERSION="v1.0.5"
REPO="estrng/estrngcli"
BINARY_NAME="estrng"
INSTALL_PATH="/usr/local/bin/$BINARY_NAME"

echo "📦 Downloading Estrng CLI $CLI_VERSION for Linux/macOS..."
sudo curl -L "https://github.com/$REPO/releases/download/$CLI_VERSION/$BINARY_NAME" -o "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

echo "✅ Estrng CLI installed to $INSTALL_PATH"
echo "🧪 Testing..."
$BINARY_NAME || echo "⚠️ CLI was installed, but not detected in PATH"

echo "✅ Done! You can now run 'estrng' from anywhere."
echo "For more information, visit: https://github.com/$REPO"