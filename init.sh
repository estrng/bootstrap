#!/usr/bin/env bash
set -e

CLI_VERSION="v1.0.5"
REPO="estrng/estrngcli"
BINARY_NAME="estrng"
TMP_FILE="./$BINARY_NAME.tmp"
INSTALL_PATH="/usr/local/bin/$BINARY_NAME"

echo "📦 Downloading Estrng CLI $CLI_VERSION for Linux/macOS..."
curl -L "https://github.com/$REPO/releases/download/$CLI_VERSION/$BINARY_NAME" -o "$TMP_FILE"
chmod +x "$TMP_FILE"

echo "📁 Moving binary to $INSTALL_PATH..."
sudo mv "$TMP_FILE" "$INSTALL_PATH"

echo "✅ Estrng CLI installed to $INSTALL_PATH"
echo "🧪 Testing..."
$BINARY_NAME || echo "⚠️ CLI was installed, but not detected in PATH"

echo "✅ Done! You can now run 'estrng' from anywhere."
echo "For more information, visit: https://github.com/$REPO"