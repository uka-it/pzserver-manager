#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server - Automated Setup & Installation
# Installs all dependencies and configures a fresh server
###############################################################################

# Colors
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
CRT_GREEN=$'\033[1;92m'
NC=$'\033[0m'

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/lib/ui-box.sh"

# Non-interactive mode (used by the Docker entrypoint): no prompts, values come
# from environment variables, branch comes from PZ_BRANCH (default: public)
PZ_NONINTERACTIVE="${PZ_NONINTERACTIVE:-0}"

show_header() {
    [ "$PZ_NONINTERACTIVE" = "1" ] || clear
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
    box_header "${YELLOW}AUTOMATED SERVER SETUP & INSTALLATION${NC}"
}

check_existing() {
    echo -e "${YELLOW}Checking for existing installation...${NC}"
    echo ""

    if [ -f "$INSTALL_DIR/ProjectZomboid64" ]; then
        echo -e "${YELLOW}⚠ WARNING: Existing server installation detected!${NC}"
        echo ""
        echo "Installation directory: $INSTALL_DIR"
        echo ""
        if [ "$PZ_NONINTERACTIVE" = "1" ]; then
            echo "Non-interactive mode: continuing"
            return
        fi
        read -p "This will overwrite the existing installation. Continue? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            echo -e "${RED}Setup cancelled.${NC}"
            exit 0
        fi
    fi
}

install_dependencies() {
    echo ""
    box_header "${GREEN}[1/4] Installing System Dependencies${NC}"

    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}Please do not run this script as root!${NC}"
        exit 1
    fi

    # Docker image ships with dependencies preinstalled
    if [ "$PZ_DOCKER" = "1" ]; then
        echo -e "${YELLOW}Running in Docker - dependencies already installed${NC}"
        return
    fi

    # Install required packages
    echo "Installing required packages (lib32gcc-s1, curl)..."
    sudo apt update
    sudo apt install -y lib32gcc-s1 curl

    echo -e "${GREEN}✓ Dependencies installed${NC}"
}

