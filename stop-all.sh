#!/usr/bin/env bash
###############################################################################
# Stop Project Zomboid Server + Playit.gg
###############################################################################

echo "=================================================="
echo "Stopping ShadowZombie Server + Playit.gg"
echo "=================================================="

# Stop Project Zomboid server
if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
    echo "Stopping Project Zomboid server..."
    pkill -f "ProjectZomboid64.*pzserver"
    sleep 3
    echo "✓ Project Zomboid server stopped"
else
    echo "ℹ Project Zomboid server is not running"
fi

# Stop Playit.gg
if pgrep -x "playit" > /dev/null; then
    echo "Stopping Playit.gg tunnel..."
    pkill playit
    sleep 1
    echo "✓ Playit.gg stopped"
else
    echo "ℹ Playit.gg is not running"
fi

echo ""
echo "=================================================="
echo "All services stopped"
echo "=================================================="
