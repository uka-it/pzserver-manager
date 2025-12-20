#!/bin/bash
###############################################################################
# IPv6 to IPv4 Proxy for Project Zomboid Server
# This allows IPv6 clients to connect to the IPv4-only game server
###############################################################################

echo "=================================================="
echo "Starting IPv6 to IPv4 Proxy for PZ Server"
echo "=================================================="

# Your IPv6 address (will listen on all IPv6 interfaces)
# Forwarding to localhost IPv4 where the server runs

# Kill any existing socat processes for these ports
pkill -f "socat.*1626" 2>/dev/null
pkill -f "socat.*876" 2>/dev/null

# Start UDP proxy for main game port (16261)
echo "Starting UDP proxy: [::]:16261 -> 127.0.0.1:16261"
socat -d -d UDP6-LISTEN:16261,ipv6only=1,reuseaddr,fork UDP4:127.0.0.1:16261 &

# Start UDP proxy for secondary port (16262)
echo "Starting UDP proxy: [::]:16262 -> 127.0.0.1:16262"
socat -d -d UDP6-LISTEN:16262,ipv6only=1,reuseaddr,fork UDP4:127.0.0.1:16262 &

# Start UDP proxy for Steam port 1 (8766)
echo "Starting UDP proxy: [::]:8766 -> 127.0.0.1:8766"
socat -d -d UDP6-LISTEN:8766,ipv6only=1,reuseaddr,fork UDP4:127.0.0.1:8766 &

# Start UDP proxy for Steam port 2 (8767)
echo "Starting UDP proxy: [::]:8767 -> 127.0.0.1:8767"
socat -d -d UDP6-LISTEN:8767,ipv6only=1,reuseaddr,fork UDP4:127.0.0.1:8767 &

echo ""
echo "=================================================="
echo "IPv6 Proxy is now running!"
echo "=================================================="
echo "Players can connect using IPv6:"
echo "  [2804:14d:aea0:58d9:ad93:2c94:4346:844e]:16261"
echo ""
echo "To stop the proxy, run:"
echo "  pkill -f 'socat.*1626'"
echo "=================================================="

# Wait for user input to keep script running
echo ""
echo "Press Ctrl+C to stop the proxy..."
wait
