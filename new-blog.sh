#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: ./new-blog.sh post-title-here"
  echo "Example: ./new-blog.sh my-new-article"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SITE_DIR="$SCRIPT_DIR/site"

hugo new "blog/$1.md" -s "$SITE_DIR"

echo ""
echo "Created: site/content/blog/$1.md"
echo "Edit this file and remove 'draft: true' when ready to publish."
