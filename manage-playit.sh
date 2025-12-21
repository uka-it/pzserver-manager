#!/usr/bin/env bash
###############################################################################
# Playit.gg Tunnel Manager
# Manage Playit.gg tunnel service
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

install_playit() {
    show_header
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                            ${YELLOW}INSTALL PLAYIT.GG${CYAN}                                   ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if command -v playit &> /dev/null; then
        echo -e "${YELLOW}✓ Playit.gg is already installed${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    echo -e "${YELLOW}Installing Playit.gg...${NC}"
    echo ""

    # Add Playit.gg repository
    echo "Adding Playit.gg repository..."
    curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list

    # Update and install
    echo "Updating package list..."
    sudo apt update

    echo "Installing playit..."
    sudo apt install -y playit

    if command -v playit &> /dev/null; then
        echo ""
        echo -e "${GREEN}✓ Playit.gg installed successfully${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Choose option [6] to setup tunnels"
        echo "  2. Create UDP tunnels for ports: $DEFAULT_PORT, $UDP_PORT, $STEAM_PORT1, $STEAM_PORT2"
    else
        echo ""
        echo -e "${RED}✗ Installation failed${NC}"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

uninstall_playit() {
    show_header
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                           ${YELLOW}UNINSTALL PLAYIT.GG${CYAN}                                  ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if ! command -v playit &> /dev/null; then
        echo -e "${YELLOW}Playit.gg is not installed${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    # Stop if running
    if pgrep -x "playit" > /dev/null; then
        echo "Stopping Playit.gg..."
        pkill playit
        sleep 1
    fi

    echo -e "${RED}This will remove Playit.gg and all its configuration.${NC}"
    echo ""
    read -p "Are you sure? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        echo "Cancelled."
        sleep 1
        return
    fi

    echo ""
    echo "Removing Playit.gg..."
    sudo apt remove -y playit

    echo "Removing repository..."
    sudo rm -f /etc/apt/sources.list.d/playit-cloud.list
    sudo rm -f /etc/apt/trusted.gpg.d/playit.gpg

    echo "Removing logs..."
    rm -f "$SCRIPT_DIR/playit.log"

    echo ""
    echo -e "${GREEN}✓ Playit.gg uninstalled${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

show_menu() {
    # Check if installed
    if command -v playit &> /dev/null; then
        INSTALLED="${GREEN}● INSTALLED${NC}"

        # Check status
        if pgrep -x "playit" > /dev/null; then
            STATUS="${GREEN}● RUNNING${NC}"
            PLAYIT_PID=$(pgrep -x "playit")
        else
            STATUS="${YELLOW}● STOPPED${NC}"
            PLAYIT_PID="N/A"
        fi
    else
        INSTALLED="${RED}● NOT INSTALLED${NC}"
        STATUS="N/A"
        PLAYIT_PID="N/A"
    fi

    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                        ${YELLOW}PLAYIT.GG TUNNEL MANAGER${CYAN}                               ║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo ""
    echo -e "  ${BLUE}Installation Status:${NC} $INSTALLED"
    if [ "$STATUS" != "N/A" ]; then
        echo -e "  ${BLUE}Service Status:${NC}     $STATUS"
        if [ "$PLAYIT_PID" != "N/A" ]; then
            echo -e "  ${BLUE}Process ID:${NC}         $PLAYIT_PID"
        fi
    fi
    echo ""
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║                                                                                ║${NC}"
    echo -e "${CYAN}║  ${GREEN}[1]${NC} Install Playit.gg                                     ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${GREEN}[2]${NC} Start Playit.gg tunnel                                ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${GREEN}[3]${NC} Stop Playit.gg tunnel                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${GREEN}[4]${NC} Restart Playit.gg tunnel                              ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${GREEN}[5]${NC} View active tunnels                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${GREEN}[6]${NC} Get claim URL / Manage account                        ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${GREEN}[7]${NC} Setup new tunnels                                     ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${GREEN}[8]${NC} View Playit.gg logs                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${RED}[9]${NC} Uninstall Playit.gg                                     ${CYAN}║${NC}"
    echo -e "${CYAN}║  ${GREEN}[0]${NC} Back to main menu                                     ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

start_playit() {
    if ! command -v playit &> /dev/null; then
        echo -e "${RED}✗ Playit.gg is not installed${NC}"
        echo "  Use option [1] to install it first"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    echo -e "${GREEN}Starting Playit.gg tunnel...${NC}"
    echo ""

    if pgrep -x "playit" > /dev/null; then
        echo -e "${YELLOW}✓ Playit.gg is already running${NC}"
        sleep 2
        return
    fi

    nohup playit start > "$SCRIPT_DIR/playit.log" 2>&1 &
    sleep 2

    if pgrep -x "playit" > /dev/null; then
        echo -e "${GREEN}✓ Playit.gg started successfully${NC}"
        echo ""
        echo "Active tunnels:"
        playit tunnels list 2>/dev/null | grep "=>" | head -4
    else
        echo -e "${RED}✗ Failed to start Playit.gg${NC}"
        echo "Check the logs with option [8]"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

stop_playit() {
    echo -e "${YELLOW}Stopping Playit.gg tunnel...${NC}"
    echo ""

    if ! pgrep -x "playit" > /dev/null; then
        echo -e "${YELLOW}ℹ Playit.gg is not running${NC}"
        sleep 2
        return
    fi

    pkill playit
    sleep 1

    if ! pgrep -x "playit" > /dev/null; then
        echo -e "${GREEN}✓ Playit.gg stopped${NC}"
    else
        echo -e "${RED}✗ Failed to stop Playit.gg${NC}"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

restart_playit() {
    echo -e "${YELLOW}Restarting Playit.gg tunnel...${NC}"
    echo ""

    if pgrep -x "playit" > /dev/null; then
        echo "Stopping Playit.gg..."
        pkill playit
        sleep 1
    fi

    echo "Starting Playit.gg..."
    nohup playit start > "$SCRIPT_DIR/playit.log" 2>&1 &
    sleep 2

    if pgrep -x "playit" > /dev/null; then
        echo -e "${GREEN}✓ Playit.gg restarted successfully${NC}"
        echo ""
        echo "Active tunnels:"
        playit tunnels list 2>/dev/null | grep "=>" | head -4
    else
        echo -e "${RED}✗ Failed to restart Playit.gg${NC}"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

view_tunnels() {
    show_header
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                              ${YELLOW}ACTIVE TUNNELS${CYAN}                                   ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if ! pgrep -x "playit" > /dev/null; then
        echo -e "${YELLOW}⚠ Playit.gg is not running${NC}"
        echo ""
        echo "Start Playit.gg first to view tunnels."
    else
        playit tunnels list 2>/dev/null || echo -e "${RED}Failed to retrieve tunnel list${NC}"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

get_claim_url() {
    show_header
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                      ${YELLOW}PLAYIT.GG ACCOUNT MANAGEMENT${CYAN}                            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Try to get account info
    echo -e "${BLUE}Retrieving account information...${NC}"
    echo ""

    # Check if playit has account command
    ACCOUNT_INFO=$(playit account 2>&1)

    if echo "$ACCOUNT_INFO" | grep -q "claim"; then
        echo -e "${GREEN}Claim URL:${NC}"
        echo "$ACCOUNT_INFO" | grep -i "claim" || echo "$ACCOUNT_INFO"
    elif echo "$ACCOUNT_INFO" | grep -q "http"; then
        echo "$ACCOUNT_INFO"
    else
        # If no direct command, check the secret file
        SECRET_PATH=$(playit secret-path 2>/dev/null)

        if [ -n "$SECRET_PATH" ] && [ -f "$SECRET_PATH" ]; then
            echo -e "${GREEN}✓ Playit.gg is configured${NC}"
            echo ""
            echo "Secret file location: $SECRET_PATH"
            echo ""
            echo -e "${YELLOW}To manage your account:${NC}"
            echo "1. Visit: https://playit.gg/account"
            echo "2. Log in with the account you used during setup"
            echo ""
            echo -e "${YELLOW}To get a new claim URL:${NC}"
            echo "Run: playit setup"
        else
            echo -e "${YELLOW}No Playit.gg account found${NC}"
            echo ""
            echo "To set up Playit.gg, run: playit setup"
            echo "You'll receive a claim URL during setup"
        fi
    fi

    echo ""
    echo -e "${BLUE}Current tunnels:${NC}"
    if pgrep -x "playit" > /dev/null; then
        playit tunnels list 2>/dev/null | grep "=>" | head -4 || echo "No active tunnels"
    else
        echo "Playit.gg is not running"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

setup_tunnels() {
    show_header
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                         ${YELLOW}SETUP PLAYIT.GG TUNNELS${CYAN}                               ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${YELLOW}This will run the Playit.gg setup wizard.${NC}"
    echo ""
    echo "You'll need to:"
    echo "  1. Get a claim URL to activate your account"
    echo "  2. Create UDP tunnels for these ports:"
    echo "     - Port 16261 (Main server)"
    echo "     - Port 16262 (Secondary)"
    echo "     - Port 8766 (Steam 1)"
    echo "     - Port 8767 (Steam 2)"
    echo ""
    read -p "Continue with setup? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        return
    fi

    echo ""
    playit setup

    echo ""
    read -p "Press Enter to continue..."
}

view_logs() {
    show_header
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                             ${YELLOW}PLAYIT.GG LOGS${CYAN}                                   ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ -f "$SCRIPT_DIR/playit.log" ]; then
        echo -e "${YELLOW}Showing last 50 lines (Press 'q' to exit)${NC}"
        echo ""
        sleep 1
        tail -50 "$SCRIPT_DIR/playit.log" | less
    else
        echo -e "${YELLOW}No log file found${NC}"
        echo ""
        echo "Log location: $SCRIPT_DIR/playit.log"
        echo "The log file will be created when Playit.gg starts"
        echo ""
        read -p "Press Enter to continue..."
    fi
}

# Main execution
while true; do
    show_header
    show_menu
    read -p "Choose option [0-9]: " choice
    echo ""

    case $choice in
        1)
            install_playit
            ;;
        2)
            start_playit
            ;;
        3)
            stop_playit
            ;;
        4)
            restart_playit
            ;;
        5)
            view_tunnels
            ;;
        6)
            get_claim_url
            ;;
        7)
            setup_tunnels
            ;;
        8)
            view_logs
            ;;
        9)
            uninstall_playit
            ;;
        0)
            clear
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please choose 0-9.${NC}"
            sleep 2
            ;;
    esac
done
