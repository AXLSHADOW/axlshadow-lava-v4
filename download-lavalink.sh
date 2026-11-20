#!/usr/bin/env bash
# ==============================================================================
# Lavalink Downloader & Pre-flight Verification (Linux/macOS)
# Downloads official release from https://github.com/lavalink-devs/Lavalink
# ==============================================================================

set -euo pipefail

echo "=== Lavalink Downloader & Pre-flight Verification ==="

# 1. Verify Java
echo -e "\n[1/3] Checking Java Runtime..."
if ! command -v java &> /dev/null; then
    echo "WARNING: Java is not installed or not in PATH."
    echo "Lavalink v4 requires Java 17 or newer (Java 21 recommended)."
    echo "Install via package manager or Adoptium: https://adoptium.net/"
else
    java -version
fi

# 2. Determine Download URL
echo -e "\n[2/3] Resolving official release binary..."
TARGET_VERSION="${1:-latest}"
REPO="lavalink-devs/Lavalink"

if [ "$TARGET_VERSION" = "latest" ]; then
    DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/Lavalink.jar"
else
    DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${TARGET_VERSION}/Lavalink.jar"
fi

OUTPUT_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/Lavalink.jar"

# 3. Download Binary
echo -e "\n[3/3] Downloading Lavalink.jar from GitHub..."
echo "Source: ${DOWNLOAD_URL}"
echo "Destination: ${OUTPUT_FILE}"

curl -fSL "${DOWNLOAD_URL}" -o "${OUTPUT_FILE}"

echo -e "\nSUCCESS: Lavalink.jar downloaded successfully."
echo "Run locally using: java -jar Lavalink.jar"
