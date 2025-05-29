#!/usr/bin/env bash
set -e

CLI_VERSION="v1.0.5"
REPO="estrng/estrngcli"
BINARY_NAME="estrng"
FILE_NAME="$BINARY_NAME"
INSTALL_DIR="/usr/local/bin"

echo "📦 Downloading Estrng CLI $CLI_VERSION for Linux/macOS..."
curl -L "https://github.com/$REPO/releases/download/$CLI_VERSION/$FILE_NAME" -o "$FILE_NAME"

chmod +x "$FILE_NAME"

echo "📁 Moving binary to $INSTALL_DIR..."
sudo mv "$FILE_NAME" "$INSTALL_DIR/$BINARY_NAME"

echo "✅ Estrng CLI installed to $INSTALL_DIR/$BINARY_NAME"
echo "🧪 Testing..."
$BINARY_NAME --version || echo "⚠️ CLI was installed, but not detected in PATH"

echo "✅ Done! You can now run 'estrng' from anywhere."
