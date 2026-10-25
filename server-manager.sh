#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server - Main Management Menu
# Central script to manage all server operations
###############################################################################

# Get script directory dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
source "$SCRIPT_DIR/config.sh"

# Colors (REAL ESC bytes so printf renders colors correctly)
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
NC=$'\033[0m' # No Color

source "$SCRIPT_DIR/lib/ui-box.sh"

###############################################################################
# Header
###############################################################################
show_header() {
    # CRT Phosphor Green
    local CRT_GREEN=$'\033[1;92m'

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

###############################################################################
# Menu
###############################################################################
# Game console log: ~/Zomboid/server-console.txt, or the newest
# Logs/*/console.txt on older builds
find_console_log() {
    if [ -f "$ZOMBOID_DIR/server-console.txt" ]; then
        echo "$ZOMBOID_DIR/server-console.txt"
    else
        ls -t "$ZOMBOID_DIR"/Logs/*/console.txt 2>/dev/null | head -1
    fi
}

# Follow log file(s) live until the user presses q (or Ctrl+C)
follow_logs() {
    local key tail_pid stop=0
    echo -e "${YELLOW}Following $*${NC}"
    echo -e "${YELLOW}Press 'q' to return to the menu${NC}"
    echo ""
    tail -n 50 -F "$@" 2>/dev/null &
    tail_pid=$!
    # read is restarted after a trapped Ctrl+C, so poll with a timeout
    trap 'stop=1' INT
    while [ "$stop" -eq 0 ]; do
        if read -rsn1 -t 1 key && [[ "$key" == [qQ] ]]; then
            break
        fi
    done
    trap - INT
    kill "$tail_pid" 2>/dev/null
    wait "$tail_pid" 2>/dev/null
}

show_menu() {
    clear
    show_header
    echo ""

    BRANCH_DISPLAY=$(get_branch_display)

    # Check server status
    if pgrep -f "$PZ_PROCESS_PATTERN" > /dev/null; then
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
    SERVER_IP=$(get_local_ip)
    [ -z "$SERVER_IP" ] && SERVER_IP="Not detected"
    [ "$PZ_DOCKER" = "1" ] && [ -z "$HOST_IP" ] && SERVER_IP="$SERVER_IP (set HOST_IP to show the host IP)"

    SERVER_MEMORY=$(get_server_memory)

    # Frame
    box_top
    box_title_center "${YELLOW}SERVER MANAGEMENT CONSOLE${NC}  v${PZ_MANAGER_VERSION}"
    box_mid
    box_empty

    box_line "  ${BLUE}Server Status:${NC}   $SERVER_STATUS"
    box_line "  ${BLUE}Playit.gg:${NC}       $PLAYIT_STATUS"
    box_line "  ${BLUE}Game Branch:${NC}     ${CYAN}$BRANCH_DISPLAY${NC}"
    box_line "  ${BLUE}Server IP:${NC}       ${CYAN}$SERVER_IP${NC}"
    box_line "  ${BLUE}Server Ports:${NC}    ${CYAN}$DEFAULT_PORT${NC} (UDP: ${CYAN}$UDP_PORT${NC})"
    box_line "  ${BLUE}Steam Ports:${NC}     ${CYAN}$STEAM_PORT1${NC}, ${CYAN}$STEAM_PORT2${NC}"
    box_line "  ${BLUE}Server Memory:${NC}   ${CYAN}$SERVER_MEMORY${NC}"

    box_empty
    box_mid
    box_empty

    box_line "${YELLOW}  ⚙  SERVER CONTROL${NC}"
    box_line "    ${GREEN}[1]${NC} Start server"
    box_line "    ${GREEN}[2]${NC} Stop server"
    box_line "    ${GREEN}[3]${NC} Restart server"
    box_line "    ${GREEN}[4]${NC} View server status"

    box_empty
    box_line "${YELLOW}  🌐 PLAYIT.GG TUNNEL${NC}"
    box_line "    ${GREEN}[5]${NC} Start Playit.gg tunnel"
    box_line "    ${GREEN}[6]${NC} Stop Playit.gg tunnel"
    box_line "    ${GREEN}[7]${NC} Manage Playit.gg (install/setup/uninstall)"

    box_empty
    box_line "${YELLOW}  🔧 MAINTENANCE${NC}"
    box_line "    ${GREEN}[8]${NC} Update server files"
    box_line "    ${GREEN}[9]${NC} Switch game branch/version"
    box_line "    ${GREEN}[10]${NC} Clean cache & workshop files"
    box_line "    ${GREEN}[11]${NC} Setup new server (automated install)"

    box_empty
    box_line "${YELLOW}  ⚙  CONFIGURATION${NC} "
    box_line "    ${GREEN}[12]${NC} Edit server config files"
    box_line "    ${GREEN}[13]${NC} Reset admin password"
    box_line "    ${GREEN}[14]${NC} Set server memory"

    box_empty
    box_line "${YELLOW}  🌍 WORLD MANAGEMENT${NC}"
    box_line "    ${GREEN}[15]${NC} Reset world (fresh start)"
    box_line "    ${GREEN}[16]${NC} Manage backups (view/restore/delete)"

    box_empty
    box_line "${YELLOW}  📋 OTHER${NC}"
    box_line "    ${GREEN}[17]${NC} View server logs (live)"
    box_line "    ${RED}[18]${NC} Uninstall / Cleanup"
    box_line "    ${GREEN}[x]${NC} Exit"

    box_empty
    box_bottom
    echo ""
}

###############################################################################
# Main loop
###############################################################################
while true; do
    show_menu
    read -p "Choose option [1-18, x]: " choice
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
            "$SCRIPT_DIR/edit-server-config.sh"
            ;;
        13)
            clear
            "$SCRIPT_DIR/reset-admin-password.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        14)
            clear
            "$SCRIPT_DIR/set-memory.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        15)
            clear
            "$SCRIPT_DIR/reset-world.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        16)
            clear
            "$SCRIPT_DIR/manage-backups.sh"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        17)
            while true; do
                clear
                box_header "${YELLOW}SERVER LOGS${NC}"
                echo ""
                echo -e "  ${GREEN}[1]${NC} Server output (server.log)"
                echo -e "  ${GREEN}[2]${NC} Game console (server-console.txt)"
                echo -e "  ${GREEN}[3]${NC} Both (combined view)"
                echo -e "  ${GREEN}[0]${NC} Back to main menu"
                echo ""
                box_top
                box_line "${CYAN}Select a log view or return to the main menu.${NC}"
                box_bottom
                echo ""
                read -p "Choose option [0-3]: " log_choice

                case $log_choice in
                    1)
                        clear
                        if [ -f "$SCRIPT_DIR/server.log" ]; then
                            follow_logs "$SCRIPT_DIR/server.log"
                        else
                            echo -e "${RED}No server.log found${NC}"
                            sleep 2
                        fi
                        ;;
                    2)
                        clear
                        CONSOLE_LOG=$(find_console_log)
                        if [ -n "$CONSOLE_LOG" ]; then
                            follow_logs "$CONSOLE_LOG"
                        else
                            echo -e "${RED}No console log found${NC}"
                            sleep 2
                        fi
                        ;;
                    3)
                        clear
                        CONSOLE_LOG=$(find_console_log)
                        LOG_FILES=()
                        [ -f "$SCRIPT_DIR/server.log" ] && LOG_FILES+=("$SCRIPT_DIR/server.log")
                        [ -n "$CONSOLE_LOG" ] && LOG_FILES+=("$CONSOLE_LOG")
                        if [ ${#LOG_FILES[@]} -gt 0 ]; then
                            follow_logs "${LOG_FILES[@]}"
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
        18)
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
            echo -e "${RED}Invalid option. Please choose 1-18 or x to exit.${NC}"
            sleep 2
            ;;
    esac
done
