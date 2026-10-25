#!/usr/bin/env bash
###############################################################################
# Stop Project Zomboid Server + Playit.gg
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "=================================================="
echo "Stopping ${SERVER_NAME:-Project Zomboid Server}"
echo "=================================================="

# Stop Project Zomboid server
if pgrep -f "$PZ_PROCESS_PATTERN" > /dev/null; then
    echo "Stopping Project Zomboid server..."
    if stop_pz_server; then
        echo "✓ Project Zomboid server stopped"
    else
        echo "✗ Server is still running (may need force kill)"
    fi
else
    echo "ℹ Project Zomboid server is not running"
fi

# Stop Playit.gg (only if it's running)
if pgrep -x "playit" > /dev/null; then
    echo "Stopping Playit.gg tunnel..."
    pkill playit
    sleep 1
    echo "✓ Playit.gg stopped"
fi

echo ""
echo "=================================================="
echo "All services stopped"
echo "=================================================="
