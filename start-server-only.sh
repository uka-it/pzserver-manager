#!/usr/bin/env bash
###############################################################################
# Start Project Zomboid Server Only (No Playit.gg)
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

show_header() {
    clear
    # CRT Phosphor Green
    local CRT_GREEN='\033[1;92m'

    echo -e "${RED}"
    cat << 'EOF'
 ██▓███   ██▀███   ▒█████   ▄▄▄██▀▀▀▓█████  ▄████▄  ▄▄▄█████▓   ▒███████▒ ▒█████   ███▄ ▄███▓ ▄▄▄▄    ▒█████   ██▓▓█████▄
▓██░  ██▒▓██ ▒ ██▒▒██▒  ██▒   ▒██   ▓█   ▀ ▒██▀ ▀█  ▓  ██▒ ▓▒   ▒ ▒ ▒ ▄▀░▒██▒  ██▒▓██▒▀█▀ ██▒▓█████▄ ▒██▒  ██▒▓██▒▒██▀ ██▌
▓██░ ██▓▒▓██ ░▄█ ▒▒██░  ██▒   ░██   ▒███   ▒▓█    ▄ ▒ ▓██░ ▒░   ░ ▒ ▄▀▒░ ▒██░  ██▒▓██    ▓██░▒██▒ ▄██▒██░  ██▒▒██▒░██   █▌
▒██▄█▓▒ ▒▒██▀▀█▄  ▒██   ██░▓██▄██▓  ▒▓█  ▄ ▒▓▓▄ ▄██▒░ ▓██▓ ░      ▄▀▒   ░▒██   ██░▒██    ▒██ ▒██░█▀  ▒██   ██░░██░░▓█▄   ▌
▒██▒ ░  ░░██▓ ▒██▒░ ████▓▒░ ▓███▒   ░▒████▒▒ ▓███▀ ░  ▒██▒ ░    ▒███████▒░ ████▓▒░▒██▒   ░██▒░▓█  ▀█▓░ ████▓▒░░██░░▒████▓
▒▓▒░ ░  ░░ ▒▓ ░▒▓░░ ▒░▒░▒░  ▒▓▒▒░   ░░ ▒░ ░░ ░▒ ▒  ░  ▒ ░░      ░▒▒ ▓░▒░▒░ ▒░▒░▒░ ░ ▒░   ░  ░░▒▓███▀▒░ ▒░▒░▒░ ░▓   ▒▒▓  ▒
░▒ ░       ░▒ ░ ▒░  ░ ▒ ▒░  ▒ ░▒░    ░ ░  ░  ░  ▒       ░       ░░▒ ▒ ░ ▒  ░ ▒ ▒░ ░  ░      ░▒░▒   ░   ░ ▒ ▒░  ▒ ░ ░ ▒  ▒
░░         ░░   ░ ░ ░ ░ ▒   ░ ░ ░      ░   ░          ░         ░ ░ ░ ░ ░░ ░ ░ ▒  ░      ░    ░    ░ ░ ░ ░ ▒   ▒ ░ ░ ░  ░
            ░         ░ ░   ░   ░      ░  ░░ ░                    ░ ░        ░ ░         ░    ░          ░ ░   ░     ░
                                           ░                    ░                                  ░               ░
EOF
    echo -e "${CRT_GREEN}"
    cat << 'EOF'
▄▄▄▄▄▄            ▄▄                                ▄▄    ▄▄▄▄▄▄▄
███▀▀██▄          ██ ▀▀               ██            ██   █████▀▀▀
███  ███ ▄█▀█▄ ▄████ ██  ▄████  ▀▀█▄ ▀██▀▀ ▄█▀█▄ ▄████    ▀████▄  ▄█▀█▄ ████▄ ██ ██ ▄█▀█▄ ████▄
███  ███ ██▄█▀ ██ ██ ██  ██    ▄█▀██  ██   ██▄█▀ ██ ██      ▀████ ██▄█▀ ██ ▀▀ ██▄██ ██▄█▀ ██ ▀▀
██████▀  ▀█▄▄▄ ▀████ ██▄ ▀████ ▀█▄██  ██   ▀█▄▄▄ ▀████   ███████▀ ▀█▄▄▄ ██     ▀█▀  ▀█▄▄▄ ██
EOF
    echo -e "${NC}"
    echo ""
}

cd "${SCRIPT_DIR}"

show_header
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                           ${YELLOW}STARTING SERVER${CYAN}                                    ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

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

echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Server Configuration:${NC}"
echo -e "  ${BLUE}Name:${NC}   ${SERVER_NAME:-My PZ Server}"
echo -e "  ${BLUE}Branch:${NC} $BRANCH_DISPLAY"
echo -e "  ${BLUE}Memory:${NC} 8GB"
echo -e "  ${BLUE}Mode:${NC}   Direct Connection (No Playit.gg)"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Players can connect via:${NC}"
if [ -n "$PUBLIC_DOMAIN" ]; then
    echo "  Domain: $PUBLIC_DOMAIN:$DEFAULT_PORT"
fi
if [ -n "$PUBLIC_IPV6" ]; then
    echo "  IPv6: [$PUBLIC_IPV6]:$DEFAULT_PORT"
fi
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "  Local: ${LOCAL_IP:-127.0.0.1}:$DEFAULT_PORT"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Server is starting in background...${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
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