install_steamcmd() {
    echo ""
    box_header "${GREEN}[2/4] Installing SteamCMD${NC}"

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
    box_header "${GREEN}[3/4] Configuring Server Settings${NC}"

    # Check if .env file exists
    ENV_FILE="$SCRIPT_DIR/.env"
    USE_EXISTING_CONFIG=false

    if [ "$PZ_NONINTERACTIVE" = "1" ]; then
        configure_from_env
        return
    fi

    if [ -f "$ENV_FILE" ]; then
        echo -e "${YELLOW}Existing configuration found!${NC}"
        echo ""
        echo -e "${CYAN}Current .env file contents:${NC}"
        echo "────────────────────────────────────────────────"

        # Display .env contents (hide comments and empty lines)
        grep -v "^#" "$ENV_FILE" | grep -v "^$" | while read -r line; do
            echo "  $line"
        done

        echo "────────────────────────────────────────────────"
        echo ""
        read -p "Use these existing values? (yes/no): " use_existing

        if [ "$use_existing" = "yes" ]; then
            USE_EXISTING_CONFIG=true
            echo ""
            echo -e "${GREEN}✓ Using existing configuration${NC}"
            echo ""

            # Load values from .env
            source "$ENV_FILE"

            # Use loaded values
            SERVER_NAME="${SERVER_NAME:-My PZ Server}"
            SERVER_DESC="${SERVER_DESCRIPTION:-A Project Zomboid Dedicated Server - Welcome Survivors!}"
            ADMIN_PASS="${ADMIN_PASSWORD:-changeme123}"
            MAX_PLAYERS="${MAX_PLAYERS:-32}"
            SERVER_MEMORY="${SERVER_MEMORY:-$(get_recommended_memory)}"
            DEFAULT_PORT="${DEFAULT_PORT:-16261}"
            UDP_PORT="${UDP_PORT:-16262}"
            STEAM_PORT1="${STEAM_PORT1:-8766}"
            STEAM_PORT2="${STEAM_PORT2:-8767}"

            echo "Loaded configuration:"
            echo "  Server Name: $SERVER_NAME"
            echo "  Max Players: $MAX_PLAYERS"
            echo "  Server Memory: $SERVER_MEMORY"
            echo "  Game Port: $DEFAULT_PORT"
            echo "  Steam Ports: $STEAM_PORT1, $STEAM_PORT2"
            echo ""
        else
            echo ""
            echo -e "${YELLOW}Existing .env will be replaced with new configuration${NC}"
            echo ""
        fi
    fi

    # If not using existing config, ask for values
    if [ "$USE_EXISTING_CONFIG" = false ]; then
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
        echo -e "${CYAN}Memory Configuration:${NC}"
        prompt_server_memory
        SERVER_MEMORY="$CHOSEN_MEMORY"

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
    fi

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

    parse_steam_branches "$TEMP_FILE"
    rm -f "$TEMP_FILE"

    if [ ${#BRANCHES[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠ Could not query branches, using defaults${NC}"
        BRANCHES=("public" "unstable")
        DESCRIPTIONS=("" "Unstable")
    fi

    # Display branches
    echo "Choose game branch:"
    echo ""

    for i in "${!BRANCHES[@]}"; do
        BRANCH="${BRANCHES[$i]}"
        DESC="${DESCRIPTIONS[$i]}"
        NUM=$((i + 1))

        echo -e "  ${GREEN}[$NUM]${NC} $(branch_label "$BRANCH" "$DESC")"
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
        BRANCH_NAME="public"
    else
        BETA_OPTION="-beta $SELECTED_BRANCH"
        BRANCH_NAME="$SELECTED_BRANCH"
    fi

    save_configuration
}

save_configuration() {
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

# Server memory (JVM -Xmx), e.g. 6G or 6144M - applied on every start
SERVER_MEMORY="$SERVER_MEMORY"

# Internal server name (-servername): file names in ~/Zomboid use it
PZ_SERVER_NAME="$PZ_SERVER_NAME"

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
PLAYIT_ENABLED=$PLAYIT_ENABLED
EOF

    echo -e "${GREEN}✓ Configuration saved to .env${NC}"

    ADMIN_FLAG="$SCRIPT_DIR/.admin_created"
    if [ -f "$PZ_DB_FILE" ]; then
        # Existing world: the admin account already exists in its database
        touch "$ADMIN_FLAG"
        echo -e "${GREEN}✓ Existing player database found - keeping its admin account${NC}"
        echo "  (use 'Reset admin password' in the menu to change it)"
    elif [ -f "$ADMIN_FLAG" ]; then
        # Remove admin flag to ensure password is applied on first start
        rm -f "$ADMIN_FLAG"
        echo -e "${GREEN}✓ Removed admin flag${NC}"
    fi

    echo ""
    echo -e "${CYAN}Configuration Summary:${NC}"
    echo "  Server Name: $SERVER_NAME"
    echo "  Admin Password: $ADMIN_PASS"
    echo "  Max Players: $MAX_PLAYERS"
    echo "  Server Memory: $SERVER_MEMORY"
    echo "  Game Port: $DEFAULT_PORT"
    echo "  Steam Ports: $STEAM_PORT1, $STEAM_PORT2"
    echo "  Branch: $BRANCH_NAME"
}

# Non-interactive configuration from environment variables (Docker)
configure_from_env() {
    SERVER_DESC="$SERVER_DESCRIPTION"
    ADMIN_PASS="$ADMIN_PASSWORD"
    UDP_PORT=$((DEFAULT_PORT + 1))
    STEAM_PORT2=$((STEAM_PORT1 + 1))

    if [ -z "$SERVER_MEMORY" ]; then
        SERVER_MEMORY=$(get_recommended_memory)
    elif ! SERVER_MEMORY=$(normalize_memory "$SERVER_MEMORY"); then
        SERVER_MEMORY=$(get_recommended_memory)
        echo -e "${YELLOW}⚠ Invalid SERVER_MEMORY - using recommended $SERVER_MEMORY${NC}"
    fi

    SELECTED_BRANCH="${PZ_BRANCH:-public}"
    if [ "$SELECTED_BRANCH" = "public" ]; then
        BETA_OPTION=""
        BRANCH_NAME="public"
    else
        BETA_OPTION="-beta $SELECTED_BRANCH"
        BRANCH_NAME="$SELECTED_BRANCH"
    fi

    if [ "$ADMIN_PASS" = "changeme123" ]; then
        echo -e "${RED}⚠ WARNING: Using default admin password 'changeme123' - set ADMIN_PASSWORD!${NC}"
    fi

    save_configuration
}

download_server() {
    echo ""
    box_header "${GREEN}[4/4] Downloading Project Zomboid Server${NC}"
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
    mkdir -p "$SERVER_CONFIG_DIR"

    # Existing server: never replace its config
    if [ -f "$SERVER_CONFIG_FILE" ]; then
        echo "Existing server configuration found: $SERVER_CONFIG_FILE"
        if [ "$PZ_NONINTERACTIVE" = "1" ]; then
            echo -e "${GREEN}✓ Keeping existing configuration unchanged${NC}"
            return
        fi

        cp "$SERVER_CONFIG_FILE" "$SERVER_CONFIG_FILE.bak-$(date +%Y%m%d-%H%M%S)"
        set_ini_value "$SERVER_CONFIG_FILE" PublicName "$SERVER_NAME"
        set_ini_value "$SERVER_CONFIG_FILE" PublicDescription "$SERVER_DESC"
        set_ini_value "$SERVER_CONFIG_FILE" MaxPlayers "$MAX_PLAYERS"
        set_ini_value "$SERVER_CONFIG_FILE" DefaultPort "$DEFAULT_PORT"
        set_ini_value "$SERVER_CONFIG_FILE" UDPPort "$UDP_PORT"
        echo -e "${GREEN}✓ Updated name, description, max players and ports - all other settings kept${NC}"
        echo "  Backup of the previous file: $SERVER_CONFIG_FILE.bak-*"
        return
    fi

    echo "Creating minimal server configuration..."
    echo "  Creating: $SERVER_CONFIG_FILE"

    cat > "$SERVER_CONFIG_FILE" << EOF
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
    if [ -f "$SERVER_CONFIG_FILE" ]; then
        echo -e "${GREEN}✓ Minimal server configuration created${NC}"
        echo "  Config Location: $SERVER_CONFIG_FILE"
        echo "  Admin password will be set via command-line on first start"
    else
        echo -e "${RED}✗ Failed to create config file${NC}"
        echo "  Expected at: $SERVER_CONFIG_FILE"
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
    if [ "$PZ_NONINTERACTIVE" = "1" ]; then
        echo ""
        echo -e "${GREEN}✓ Installation complete (branch: $BRANCH_NAME)${NC}"
        return
    fi

    clear
    show_header

    box_header "${GREEN}✓ INSTALLATION COMPLETE!${NC}"
    echo -e "${CYAN}Server Details:${NC}"
    echo "  Name: $SERVER_NAME"
    echo "  Branch: $BRANCH_NAME"
    echo "  Location: $INSTALL_DIR"
    echo "  Max Players: $MAX_PLAYERS"
    echo "  Server Memory: $SERVER_MEMORY"
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
    box_top
    box_line "${GREEN}You're ready to run the server!${NC}"
    box_bottom
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
