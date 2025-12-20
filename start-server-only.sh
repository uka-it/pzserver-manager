#!/usr/bin/env bash
###############################################################################
# Start Project Zomboid Server Only (No Playit.gg)
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

cd "${SCRIPT_DIR}"

echo "=================================================="
echo "Starting ${SERVER_NAME:-Project Zomboid Server}"
echo "=================================================="

# Check if PZ server is already running
if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
    echo "⚠ Project Zomboid server is already running!"
    echo "If you want to restart it, run: ./stop-all.sh first"
    exit 1
fi

# Detect current branch
MANIFEST="${INSTALL_DIR}/steamapps/appmanifest_380870.acf"
if [ -f "$MANIFEST" ]; then
    CURRENT_BRANCH=$(grep "BetaKey" "$MANIFEST" | head -1 | sed 's/.*"BetaKey".*"\([^"]*\)".*/\1/')
    if [ -z "$CURRENT_BRANCH" ] || [ "$CURRENT_BRANCH" = "BetaKey" ]; then
        BRANCH_DISPLAY="STABLE (Build 41)"
    elif [ "$CURRENT_BRANCH" = "42.13.1" ]; then
        BRANCH_DISPLAY="Build 42.13.1"
    elif [ "$CURRENT_BRANCH" = "unstable" ]; then
        BRANCH_DISPLAY="UNSTABLE (Build 42)"
    else
        BRANCH_DISPLAY="$CURRENT_BRANCH"
    fi
else
    BRANCH_DISPLAY="Unknown"
fi

echo "=================================================="
echo "Starting Project Zomboid Server..."
echo "Server Name: ${SERVER_NAME:-My PZ Server}"
echo "Branch: $BRANCH_DISPLAY"
echo "Memory: 8GB"
echo "Mode: Direct Connection (No Playit.gg)"
echo "=================================================="
echo ""
echo "Players can connect via:"
if [ -n "$PUBLIC_DOMAIN" ]; then
    echo "  Domain: $PUBLIC_DOMAIN:$DEFAULT_PORT"
fi
if [ -n "$PUBLIC_IPV6" ]; then
    echo "  IPv6: [$PUBLIC_IPV6]:$DEFAULT_PORT"
fi
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "  Local: ${LOCAL_IP:-127.0.0.1}:$DEFAULT_PORT"
echo ""
echo "=================================================="
echo "Server is starting in background..."
echo "=================================================="
echo ""

# Start the PZ server in background
nohup ./start-pzserver.sh > server.log 2>&1 &
SERVER_PID=$!

# Wait a moment and check if it started
sleep 3

if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
    echo "✓ Server started successfully (PID: $(pgrep -f 'ProjectZomboid64.*pzserver'))"
    echo ""
    echo "Server logs: $SCRIPT_DIR/server.log"
    echo ""
    echo "To view live logs:"
    echo "  tail -f server.log"
    echo ""
    echo "To stop the server:"
    echo "  ./stop-all.sh"
else
    echo "✗ Server may have failed to start"
    echo "Check logs: tail -50 server.log"
    exit 1
fi
