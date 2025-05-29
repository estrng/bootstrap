#!/usr/bin/env bash
set -e

# === CONFIGURAÇÕES ===
CLI_VERSION="v1.0.6"
REPO="estrng/estrngcli"
BINARY_NAME="estrng"
INSTALL_PATH="/usr/local/bin/$BINARY_NAME"

# === VALIDAÇÃO DE TOKEN ===
if [[ -z "$GH_PAT" ]]; then
  echo "❌ GH_PAT environment variable is not set."
  echo "🔐 Export it before running: export GH_PAT=your_token"
  exit 1
fi

# === OBTÉM ID DO ASSET USANDO GITHUB API ===
echo "🔍 Fetching asset ID from GitHub API..."
ASSET_ID=$(curl -s -H "Authorization: token $GH_PAT" \
  https://api.github.com/repos/$REPO/releases/tags/$CLI_VERSION |
  jq -r ".assets[] | select(.name == \"$BINARY_NAME\") | .id")

if [[ -z "$ASSET_ID" || "$ASSET_ID" == "null" ]]; then
  echo "❌ Asset '$BINARY_NAME' not found in release $CLI_VERSION"
  exit 1
fi

# === DOWNLOAD DO BINÁRIO USANDO ASSET_ID ===
TMP_FILE=$(mktemp)
echo "📦 Downloading $BINARY_NAME (asset ID: $ASSET_ID)..."

curl -L -H "Authorization: token $GH_PAT" \
  -H "Accept: application/octet-stream" \
  "https://api.github.com/repos/$REPO/releases/assets/$ASSET_ID" \
  -o "$TMP_FILE"

# === VALIDAR BINÁRIO ===
if file "$TMP_FILE" | grep -q "ELF"; then
  echo "🔐 Binary verified as ELF executable"
else
  echo "❌ Downloaded file is not a valid ELF binary:"
  file "$TMP_FILE"
  head -20 "$TMP_FILE"
  rm "$TMP_FILE"
  exit 1
fi

# === INSTALAÇÃO ===
echo "📁 Installing to $INSTALL_PATH..."
sudo mv "$TMP_FILE" "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

# === TESTE FINAL ===
echo "🧪 Testing installation..."
"$INSTALL_PATH" || echo "⚠️ CLI was installed, but not detected in PATH"

# === FINALIZAÇÃO ===
echo "✅ Done! Estrng CLI installed to $INSTALL_PATH"
echo "🚀 You can now run '$BINARY_NAME' from anywhere."
echo "🔗 More info: https://github.com/$REPO"
