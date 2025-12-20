#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server - Uninstall Script
# Selectively remove server components
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

show_header() {
    clear
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
    echo -e "${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}║                           ${YELLOW}UNINSTALL / CLEANUP${CYAN}                                ║${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

calculate_sizes() {
    # Calculate component sizes
    if [ -d "$INSTALL_DIR" ]; then
        SERVER_SIZE=$(du -sh "$INSTALL_DIR" 2>/dev/null | awk '{print $1}')
    else
        SERVER_SIZE="0"
    fi

    if [ -d "$ZOMBOID_DIR" ]; then
        DATA_SIZE=$(du -sh "$ZOMBOID_DIR" 2>/dev/null | awk '{print $1}')
    else
        DATA_SIZE="0"
    fi

    if command -v playit &> /dev/null; then
        PLAYIT_SIZE="~10M (installed)"
    else
        PLAYIT_SIZE="Not installed"
    fi
}

show_menu() {
    calculate_sizes

    echo -e "${YELLOW}What would you like to uninstall?${NC}"
    echo ""
    echo -e "  ${GREEN}[1]${NC} Server files only (SteamCMD + Project Zomboid) [$SERVER_SIZE]"
    echo "      Keeps: World data, saves, player database"
    echo ""
    echo -e "  ${GREEN}[2]${NC} World data only (saves, database, configs) [$DATA_SIZE]"
    echo "      Keeps: Server files, you can create a new world"
    echo ""
    echo -e "  ${GREEN}[3]${NC} Playit.gg only [$PLAYIT_SIZE]"
    echo "      Removes the tunneling service"
    echo ""
    echo -e "  ${RED}[4]${NC} Everything (server + world data + Playit.gg)"
    echo "      Complete removal, fresh start"
    echo ""
    echo -e "  ${GREEN}[5]${NC} Cancel"
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
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

uninstall_server() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}UNINSTALL SERVER FILES${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "This will remove:"
    echo "  - SteamCMD ($STEAMCMD_DIR)"
    echo "  - Project Zomboid server files ($INSTALL_DIR)"
    echo "  - All installed mods and workshop content"
    echo ""
    echo "This will NOT remove:"
    echo "  - World saves ($ZOMBOID_DIR)"
    echo "  - Player database"
    echo "  - Server configurations"
    echo ""
    read -p "Type 'DELETE' to confirm: " confirm

    if [ "$confirm" != "DELETE" ]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        return
    fi

    stop_services

    echo "Removing server files..."
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        echo -e "${GREEN}✓ Server files removed ($SERVER_SIZE freed)${NC}"
    else
        echo -e "${YELLOW}ℹ No server files found${NC}"
    fi
}

uninstall_world_data() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}UNINSTALL WORLD DATA${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
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

uninstall_playit() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}UNINSTALL PLAYIT.GG${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""

    if ! command -v playit &> /dev/null; then
        echo -e "${YELLOW}ℹ Playit.gg is not installed${NC}"
        sleep 2
        return
    fi

    echo "This will remove the Playit.gg tunneling service."
    echo "You will need to use direct connection or another tunnel solution."
    echo ""
    read -p "Remove Playit.gg? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        return
    fi

    # Stop playit if running
    if pgrep -x "playit" > /dev/null; then
        echo "Stopping Playit.gg..."
        pkill playit
        sleep 1
    fi

    echo "Uninstalling Playit.gg..."
    sudo apt remove -y playit 2>/dev/null
    sudo rm -f /etc/apt/sources.list.d/playit-cloud.list
    sudo rm -f /etc/apt/trusted.gpg.d/playit.gpg

    echo -e "${GREEN}✓ Playit.gg removed${NC}"
}

uninstall_everything() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}COMPLETE UNINSTALL${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${RED}⚠ FINAL WARNING: This will remove EVERYTHING!${NC}"
    echo ""
    echo "This will remove:"
    echo "  - Server files ($SERVER_SIZE)"
    echo "  - World data ($DATA_SIZE)"
    echo "  - Playit.gg"
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

    # Remove server files
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

    # Remove Playit.gg
    if command -v playit &> /dev/null; then
        echo "Removing Playit.gg..."
        sudo apt remove -y playit 2>/dev/null
        sudo rm -f /etc/apt/sources.list.d/playit-cloud.list
        sudo rm -f /etc/apt/trusted.gpg.d/playit.gpg
        echo -e "${GREEN}✓ Playit.gg removed${NC}"
    fi

    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Complete Uninstall Finished${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Total space freed: Combined $SERVER_SIZE + $DATA_SIZE"
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
        uninstall_server
        ;;
    2)
        uninstall_world_data
        ;;
    3)
        uninstall_playit
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
