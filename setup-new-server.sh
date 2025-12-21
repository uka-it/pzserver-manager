#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server - Automated Setup & Installation
# Installs all dependencies and configures a fresh server
###############################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
CRT_GREEN='\033[1;92m'
NC='\033[0m'

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

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
    echo -e "${CRT_GREEN}"
    cat << 'EOF'
                         ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄   ▄▄ ▄▄▄▄▄▄▄
                        █       █       █       █  █ █  █       █
                        █  ▄▄▄▄▄█    ▄▄▄█_     _█  █ █  █    ▄  █
                        █ █▄▄▄▄▄█   █▄▄▄  █   █ █  █▄█  █   █▄█ █
                        █▄▄▄▄▄  █    ▄▄▄█ █   █ █       █    ▄▄▄█
                         ▄▄▄▄▄█ █   █▄▄▄  █   █ █       █   █
                        █▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█ █▄▄▄█ █▄▄▄▄▄▄▄█▄▄▄█
EOF
    echo -e "${NC}"
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}║                    ${YELLOW}AUTOMATED SERVER SETUP & INSTALLATION${CYAN}                     ║${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

check_existing() {
    echo -e "${YELLOW}Checking for existing installation...${NC}"
    echo ""

    if [ -f "$INSTALL_DIR/ProjectZomboid64" ]; then
        echo -e "${YELLOW}⚠ WARNING: Existing server installation detected!${NC}"
        echo ""
        echo "Installation directory: $INSTALL_DIR"
        echo ""
        read -p "This will overwrite the existing installation. Continue? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            echo -e "${RED}Setup cancelled.${NC}"
            exit 0
        fi
    fi
}

install_dependencies() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}[1/4] Installing System Dependencies${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}Please do not run this script as root!${NC}"
        exit 1
    fi

    # Install required packages
    echo "Installing required packages (lib32gcc-s1, curl)..."
    sudo apt update
    sudo apt install -y lib32gcc-s1 curl

    echo -e "${GREEN}✓ Dependencies installed${NC}"
}

