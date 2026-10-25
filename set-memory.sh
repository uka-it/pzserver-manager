#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server - Set Server Memory
# Saves SERVER_MEMORY to .env; it is applied to ProjectZomboid64.json on start
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Colors
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

source "$SCRIPT_DIR/lib/ui-box.sh"

box_header "${YELLOW}SET SERVER MEMORY${NC}"

CURRENT_MEMORY=$(get_server_memory)
echo -e "Current server memory: ${CYAN}$CURRENT_MEMORY${NC}"
echo ""

DEFAULT_MEMORY=$(normalize_memory "$CURRENT_MEMORY") || DEFAULT_MEMORY=""
prompt_server_memory "$DEFAULT_MEMORY"
NEW_MEMORY="$CHOSEN_MEMORY"

if [ "$NEW_MEMORY" = "$CURRENT_MEMORY" ] && [ -n "$SERVER_MEMORY" ]; then
    echo ""
    echo -e "${YELLOW}Memory unchanged ($NEW_MEMORY)${NC}"
    exit 0
fi

set_env_value SERVER_MEMORY "$NEW_MEMORY"
SERVER_MEMORY="$NEW_MEMORY"
apply_server_memory

echo ""
echo -e "${GREEN}✓ Server memory set to $NEW_MEMORY${NC}"

if pgrep -f "$PZ_PROCESS_PATTERN" > /dev/null; then
    echo ""
    echo -e "${YELLOW}The server is running - the new memory applies after a restart.${NC}"
    read -p "Restart the server now? (yes/no): " restart
    if [ "$restart" = "yes" ]; then
        "$SCRIPT_DIR/stop-server-only.sh"
        "$SCRIPT_DIR/start-server-only.sh"
    fi
fi
