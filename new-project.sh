#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: ./new-project.sh project-name"
  echo "Example: ./new-project.sh my-new-game"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SITE_DIR="$SCRIPT_DIR/site"

mkdir -p "$SITE_DIR/content/projects/$1"
hugo new "projects/$1/index.md" -s "$SITE_DIR"

echo ""
echo "Created: site/content/projects/$1/index.md"
echo "Add images to site/content/projects/$1/ as page resources."
