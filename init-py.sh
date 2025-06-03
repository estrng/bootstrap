#!/usr/bin/env bash

set -e

# === CONFIGURATION ===
CLI_VERSION="v1.0.2"
REPO="estrng/estrng-py"
BINARY_NAME="epy"
INSTALL_PATH="/usr/local/bin/$BINARY_NAME"

# === CHECK FOR GH_PAT ===
if [[ -z "$GH_PAT" ]]; then
  echo "❌ GH_PAT environment variable is not set."
  echo "💡 Please run: export GH_PAT=your_personal_access_token"
  exit 1
fi

# === CHECK jq DEPENDENCY ===
if ! command -v jq >/dev/null 2>&1; then
  echo "❌ 'jq' is required but not installed."
  echo "➡️  Please install jq and rerun this script."
  echo "    For Debian/Ubuntu: sudo apt-get install jq"
  echo "    For macOS (Homebrew): brew install jq"
  exit 1
fi

# === GET ASSET ID USING GITHUB API ===
echo "🔍 Fetching asset ID from GitHub API..."
ASSET_ID=$(curl -s -H "Authorization: token $GH_PAT" \
  https://api.github.com/repos/$REPO/releases/tags/$CLI_VERSION |
  jq -r ".assets[] | select(.name == \"$BINARY_NAME\") | .id")

if [[ -z "$ASSET_ID" || "$ASSET_ID" == "null" ]]; then
  echo "❌ Asset '$BINARY_NAME' not found in release $CLI_VERSION"
  exit 1
fi

# === DOWNLOAD BINARY USING ASSET_ID ===
TMP_FILE=$(mktemp)
echo "📦 Downloading $BINARY_NAME (asset ID: $ASSET_ID)..."

curl -L -H "Authorization: token $GH_PAT" \
  -H "Accept: application/octet-stream" \
  "https://api.github.com/repos/$REPO/releases/assets/$ASSET_ID" \
  -o "$TMP_FILE"

# === VERIFY BINARY ===
if file "$TMP_FILE" | grep -q "ELF"; then
  echo "✅ Verified: ELF binary"
else
  echo "❌ Invalid binary:"
  file "$TMP_FILE"
  echo "🔎 First few lines of file content:"
  head -20 "$TMP_FILE"
  rm "$TMP_FILE"
  exit 1
fi

# === INSTALL BINARY ===
echo "📁 Moving binary to $INSTALL_PATH..."
sudo mv "$TMP_FILE" "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

# === TEST INSTALLATION ===
echo "🧪 Testing CLI..."
if command -v "$BINARY_NAME" >/dev/null 2>&1; then
  "$BINARY_NAME" --help || echo "⚠️ CLI installed, but help command failed"
else
  echo "⚠️ CLI installed, but not found in PATH"
fi

# === DONE ===
echo "🚀 Done! You can now use the '$BINARY_NAME' command globally."
