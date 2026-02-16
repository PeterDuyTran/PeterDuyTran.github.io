#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SITE_DIR="$SCRIPT_DIR/site"

echo "=== Building Portfolio for Production ==="
echo ""

hugo --gc --minify -s "$SITE_DIR"

echo ""
echo "Build complete! Output is in: $SITE_DIR/public/"
