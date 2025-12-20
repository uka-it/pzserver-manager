#!/usr/bin/env bash
###############################################################################
# Check Status of Project Zomboid Server + Playit.gg
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "=================================================="
echo "Project Zomboid Server Status"
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
ss -ulpn 2>/dev/null | grep -E "($DEFAULT_PORT|$UDP_PORT)" | while read line; do
    echo "  $line" | awk '{print "  " $1 " " $5}'
done

echo ""
echo "=================================================="
echo "Connection Information:"
echo "=================================================="

# Show configured connection info
if [ -n "$PLAYIT_TUNNEL" ]; then
    echo "  Playit.gg: $PLAYIT_TUNNEL"
elif pgrep -x "playit" > /dev/null && command -v playit &> /dev/null; then
    # Try to get tunnel address from playit
    TUNNEL=$(playit tunnels list 2>/dev/null | grep "=>" | head -1 | awk '{print $1}')
    if [ -n "$TUNNEL" ]; then
        echo "  Playit.gg: $TUNNEL"
    fi
fi

if [ -n "$PUBLIC_DOMAIN" ]; then
    echo "  Domain:    $PUBLIC_DOMAIN:$DEFAULT_PORT"
fi

if [ -n "$PUBLIC_IPV6" ]; then
    echo "  IPv6:      [$PUBLIC_IPV6]:$DEFAULT_PORT"
fi

# Always show local
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "  Local:     ${LOCAL_IP:-127.0.0.1}:$DEFAULT_PORT"

echo "=================================================="
