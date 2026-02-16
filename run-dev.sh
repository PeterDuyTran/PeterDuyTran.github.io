#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SITE_DIR="$SCRIPT_DIR/site"

echo "=== Portfolio Dev Server ==="
echo ""

# Clean stale public dir
if [[ -d "$SITE_DIR/public" ]]; then
  chmod -R u+w "$SITE_DIR/public" 2>/dev/null
  rm -rf "$SITE_DIR/public"
fi

echo "  Starting Hugo server..."
echo "  → http://localhost:1313"
echo ""
echo "  Press Ctrl+C to stop."
echo ""

hugo server -D --navigateToChanged -s "$SITE_DIR" -p 1313
