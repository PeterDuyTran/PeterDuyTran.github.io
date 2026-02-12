#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Theme definitions: name|directory|port
THEMES=(
  "Toha|site|1313"
  "Typo|site-typo|1314"
  "PaperMod|site-papermod|1315"
  "Paper|site-paper|1316"
  "Risotto|site-risotto|1317"
  "Anatole|site-anatole|1318"
)

PIDS=()
LANDING_PID=""

cleanup() {
  echo ""
  echo "Stopping all servers..."
  for pid in "${PIDS[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
  if [[ -n "$LANDING_PID" ]]; then
    kill "$LANDING_PID" 2>/dev/null || true
  fi
  wait 2>/dev/null
  echo "All servers stopped."
}

trap cleanup SIGINT SIGTERM EXIT

echo "=== Portfolio Theme Switcher ==="
echo ""

# Start Hugo servers
for entry in "${THEMES[@]}"; do
  IFS='|' read -r name dir port <<< "$entry"
  site_path="$SCRIPT_DIR/$dir"
  if [[ ! -d "$site_path" ]]; then
    echo "  SKIP  $name — directory $dir/ not found"
    continue
  fi
  # Clean stale public dir (fixes read-only permission issues)
  if [[ -d "$site_path/public" ]]; then
    chmod -R u+w "$site_path/public" 2>/dev/null
    rm -rf "$site_path/public"
  fi
  hugo server -D --navigateToChanged -s "$site_path" -p "$port" &>/dev/null &
  PIDS+=($!)
  echo "  START  $name → http://localhost:$port  (pid $!)"
done

# Start landing page server
echo ""
cd "$SCRIPT_DIR"
python3 -m http.server 8080 --bind 127.0.0.1 &>/dev/null &
LANDING_PID=$!
echo "  LANDING PAGE → http://localhost:8080  (pid $LANDING_PID)"

echo ""
echo "Open http://localhost:8080 in your browser to switch themes."
echo "Press Ctrl+C to stop all servers."
echo ""

# Wait for all background processes
wait