install_steamcmd() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}[2/4] Installing SteamCMD${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""

    mkdir -p "$STEAMCMD_DIR"
    cd "$STEAMCMD_DIR"

    if [ ! -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
        echo "Downloading SteamCMD..."
        curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
        echo -e "${GREEN}✓ SteamCMD installed${NC}"
    else
        echo -e "${YELLOW}SteamCMD already installed${NC}"
    fi
}

configure_server() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}[3/4] Configuring Server Settings${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Get server configuration from user
    read -p "Enter server name (press Enter for 'My PZ Server'): " SERVER_NAME
    if [ -z "$SERVER_NAME" ]; then
        SERVER_NAME="My PZ Server"
    fi

    read -p "Enter server description (press Enter for default): " SERVER_DESC
    if [ -z "$SERVER_DESC" ]; then
        SERVER_DESC="A Project Zomboid Dedicated Server - Welcome Survivors!"
    fi

    read -p "Enter admin password (press Enter for 'changeme123'): " ADMIN_PASS
    if [ -z "$ADMIN_PASS" ]; then
        ADMIN_PASS="changeme123"
    fi

    read -p "Enter max players (press Enter for '32'): " MAX_PLAYERS
    if [ -z "$MAX_PLAYERS" ]; then
        MAX_PLAYERS=32
    fi

    echo ""
    echo -e "${CYAN}Port Configuration:${NC}"

    read -p "Enter game port (press Enter for '16261'): " DEFAULT_PORT
    if [ -z "$DEFAULT_PORT" ]; then
        DEFAULT_PORT=16261
    fi
    UDP_PORT=$((DEFAULT_PORT + 1))

    read -p "Enter Steam port 1 (press Enter for '8766'): " STEAM_PORT1
    if [ -z "$STEAM_PORT1" ]; then
        STEAM_PORT1=8766
    fi
    STEAM_PORT2=$((STEAM_PORT1 + 1))

    echo ""
    echo -e "${GREEN}Port Configuration:${NC}"
    echo "  Game Port: $DEFAULT_PORT"
    echo "  UDP Port: $UDP_PORT (Game Port + 1)"
    echo "  Steam Port 1: $STEAM_PORT1"
    echo "  Steam Port 2: $STEAM_PORT2 (Steam Port 1 + 1)"

    echo ""
    echo -e "${YELLOW}Querying Steam for available branches...${NC}"
    echo ""

    # Query Steam and extract branch info
    TEMP_FILE=$(mktemp)
    "$STEAMCMD_DIR/steamcmd.sh" +login anonymous +app_info_update 1 +app_info_print 380870 +quit > "$TEMP_FILE" 2>&1

    # Extract branches section
    BRANCHES_DATA=$(sed -n '/"branches"/,/"privatebranches"/p' "$TEMP_FILE")

    # Parse branch names
    declare -a BRANCHES
    declare -a DESCRIPTIONS

    # Extract each branch
    while read -r line; do
        if echo "$line" | grep -q '^\s*"[^"]*"\s*$'; then
            BRANCH=$(echo "$line" | sed 's/^\s*"\([^"]*\)"\s*$/\1/')

            # Skip metadata fields
            if [[ "$BRANCH" == "branches" || "$BRANCH" == "buildid" || "$BRANCH" == "timeupdated" || "$BRANCH" == "description" || "$BRANCH" == "pwdrequired" ]]; then
                continue
            fi

            # Look for description
            DESC="$BRANCH"
            SEARCH_START=$(grep -n "\"$BRANCH\"" "$TEMP_FILE" | head -1 | cut -d: -f1)
            if [ -n "$SEARCH_START" ]; then
                SEARCH_END=$((SEARCH_START + 10))
                DESC_LINE=$(sed -n "${SEARCH_START},${SEARCH_END}p" "$TEMP_FILE" | grep '"description"' | head -1)
                if [ -n "$DESC_LINE" ]; then
                    DESC=$(echo "$DESC_LINE" | sed 's/.*"description"\s*"\([^"]*\)".*/\1/')
                fi
            fi

            BRANCHES+=("$BRANCH")
            DESCRIPTIONS+=("$DESC")
        fi
    done <<< "$BRANCHES_DATA"

    rm -f "$TEMP_FILE"

    if [ ${#BRANCHES[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠ Could not query branches, using defaults${NC}"
        BRANCHES=("public" "42.13.1" "unstable")
        DESCRIPTIONS=("STABLE (Build 41)" "Build 42.13.1" "UNSTABLE")
    fi

    # Display branches
    echo "Choose game branch:"
    echo ""

    for i in "${!BRANCHES[@]}"; do
        BRANCH="${BRANCHES[$i]}"
        DESC="${DESCRIPTIONS[$i]}"
        NUM=$((i + 1))

        # Add helpful labels for known branches
        if [ "$BRANCH" = "public" ]; then
            echo -e "  ${GREEN}[$NUM]${NC} STABLE (Build 41) - Recommended"
        elif [ "$BRANCH" = "42.13.1" ]; then
            echo -e "  ${GREEN}[$NUM]${NC} Build 42.13.1 - Stable Build 42"
        elif [ "$BRANCH" = "unstable" ]; then
            echo -e "  ${GREEN}[$NUM]${NC} UNSTABLE - Latest experimental"
        else
            echo -e "  ${GREEN}[$NUM]${NC} $BRANCH"
            if [ "$DESC" != "$BRANCH" ]; then
                echo "       $DESC"
            fi
        fi
    done

    echo ""
    read -p "Choose [1-${#BRANCHES[@]}]: " BRANCH_CHOICE

    # Validate choice
    if ! [[ "$BRANCH_CHOICE" =~ ^[0-9]+$ ]] || [ "$BRANCH_CHOICE" -lt 1 ] || [ "$BRANCH_CHOICE" -gt "${#BRANCHES[@]}" ]; then
        echo -e "${YELLOW}Invalid choice, defaulting to STABLE${NC}"
        BRANCH_CHOICE=1
    fi

    # Get selected branch
    SELECTED_BRANCH="${BRANCHES[$((BRANCH_CHOICE - 1))]}"

    if [ "$SELECTED_BRANCH" = "public" ]; then
        BETA_OPTION=""
        BRANCH_NAME="STABLE (Build 41)"
    else
        BETA_OPTION="-beta $SELECTED_BRANCH"
        BRANCH_NAME="$SELECTED_BRANCH"
    fi

    echo ""
    echo -e "${GREEN}Saving configuration to .env file...${NC}"

    # Write .env file to persist user configuration
    cat > "$SCRIPT_DIR/.env" << EOF
# Project Zomboid Server Configuration
# Generated by setup script on $(date)

# Server Configuration
SERVER_NAME="$SERVER_NAME"
SERVER_DESCRIPTION="$SERVER_DESC"
ADMIN_PASSWORD="$ADMIN_PASS"
MAX_PLAYERS=$MAX_PLAYERS

# Installation Directory
INSTALL_DIR="$INSTALL_DIR"
STEAMCMD_DIR="$STEAMCMD_DIR"

# Ports
DEFAULT_PORT=$DEFAULT_PORT
UDP_PORT=$UDP_PORT
STEAM_PORT1=$STEAM_PORT1
STEAM_PORT2=$STEAM_PORT2
RCON_PORT=27015

# Network (optional - for status display)
PUBLIC_DOMAIN=""
PUBLIC_IPV6=""
PLAYIT_TUNNEL=""

# Playit.gg Configuration
PLAYIT_ENABLED=true
EOF

    echo -e "${GREEN}✓ Configuration saved to .env${NC}"
    echo ""
    echo -e "${CYAN}Configuration Summary:${NC}"
    echo "  Server Name: $SERVER_NAME"
    echo "  Admin Password: $ADMIN_PASS"
    echo "  Max Players: $MAX_PLAYERS"
    echo "  Game Port: $DEFAULT_PORT"
    echo "  Steam Ports: $STEAM_PORT1, $STEAM_PORT2"
    echo "  Branch: $BRANCH_NAME"
}

download_server() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}[4/4] Downloading Project Zomboid Server${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Branch: $BRANCH_NAME"
    echo "This may take several minutes depending on your connection..."
    echo ""

    "$STEAMCMD_DIR/steamcmd.sh" \
        +force_install_dir "$INSTALL_DIR" \
        +login anonymous \
        +app_update 380870 $BETA_OPTION validate \
        +quit

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ Server files downloaded successfully${NC}"
    else
        echo ""
        echo -e "${RED}✗ Failed to download server files${NC}"
        exit 1
    fi
}

create_server_config() {
    echo ""
    echo "Creating minimal server configuration..."

    CONFIG_DIR="$ZOMBOID_DIR/Server"
    mkdir -p "$CONFIG_DIR"

    echo "  Creating: $CONFIG_DIR/pzserver.ini"

    cat > "$CONFIG_DIR/pzserver.ini" << EOF
# Minimal Server Configuration
# The server will fill in remaining options with defaults

PublicName=$SERVER_NAME
PublicDescription=$SERVER_DESC
MaxPlayers=$MAX_PLAYERS
ServerWelcomeMessage=Welcome to $SERVER_NAME! Survive the apocalypse together.
DefaultPort=$DEFAULT_PORT
UDPPort=$UDP_PORT
EOF

    echo ""

    # Verify the config was created
    if [ -f "$CONFIG_DIR/pzserver.ini" ]; then
        echo -e "${GREEN}✓ Minimal server configuration created${NC}"
        echo "  Config Location: $CONFIG_DIR/pzserver.ini"
        echo "  Admin password will be set via command-line on first start"
    else
        echo -e "${RED}✗ Failed to create config file${NC}"
        echo "  Expected at: $CONFIG_DIR/pzserver.ini"
    fi
}

create_management_scripts() {
    echo ""
    echo "Creating management scripts..."

    # Already exist, just make sure they're executable
    cd "$INSTALL_DIR"
    chmod +x *.sh 2>/dev/null

    echo -e "${GREEN}✓ Management scripts ready${NC}"
}

show_completion() {
    clear
    show_header

    echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}║                         ✓ INSTALLATION COMPLETE!                              ║${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Server Details:${NC}"
    echo "  Name: $SERVER_NAME"
    echo "  Branch: $BRANCH_NAME"
    echo "  Location: $INSTALL_DIR"
    echo "  Max Players: $MAX_PLAYERS"
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo ""
    echo -e "${YELLOW}1. Start the server:${NC}"
    echo "   cd $INSTALL_DIR"
    echo "   ./server-manager.sh"
    echo "   Choose option [1] to start server"
    echo ""
    echo -e "${YELLOW}2. (Optional) Setup Playit.gg tunneling:${NC}"
    echo "   In server manager, choose option [5]"
    echo "   Install and configure tunnels for ports: $DEFAULT_PORT, $UDP_PORT, $STEAM_PORT1, $STEAM_PORT2"
    echo ""
    echo -e "${YELLOW}3. Admin Password:${NC}"
    echo "   Password: $ADMIN_PASS"
    echo "   (Saved in: .env file, will be removed after first start)"
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    read -p "Press Enter to exit..."
}

# Main execution
main() {
    show_header
    check_existing
    install_dependencies
    install_steamcmd
    configure_server
    download_server
    create_server_config
    create_management_scripts
    show_completion
}

main
