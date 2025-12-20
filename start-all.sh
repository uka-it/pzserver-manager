#!/usr/bin/env bash
###############################################################################
# Combined Project Zomboid Server + Playit.gg Startup Script
###############################################################################

SCRIPT_DIR="/home/liviouka/pzserver"
cd "${SCRIPT_DIR}"

echo "=================================================="
echo "Starting ShadowZombie Server + Playit.gg Tunnel"
echo "=================================================="

# Check if Playit is already running
if pgrep -x "playit" > /dev/null; then
    echo "✓ Playit.gg is already running"
else
    echo "Starting Playit.gg tunnel agent..."
    nohup playit start > playit.log 2>&1 &
    sleep 2
    if pgrep -x "playit" > /dev/null; then
        echo "✓ Playit.gg started successfully"
    else
        echo "✗ Failed to start Playit.gg"
        exit 1
    fi
fi

# Show tunnel information
echo ""
echo "Playit.gg Tunnels:"
playit tunnels list | grep "=>" | head -4
echo ""

# Check if PZ server is already running
if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
    echo "⚠ Project Zomboid server is already running!"
    echo "If you want to restart it, run: ./stop-all.sh first"
    exit 1
fi

# Detect current branch
MANIFEST="${SCRIPT_DIR}/steamapps/appmanifest_380870.acf"
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
echo "Server Name: ShadowZombie Server"
echo "Branch: $BRANCH_DISPLAY"
echo "Memory: 8GB"
echo "=================================================="
echo ""
echo "Players can connect via Playit.gg:"
echo "  glass-fascinating.gl.at.ply.gg:11128"
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
    echo "Playit logs: $SCRIPT_DIR/playit.log"
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
