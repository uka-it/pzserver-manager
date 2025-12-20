#!/usr/bin/env bash
###############################################################################
# Check Status of Project Zomboid Server + Playit.gg
###############################################################################

echo "=================================================="
echo "ShadowZombie Server Status"
echo "=================================================="
echo ""

# Check Project Zomboid server
if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
    PZ_PID=$(pgrep -f "ProjectZomboid64.*pzserver")
    echo "✓ Project Zomboid Server: RUNNING (PID: $PZ_PID)"

    # Show memory usage
    PZ_MEM=$(ps -p $PZ_PID -o rss= | awk '{printf "%.1f GB", $1/1024/1024}')
    echo "  Memory Usage: $PZ_MEM"
else
    echo "✗ Project Zomboid Server: NOT RUNNING"
fi

echo ""

# Check Playit.gg
if pgrep -x "playit" > /dev/null; then
    PLAYIT_PID=$(pgrep -x "playit")
    echo "✓ Playit.gg Tunnel: RUNNING (PID: $PLAYIT_PID)"
    echo ""
    echo "  Active Tunnels:"
    playit tunnels list 2>/dev/null | grep "=>" | sed 's/^/    /'
else
    echo "✗ Playit.gg Tunnel: NOT RUNNING"
fi

echo ""

# Check listening ports
echo "Listening Ports:"
ss -ulpn 2>/dev/null | grep -E "(16261|16262)" | while read line; do
    echo "  $line" | awk '{print "  " $1 " " $5}'
done

echo ""
echo "=================================================="
echo "Connection Information:"
echo "=================================================="
echo "  Playit.gg: glass-fascinating.gl.at.ply.gg:11128"
echo "  IPv6:      shadowzombie.uka-it.com:16261"
echo "  Local:     127.0.0.1:16261"
echo "=================================================="
