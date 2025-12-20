#!/usr/bin/env bash
###############################################################################
# Stop Project Zomboid Server Only (Leave Playit.gg Running)
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "=================================================="
echo "Stopping ${SERVER_NAME:-Project Zomboid Server}"
echo "=================================================="

# Stop Project Zomboid server
if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
    echo "Stopping Project Zomboid server..."
    pkill -f "ProjectZomboid64.*pzserver"
    sleep 3

    if ! pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
        echo "✓ Project Zomboid server stopped"
    else
        echo "✗ Failed to stop server (may need force kill)"
    fi
else
    echo "ℹ Project Zomboid server is not running"
fi

# Check Playit.gg status (but don't stop it)
echo ""
if pgrep -x "playit" > /dev/null; then
    echo "ℹ Playit.gg tunnel is still running"
    echo "  Use option [6] → [2] to stop the tunnel if needed"
else
    echo "ℹ Playit.gg tunnel is not running"
fi

echo ""
echo "=================================================="
echo "Server stopped (Playit.gg unchanged)"
echo "=================================================="
