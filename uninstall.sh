#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server - Uninstall Script
# Selectively remove server components
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Colors
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

source "$SCRIPT_DIR/lib/ui-box.sh"

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
    box_header "${YELLOW}UNINSTALL / CLEANUP${NC}"
}

calculate_sizes() {
    # Calculate component sizes
    if [ -d "$STEAMCMD_DIR" ]; then
        STEAMCMD_SIZE=$(du -sh "$STEAMCMD_DIR" 2>/dev/null | awk '{print $1}')
    else
        STEAMCMD_SIZE="0"
    fi

    if [ -d "$INSTALL_DIR" ]; then
        PZSERVER_SIZE=$(du -sh "$INSTALL_DIR" 2>/dev/null | awk '{print $1}')
    else
        PZSERVER_SIZE="0"
    fi

    if [ -d "$ZOMBOID_DIR" ]; then
        DATA_SIZE=$(du -sh "$ZOMBOID_DIR" 2>/dev/null | awk '{print $1}')
    else
        DATA_SIZE="0"
    fi
}

show_menu() {
    calculate_sizes

    echo -e "${YELLOW}What would you like to uninstall?${NC}"
    echo ""
    echo -e "  ${GREEN}[1]${NC} SteamCMD only [$STEAMCMD_SIZE]"
    echo "      Keeps: Project Zomboid server, world data"
    echo "      (Can be reinstalled to update server later)"
    echo ""
    echo -e "  ${GREEN}[2]${NC} Project Zomboid server only [$PZSERVER_SIZE]"
    echo "      Keeps: SteamCMD, world data, saves, player database"
    echo ""
    echo -e "  ${GREEN}[3]${NC} World data only [$DATA_SIZE]"
    echo "      Keeps: Server files, can create a new world"
    echo ""
    echo -e "  ${RED}[4]${NC} Everything (SteamCMD + server + world data)"
    echo "      Complete removal, fresh start"
    echo ""
    echo -e "  ${GREEN}[5]${NC} Cancel"
    echo ""
    box_top
    box_line "${YELLOW}Select an option and follow the confirmation prompts.${NC}"
    box_bottom
    echo ""
}

stop_services() {
    echo -e "${YELLOW}Stopping all services...${NC}"
    echo ""

    if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
        echo "Stopping Project Zomboid server..."
        pkill -f "ProjectZomboid64.*pzserver"
        sleep 3
    fi

    if pgrep -x "playit" > /dev/null; then
        echo "Stopping Playit.gg..."
        pkill playit
        sleep 1
    fi

    echo -e "${GREEN}✓ Services stopped${NC}"
    echo ""
}

uninstall_steamcmd() {
    echo ""
    box_header "${YELLOW}UNINSTALL STEAMCMD ONLY${NC}"
    echo "This will remove:"
    echo "  - SteamCMD ($STEAMCMD_DIR)"
    echo ""
    echo "This will NOT remove:"
    echo "  - Project Zomboid server files"
    echo "  - World saves and configurations"
    echo ""
    echo "Note: You can reinstall SteamCMD later to update the server."
    echo ""
    read -p "Type 'DELETE' to confirm: " confirm

    if [ "$confirm" != "DELETE" ]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        return
    fi

    echo "Removing SteamCMD..."
    if [ -d "$STEAMCMD_DIR" ]; then
        rm -rf "$STEAMCMD_DIR"
        echo -e "${GREEN}✓ SteamCMD removed ($STEAMCMD_SIZE freed)${NC}"
    else
        echo -e "${YELLOW}ℹ SteamCMD not found${NC}"
    fi
}

