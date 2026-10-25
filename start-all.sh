#!/usr/bin/env bash
###############################################################################
# Combined Project Zomboid Server + Playit.gg Startup Script
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

cd "${SCRIPT_DIR}"

echo "=================================================="
echo "Starting ${SERVER_NAME:-Project Zomboid Server}"
echo "=================================================="

# Check if Playit.gg is installed and enabled
if command -v playit &> /dev/null && [ "${PLAYIT_ENABLED}" = "true" ]; then
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
            echo "✗ Failed to start Playit.gg (continuing anyway)"
        fi
    fi

    # Show tunnel information
    echo ""
    echo "Playit.gg Tunnels:"
    playit tunnels list 2>/dev/null | grep "=>" | head -4
    echo ""
else
    if [ "${PLAYIT_ENABLED}" != "true" ]; then
        echo "ℹ Playit.gg is disabled in configuration"
    else
        echo "ℹ Playit.gg is not installed (server will use direct connection)"
    fi
    echo ""
fi

# Check if PZ server is already running
if pgrep -f "$PZ_PROCESS_PATTERN" > /dev/null; then
    echo "⚠ Project Zomboid server is already running!"
    echo "If you want to restart it, run: ./stop-all.sh first"
    exit 1
fi

BRANCH_DISPLAY=$(get_branch_display)

echo "=================================================="
echo "Starting Project Zomboid Server..."
echo "Server Name: ${SERVER_NAME:-My PZ Server}"
echo "Branch: $BRANCH_DISPLAY"
echo "Memory: $(get_server_memory)"
echo "=================================================="
echo ""
if [ -n "$PLAYIT_TUNNEL" ]; then
    echo "Players can connect via Playit.gg:"
    echo "  $PLAYIT_TUNNEL"
    echo ""
fi
echo "=================================================="
echo "Server is starting in background..."
echo "=================================================="
echo ""

# Start the PZ server in background
nohup ./start-pzserver.sh > server.log 2>&1 &
SERVER_PID=$!

# Wait a moment and check if it started
sleep 3

if pgrep -f "$PZ_PROCESS_PATTERN" > /dev/null; then
    echo "✓ Server started successfully (PID: $(pgrep -f "$PZ_PROCESS_PATTERN"))"
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
