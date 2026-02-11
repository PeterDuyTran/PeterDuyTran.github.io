#!/usr/bin/env bash
# Kill any lingering Hugo server and landing page processes from dev.sh

echo "Looking for Hugo server processes..."
HUGO_PIDS=$(pgrep -f "hugo server" 2>/dev/null || true)
if [[ -n "$HUGO_PIDS" ]]; then
  echo "Killing Hugo servers: $HUGO_PIDS"
  echo "$HUGO_PIDS" | xargs kill 2>/dev/null || true
else
  echo "No Hugo server processes found."
fi

echo "Looking for landing page server on port 8080..."
LAND_PIDS=$(lsof -ti :8080 2>/dev/null || true)
if [[ -n "$LAND_PIDS" ]]; then
  echo "Killing process on port 8080: $LAND_PIDS"
  echo "$LAND_PIDS" | xargs kill 2>/dev/null || true
else
  echo "No process found on port 8080."
fi

echo "Done."
