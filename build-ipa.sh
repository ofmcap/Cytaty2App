#!/bin/bash

# === KONFIGURACJA ===
APP_NAME="Cytaty2App"               # <- ZMIEŃ to na nazwę aplikacji z Xcode
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
EXPORT_PATH="$HOME/Desktop/$APP_NAME.ipa"

# === ZNAJDŹ ŚCIEŻKĘ DO .app ===
APP_PATH=$(find "$DERIVED_DATA_PATH" -type d -path "*/Build/Products/Debug-iphoneos/$APP_NAME.app" | head -n 1)

if [ -z "$APP_PATH" ]; then
  echo "❌ Nie znaleziono pliku .app dla $APP_NAME."
  exit 1
fi

echo "✅ Znaleziono aplikację: $APP_PATH"

# === STWÓRZ KATALOG IPA ===
WORK_DIR=$(mktemp -d)
PAYLOAD_DIR="$WORK_DIR/Payload"

mkdir -p "$PAYLOAD_DIR"
cp -R "$APP_PATH" "$PAYLOAD_DIR/"

# === SPACKUJ DO IPA ===
cd "$WORK_DIR" || exit
zip -r "$EXPORT_PATH" Payload > /dev/null

echo "📦 Plik IPA zapisany na biurku: $EXPORT_PATH"

# === POSPRZĄTAJ ===
rm -rf "$WORK_DIR"

