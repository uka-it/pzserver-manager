#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server - Main Management Menu
# Central script to manage all server operations
###############################################################################

# Get script directory dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
source "$SCRIPT_DIR/config.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

show_header() {
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
}

show_menu() {
    clear
    show_header

    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                          ${YELLOW}SERVER MANAGEMENT CONSOLE${CYAN}                           ║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo ""

    # Detect current branch
    MANIFEST="$INSTALL_DIR/steamapps/appmanifest_380870.acf"
    if [ -f "$MANIFEST" ]; then
        CURRENT_BRANCH=$(grep "BetaKey" "$MANIFEST" | head -1 | sed 's/.*"BetaKey".*"\([^"]*\)".*/\1/')
        BUILD_ID=$(grep "buildid" "$MANIFEST" | head -1 | sed 's/.*"buildid".*"\([^"]*\)".*/\1/')

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

    # Check server status
    if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
        SERVER_STATUS="${GREEN}● RUNNING${NC}"
    else
        SERVER_STATUS="${RED}● STOPPED${NC}"
    fi

    # Check Playit status
    if pgrep -x "playit" > /dev/null; then
        PLAYIT_STATUS="${GREEN}● RUNNING${NC}"
    else
        PLAYIT_STATUS="${YELLOW}● STOPPED${NC}"
    fi

    # Get IP address
    SERVER_IP=$(hostname -I | awk '{print $1}')
    [ -z "$SERVER_IP" ] && SERVER_IP="Not detected"

    # Get memory allocation (from ProjectZomboid64.json or default)
    if [ -f "$INSTALL_DIR/ProjectZomboid64.json" ]; then
        SERVER_MEMORY=$(grep -o '"vmArgs".*-Xmx[0-9]*[gGmM]' "$INSTALL_DIR/ProjectZomboid64.json" 2>/dev/null | grep -o '[0-9]*[gGmM]' | tail -1)
    fi
    [ -z "$SERVER_MEMORY" ] && SERVER_MEMORY="8G (default)"

    echo -e "  ${BLUE}Server Status:${NC}    $SERVER_STATUS"
    echo -e "  ${BLUE}Playit.gg:${NC}       $PLAYIT_STATUS"
    echo -e "  ${BLUE}Game Branch:${NC}     ${CYAN}$BRANCH_DISPLAY${NC}"
    echo -e "  ${BLUE}Server IP:${NC}       ${CYAN}$SERVER_IP${NC}"
    echo -e "  ${BLUE}Server Ports:${NC}    ${CYAN}$DEFAULT_PORT${NC} (UDP: ${CYAN}$UDP_PORT${NC})"
    echo -e "  ${BLUE}Steam Ports:${NC}     ${CYAN}$STEAM_PORT1${NC}, ${CYAN}$STEAM_PORT2${NC}"
    echo -e "  ${BLUE}Server Memory:${NC}   ${CYAN}$SERVER_MEMORY${NC}"
    echo ""
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo ""
    echo -e "${YELLOW}  ⚙  SERVER CONTROL${NC}"
    echo -e "    ${GREEN}[1]${NC} Start server"
    echo -e "    ${GREEN}[2]${NC} Stop server"
    echo -e "    ${GREEN}[3]${NC} Restart server"
    echo -e "    ${GREEN}[4]${NC} View server status"
    echo ""
    echo -e "${YELLOW}  🌐 PLAYIT.GG TUNNEL${NC}"
    echo -e "    ${GREEN}[5]${NC} Start Playit.gg tunnel"
    echo -e "    ${GREEN}[6]${NC} Stop Playit.gg tunnel"
    echo -e "    ${GREEN}[7]${NC} Manage Playit.gg (install/setup/uninstall)"
    echo ""
    echo -e "${YELLOW}  🔧 MAINTENANCE${NC}"
    echo -e "    ${GREEN}[8]${NC} Update server files"
    echo -e "    ${GREEN}[9]${NC} Switch game branch/version"
    echo -e "    ${GREEN}[10]${NC} Clean cache & workshop files"
    echo -e "    ${GREEN}[11]${NC} Setup new server (automated install)"
    echo ""
    echo -e "${YELLOW}  🌍 WORLD MANAGEMENT${NC}"
    echo -e "    ${GREEN}[12]${NC} Reset world (fresh start)"
    echo -e "    ${GREEN}[13]${NC} Manage backups (view/restore/delete)"
    echo ""
    echo -e "${YELLOW}  📋 OTHER${NC}"
    echo -e "    ${GREEN}[14]${NC} View server logs (live)"
    echo -e "    ${RED}[15]${NC} Uninstall / Cleanup"
    echo -e "    ${GREEN}[x]${NC} Exit"
    echo ""
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

while true; do
    show_menu
    read -p "Choose option [1-15, x]: " choice
    echo ""

    case $choice in
        1)
            clear
            echo -e "${GREEN}Starting server...${NC}"
            echo ""
            "$SCRIPT_DIR/start-server-only.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        2)
            clear
            echo -e "${YELLOW}Stopping server...${NC}"
            echo ""
            "$SCRIPT_DIR/stop-server-only.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        3)
            clear
            echo -e "${YELLOW}Restarting server...${NC}"
            echo ""
            "$SCRIPT_DIR/stop-server-only.sh"
            sleep 3
            echo ""
            "$SCRIPT_DIR/start-server-only.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        4)
            clear
            "$SCRIPT_DIR/status.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        5)
            clear
            if ! command -v playit &> /dev/null; then
                echo -e "${RED}✗ Playit.gg is not installed${NC}"
                echo "  Use option [7] to install it first"
            elif pgrep -x "playit" > /dev/null; then
                echo -e "${YELLOW}✓ Playit.gg is already running${NC}"
            else
                echo -e "${GREEN}Starting Playit.gg tunnel...${NC}"
                nohup playit start > "$SCRIPT_DIR/playit.log" 2>&1 &
                sleep 2
                if pgrep -x "playit" > /dev/null; then
                    echo -e "${GREEN}✓ Playit.gg started${NC}"
                else
                    echo -e "${RED}✗ Failed to start${NC}"
                fi
            fi
            echo ""
            read -p "Press Enter to continue..."
            ;;
        6)
            clear
            if pgrep -x "playit" > /dev/null; then
                echo -e "${YELLOW}Stopping Playit.gg tunnel...${NC}"
                pkill playit
                sleep 1
                echo -e "${GREEN}✓ Playit.gg stopped${NC}"
            else
                echo -e "${YELLOW}ℹ Playit.gg is not running${NC}"
            fi
            echo ""
            read -p "Press Enter to continue..."
            ;;
        7)
            clear
            "$SCRIPT_DIR/manage-playit.sh"
            ;;
        8)
            clear
            "$SCRIPT_DIR/update-server.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        9)
            clear
            "$SCRIPT_DIR/list-branches.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        10)
            clear
            "$SCRIPT_DIR/clean-cache.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        11)
            clear
            "$SCRIPT_DIR/setup-new-server.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        12)
            clear
            "$SCRIPT_DIR/reset-world.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        13)
            clear
            "$SCRIPT_DIR/manage-backups.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        14)
            while true; do
                clear
                echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
                echo -e "${CYAN}║                              ${YELLOW}SERVER LOGS${CYAN}                                    ║${NC}"
                echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
                echo ""
                echo -e "  ${GREEN}[1]${NC} Server output (server.log)"
                echo -e "  ${GREEN}[2]${NC} Game console (console.txt)"
                echo -e "  ${GREEN}[3]${NC} Both (combined view)"
                echo -e "  ${GREEN}[0]${NC} Back to main menu"
                echo ""
                echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
                echo ""
                read -p "Choose option [0-3]: " log_choice

                case $log_choice in
                    1)
                        clear
                        echo -e "${YELLOW}Loading server.log... (Press 'q' to exit)${NC}"
                        echo ""
                        sleep 1
                        if [ -f "$SCRIPT_DIR/server.log" ]; then
                            less +F "$SCRIPT_DIR/server.log"
                        else
                            echo -e "${RED}No server.log found${NC}"
                            sleep 2
                        fi
                        ;;
                    2)
                        clear
                        echo -e "${YELLOW}Loading console.txt... (Press 'q' to exit)${NC}"
                        echo ""
                        sleep 1
                        CONSOLE_LOG=$(ls -t $ZOMBOID_DIR/Logs/*/console.txt 2>/dev/null | head -1)
                        if [ -n "$CONSOLE_LOG" ]; then
                            less +F "$CONSOLE_LOG"
                        else
                            echo -e "${RED}No console.txt found${NC}"
                            sleep 2
                        fi
                        ;;
                    3)
                        clear
                        echo -e "${YELLOW}Loading combined logs... (Press 'q' to exit)${NC}"
                        echo ""
                        sleep 1
                        CONSOLE_LOG=$(ls -t $ZOMBOID_DIR/Logs/*/console.txt 2>/dev/null | head -1)
                        if [ -f "$SCRIPT_DIR/server.log" ] || [ -n "$CONSOLE_LOG" ]; then
                            (tail -f "$SCRIPT_DIR/server.log" 2>/dev/null & tail -f "$CONSOLE_LOG" 2>/dev/null) | less +F
                        else
                            echo -e "${RED}No logs found${NC}"
                            sleep 2
                        fi
                        ;;
                    0)
                        break
                        ;;
                    *)
                        echo -e "${RED}Invalid choice${NC}"
                        sleep 2
                        ;;
                esac
            done
            ;;
        15)
            clear
            "$SCRIPT_DIR/uninstall.sh"
            ;;
        x|X)
            clear
            echo -e "${GREEN}Exiting server manager...${NC}"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please choose 1-15 or x to exit.${NC}"
            sleep 2
            ;;
    esac
done
