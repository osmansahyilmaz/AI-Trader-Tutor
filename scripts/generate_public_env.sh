#!/usr/bin/env bash
set -euo pipefail

# Master file (contains PUBLIC + SERVER)
SRC=".env"

# Generated file (PUBLIC only) — safe to pass to Flutter
OUT=".env.public"

# Whitelist of vars allowed in Flutter
ALLOWED_REGEX='^(SUPABASE_URL|SUPABASE_ANON_KEY|APP_ENV|DEFAULT_ASSET_CLASS|DEFAULT_TIMEFRAME)='

if [ ! -f "$SRC" ]; then
    echo "Error: $SRC not found. Please create it from .env.example"
    exit 1
fi

grep -E "${ALLOWED_REGEX}" "$SRC" > "$OUT"

echo "Generated $OUT from $SRC"