uninstall_pzserver_only() {
    echo ""
    box_header "${RED}UNINSTALL PROJECT ZOMBOID SERVER${NC}"
    echo "This will remove:"
    echo "  - Project Zomboid server files"
    echo "  - All installed mods and workshop content"
    echo ""
    echo "This will NOT remove:"
    echo "  - SteamCMD (can reinstall server later)"
    echo "  - World saves ($ZOMBOID_DIR)"
    echo "  - Player database and configurations"
    echo ""
    read -p "Type 'DELETE' to confirm: " confirm

    if [ "$confirm" != "DELETE" ]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        return
    fi

    stop_services

    echo "Removing Project Zomboid server..."
    # Remove everything in INSTALL_DIR except steamcmd folder
    if [ -d "$INSTALL_DIR" ]; then
        find "$INSTALL_DIR" -mindepth 1 -maxdepth 1 ! -name 'steamcmd' -exec rm -rf {} +
        echo -e "${GREEN}✓ Project Zomboid server removed${NC}"
    else
        echo -e "${YELLOW}ℹ No server files found${NC}"
    fi
}

uninstall_world_data() {
    echo ""
    box_header "${RED}UNINSTALL WORLD DATA${NC}"
    echo -e "${RED}⚠ WARNING: This will DELETE all your world progress!${NC}"
    echo ""
    echo "This will remove:"
    echo "  - All world saves"
    echo "  - Player database"
    echo "  - Server configurations"
    echo "  - Logs"
    echo "  - Location: $ZOMBOID_DIR"
    echo ""
    echo "This will NOT remove:"
    echo "  - Server installation files"
    echo "  - You can create a new world after this"
    echo ""
    read -p "Type 'DELETE' to confirm: " confirm

    if [ "$confirm" != "DELETE" ]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        return
    fi

    stop_services

    echo "Removing world data..."
    if [ -d "$ZOMBOID_DIR" ]; then
        rm -rf "$ZOMBOID_DIR"
        echo -e "${GREEN}✓ World data removed ($DATA_SIZE freed)${NC}"
    else
        echo -e "${YELLOW}ℹ No world data found${NC}"
    fi
}

uninstall_everything() {
    echo ""
    box_header "${RED}COMPLETE UNINSTALL${NC}"
    echo -e "${RED}⚠ FINAL WARNING: This will remove EVERYTHING!${NC}"
    echo ""
    echo "This will remove:"
    echo "  - SteamCMD ($STEAMCMD_SIZE)"
    echo "  - Project Zomboid server ($PZSERVER_SIZE)"
    echo "  - World data ($DATA_SIZE)"
    echo "  - All configurations"
    echo ""
    echo "The only thing remaining will be this management script folder."
    echo ""
    read -p "Type 'DELETE EVERYTHING' to confirm: " confirm

    if [ "$confirm" != "DELETE EVERYTHING" ]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        return
    fi

    stop_services

    echo ""
    echo "Removing all components..."
    echo ""

    # Remove server files (includes SteamCMD and PZ server)
    if [ -d "$INSTALL_DIR" ]; then
        echo "Removing server files..."
        rm -rf "$INSTALL_DIR"
        echo -e "${GREEN}✓ Server files removed${NC}"
    fi

    # Remove world data
    if [ -d "$ZOMBOID_DIR" ]; then
        echo "Removing world data..."
        rm -rf "$ZOMBOID_DIR"
        echo -e "${GREEN}✓ World data removed${NC}"
    fi

    # Remove .env file
    if [ -f "$SCRIPT_DIR/.env" ]; then
        rm -f "$SCRIPT_DIR/.env"
        echo -e "${GREEN}✓ Configuration removed${NC}"
    fi

    # Remove flag files
    rm -f "$SCRIPT_DIR/.admin_created"

    echo ""
    box_top
    box_line "${GREEN}✓ Complete Uninstall Finished${NC}"
    box_bottom
    echo ""
    echo "All server components removed"
    echo ""
    echo "This management script folder is still here at:"
    echo "  $SCRIPT_DIR"
    echo ""
    echo "You can run ./setup-new-server.sh to reinstall anytime."
    echo ""
}

# Main execution
show_header
show_menu

read -p "Choose option [1-5]: " choice
echo ""

case $choice in
    1)
        uninstall_steamcmd
        ;;
    2)
        uninstall_pzserver_only
        ;;
    3)
        uninstall_world_data
        ;;
    4)
        uninstall_everything
        ;;
    5)
        echo -e "${GREEN}Cancelled.${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option.${NC}"
        exit 1
        ;;
esac

echo ""
read -p "Press Enter to exit..."
