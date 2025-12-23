#!/system/bin/sh
cd ${0%/*} # current working directory
URL="https://core.acstudycn.eu.org/xray/download/android"

TMP="$(mktemp xrayXXXXXX 2>/dev/null || echo /tmp/xray$$)"
mv "$TMP" "${TMP}.zip"
TMP="${TMP}.zip"

DEST="$(dirname "$(pwd)")/binary"

curl -L -o "$TMP" "$URL" || wget -O "$TMP" "$URL"
mkdir -p "$DEST"
unzip -o "$TMP" -d "$DEST"
rm -f "$TMP" "$DEST/LICENSE" "$DEST/README.md"
# Last edited: 2025.12.23