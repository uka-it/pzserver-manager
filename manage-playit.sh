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
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}║                        ${YELLOW}PLAYIT.GG TUNNEL MANAGER${CYAN}                               ║${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

check_playit_installed() {
    if ! command -v playit &> /dev/null; then
        echo -e "${RED}✗ Playit.gg is not installed${NC}"
        echo ""
        echo "To install Playit.gg:"
        echo "  curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null"
        echo "  echo \"deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./ \" | sudo tee /etc/apt/sources.list.d/playit-cloud.list"
        echo "  sudo apt update"
        echo "  sudo apt install -y playit"
        echo ""
        read -p "Press Enter to exit..."
        exit 1
    fi
}

show_menu() {
    # Check status
    if pgrep -x "playit" > /dev/null; then
        STATUS="${GREEN}● RUNNING${NC}"
        PLAYIT_PID=$(pgrep -x "playit")
    else
        STATUS="${RED}● STOPPED${NC}"
        PLAYIT_PID="N/A"
    fi

    echo -e "${BLUE}Playit.gg Status:${NC} $STATUS"
    if [ "$PLAYIT_PID" != "N/A" ]; then
        echo -e "${BLUE}Process ID:${NC} $PLAYIT_PID"
    fi
    echo ""

    echo -e "${YELLOW}Options:${NC}"
    echo ""
    echo -e "  ${GREEN}[1]${NC} Start Playit.gg tunnel"
    echo -e "  ${GREEN}[2]${NC} Stop Playit.gg tunnel"
    echo -e "  ${GREEN}[3]${NC} Restart Playit.gg tunnel"
    echo -e "  ${GREEN}[4]${NC} View active tunnels"
    echo -e "  ${GREEN}[5]${NC} Get claim URL / Manage account"
    echo -e "  ${GREEN}[6]${NC} Setup new tunnels"
    echo -e "  ${GREEN}[7]${NC} View Playit.gg logs"
    echo -e "  ${GREEN}[8]${NC} Back to main menu"
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

start_playit() {
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
        echo "Check the logs with option [7]"
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
    clear
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}║                           ${YELLOW}ACTIVE TUNNELS${CYAN}                                     ║${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""

    if ! pgrep -x "playit" > /dev/null; then
        echo -e "${YELLOW}⚠ Playit.gg is not running${NC}"
        echo ""
        echo "Start Playit.gg first to view tunnels."
    else
        playit tunnels list 2>/dev/null || echo -e "${RED}Failed to retrieve tunnel list${NC}"
    fi

    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

get_claim_url() {
    clear
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}║                      ${YELLOW}PLAYIT.GG ACCOUNT MANAGEMENT${CYAN}                            ║${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
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
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

setup_tunnels() {
    clear
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}║                         ${YELLOW}SETUP PLAYIT.GG TUNNELS${CYAN}                               ║${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
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
    clear
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}║                          ${YELLOW}PLAYIT.GG LOGS${CYAN}                                     ║${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
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
show_header
check_playit_installed

while true; do
    show_header
    show_menu
    read -p "Choose option [1-8]: " choice
    echo ""

    case $choice in
        1)
            start_playit
            ;;
        2)
            stop_playit
            ;;
        3)
            restart_playit
            ;;
        4)
            view_tunnels
            ;;
        5)
            get_claim_url
            ;;
        6)
            setup_tunnels
            ;;
        7)
            view_logs
            ;;
        8)
            clear
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please choose 1-8.${NC}"
            sleep 2
            ;;
    esac
done
