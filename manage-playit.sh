#!/usr/bin/env bash
###############################################################################
# Playit.gg Tunnel Manager
# Manage Playit.gg tunnel service
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Colors (REAL ESC bytes so printf renders colors correctly)
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

###############################################################################
# Box / Frame helpers (no more counting spaces)
###############################################################################
BOX_INNER=78 # width of content inside the frame (not counting the side padding spaces)

_repeat_char() {
    local n="$1"
    local ch="$2"
    local out=""
    local i
    for ((i=0; i<n; i++)); do
        out+="$ch"
    done
    printf "%s" "$out"
}

_strip_ansi() {
    # Strip ANSI escape sequences for length calculations
    # (This won't perfectly handle emoji/ambiguous-width glyphs, but fixes the "counting spaces" problem.)
    printf '%s' "$1" | sed -r $'s/\x1B\\[[0-9;]*[[:alpha:]]//g'
}

box_top() {
    printf "${CYAN}╔%s╗${NC}\n" "$(_repeat_char $((BOX_INNER + 2)) "═")"
}

box_mid() {
    printf "${CYAN}╠%s╣${NC}\n" "$(_repeat_char $((BOX_INNER + 2)) "═")"
}

box_bottom() {
    printf "${CYAN}╚%s╝${NC}\n" "$(_repeat_char $((BOX_INNER + 2)) "═")"
}

box_line() {
    local s="$1"
    local plain len pad
    plain="$(_strip_ansi "$s")"
    len=${#plain}
    pad=$((BOX_INNER - len))
    ((pad < 0)) && pad=0

    # Left border cyan, inside normal, right border cyan
    printf "${CYAN}║${NC} %s%*s ${CYAN}║${NC}\n" "$s" "$pad" ""
}

box_empty() {
    box_line ""
}

box_title_center() {
    local s="$1"
    local plain len left right
    plain="$(_strip_ansi "$s")"
    len=${#plain}

    if ((len >= BOX_INNER)); then
        # If too long, just print it (will spill but avoids weird negative padding)
        box_line "$s"
        return
    fi

    left=$(( (BOX_INNER - len) / 2 ))
    right=$(( BOX_INNER - len - left ))

    printf "${CYAN}║${NC} %*s%s%*s ${CYAN}║${NC}\n" "$left" "" "$s" "$right" ""
}

box_header() {
    local title="$1"
    box_top
    box_title_center "$title"
    box_bottom
    echo ""
}

###############################################################################
# UI
###############################################################################
show_header() {
    clear
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
    echo ""
}

install_playit() {
    show_header
    box_header "${YELLOW}INSTALL PLAYIT.GG${NC}"

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
    box_header "${YELLOW}UNINSTALL PLAYIT.GG${NC}"

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

    box_top
    box_title_center "${YELLOW}PLAYIT.GG TUNNEL MANAGER${NC}"
    box_mid
    box_empty

    box_line "  ${BLUE}Installation Status:${NC} $INSTALLED"
    if [ "$STATUS" != "N/A" ]; then
        box_line "  ${BLUE}Service Status:${NC}     $STATUS"
        if [ "$PLAYIT_PID" != "N/A" ]; then
            box_line "  ${BLUE}Process ID:${NC}         $PLAYIT_PID"
        fi
    fi

    box_empty
    box_mid
    box_empty

    box_line "  ${GREEN}[1]${NC} Install Playit.gg"
    box_line "  ${GREEN}[2]${NC} Start Playit.gg tunnel"
    box_line "  ${GREEN}[3]${NC} Stop Playit.gg tunnel"
    box_line "  ${GREEN}[4]${NC} Restart Playit.gg tunnel"
    box_line "  ${GREEN}[5]${NC} View active tunnels"
    box_line "  ${GREEN}[6]${NC} Get claim URL / Manage account"
    box_line "  ${GREEN}[7]${NC} Setup new tunnels"
    box_line "  ${GREEN}[8]${NC} View Playit.gg logs"
    box_line "  ${RED}[9]${NC} Uninstall Playit.gg"
    box_line "  ${GREEN}[0]${NC} Back to main menu"

    box_empty
    box_bottom
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
    box_header "${YELLOW}ACTIVE TUNNELS${NC}"

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
    box_header "${YELLOW}PLAYIT.GG ACCOUNT MANAGEMENT${NC}"

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
    box_header "${YELLOW}SETUP PLAYIT.GG TUNNELS${NC}"

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
    box_header "${YELLOW}PLAYIT.GG LOGS${NC}"

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

