#!/usr/bin/env bash
set -e

CLI_VERSION="v1.0.5"
REPO="estrng/estrngcli"
BINARY_NAME="estrng"
INSTALL_PATH="/usr/local/bin/$BINARY_NAME"

# Download using wget (try .tar.gz if plain binary fails)
echo "📦 Downloading Estrng CLI $CLI_VERSION for Linux/macOS..."

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Try downloading the binary directly
if wget -q "https://github.com/$REPO/releases/download/$CLI_VERSION/$BINARY_NAME"; then
    sudo mv "$BINARY_NAME" "$INSTALL_PATH"
    sudo chmod +x "$INSTALL_PATH"
else
    # Try downloading a tar.gz archive if direct binary fails
    if wget -q "https://github.com/$REPO/releases/download/$CLI_VERSION/${BINARY_NAME}.tar.gz"; then
        tar -xzf "${BINARY_NAME}.tar.gz"
        sudo mv "$BINARY_NAME" "$INSTALL_PATH"
        sudo chmod +x "$INSTALL_PATH"
    else
        echo "❌ Download failed. Please check the release URL or your network connection."
        exit 1
    fi
fi

cd -
rm -rf "$TMP_DIR"

echo "✅ Estrng CLI installed to $INSTALL_PATH"
echo "🧪 Testing..."
$BINARY_NAME || echo "⚠️ CLI was installed, but not detected in PATH"

echo "✅ Done! You can now run 'estrng' from anywhere."
echo "For more information, visit: https://github.com/$REPO"