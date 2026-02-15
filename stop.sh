#!/usr/bin/env bash
# Kill any lingering Hugo server processes

echo "Looking for Hugo server processes..."
HUGO_PIDS=$(pgrep -f "hugo server" 2>/dev/null || true)
if [[ -n "$HUGO_PIDS" ]]; then
  echo "Killing Hugo servers: $HUGO_PIDS"
  echo "$HUGO_PIDS" | xargs kill 2>/dev/null || true
else
  echo "No Hugo server processes found."
fi

echo "Done."
