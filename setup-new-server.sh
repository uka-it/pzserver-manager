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
    echo -e "${GREEN}[1/5] Installing System Dependencies${NC}"
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
    echo -e "${GREEN}[2/5] Installing SteamCMD${NC}"
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
    echo -e "${GREEN}[3/5] Configuring Server Settings${NC}"
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
    echo -e "${GREEN}Configuration saved:${NC}"
    echo "  Server Name: $SERVER_NAME"
    echo "  Branch: $BRANCH_NAME"
    echo "  Max Players: $MAX_PLAYERS"
}

download_server() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}[4/5] Downloading Project Zomboid Server${NC}"
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

setup_playit() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}[5/5] Setting up Playit.gg Tunnel${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""

    read -p "Do you want to install Playit.gg for tunneling? (yes/no): " install_playit

    if [ "$install_playit" = "yes" ]; then
        if ! command -v playit &> /dev/null; then
            echo "Installing Playit.gg..."
            curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
            echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
            sudo apt update
            sudo apt install -y playit
            echo -e "${GREEN}✓ Playit.gg installed${NC}"
        else
            echo -e "${YELLOW}Playit.gg already installed${NC}"
        fi

        echo ""
        echo -e "${YELLOW}You'll need to set up Playit.gg tunnels:${NC}"
        echo ""
        echo "1. Run: playit setup"
        echo "2. Create tunnels for these ports:"
        echo "   - Port 16261 (UDP) - Main server port"
        echo "   - Port 16262 (UDP) - Secondary port"
        echo "   - Port 8766 (UDP) - Steam port 1"
        echo "   - Port 8767 (UDP) - Steam port 2"
        echo ""
        read -p "Press Enter to continue..."
    else
        echo -e "${YELLOW}Skipping Playit.gg installation${NC}"
    fi
}

create_server_config() {
    echo ""
    echo "Creating server configuration..."

    CONFIG_DIR="$HOME/.local/share/Zomboid/Server/pzserver"
    mkdir -p "$CONFIG_DIR"

    cat > "$CONFIG_DIR/pzserver.ini" << EOF
# Server Configuration
PublicName=$SERVER_NAME
PublicDescription=$SERVER_DESC
MaxPlayers=$MAX_PLAYERS
PVP=true
PauseEmpty=true
GlobalChat=true
ChatStreams=s,r,a,w,y,sh,f,all
Open=true
ServerWelcomeMessage=Welcome to $SERVER_NAME! Survive the apocalypse together.

# Ports
DefaultPort=16261
UDPPort=16262

# Admin
AdminPassword=$ADMIN_PASS

# Performance
MaxAccountsPerUser=0
AllowCoop=true
SleepAllowed=false
SleepNeeded=false

# Mods
Mods=
WorkshopItems=

# Map
Map=Muldraugh, KY

# Spawns
SpawnPoint=0,0,0
SpawnItems=

# Game Settings
HoursForLootRespawn=0
MaxItemsForLootRespawn=4
ConstructionPreventsLootRespawn=true
DropOffWhiteListItems=Base.Axe,Base.HandAxe,Base.WoodAxe
TrashDeleteAll=false
PVPMeleeDamageModifier=30.0
PVPFirearmDamageModifier=50.0
CarSpawnRate=3
ChanceHasGas=14
InitialGas=2
FuelStationGas=100
LockedCar=6
CarGeneralCondition=2
CarDamageOnImpact=3
DamageToPlayerFromHitByACar=1
TrafficJam=true
CarAlarm=2
PlayerRespawnWithSelf=false
PlayerRespawnWithOther=false
FastForwardMultiplier=40.0
DisableRadioStaff=false
DisableRadioAdmin=true
DisableRadioGM=true
DisableRadioOverseer=false
DisableRadioModerator=false
DisableRadioInvisible=true
ClientCommandFilter=- vehicle.* +vehicle.installPart +vehicle.uninstallPart
ClientActionLogs=ISEnterVehicle,ISExitVehicle,ISTakeEngineParts;
PerksLognumber=3
BloodSplatLifespanDays=0
AllowDestructionBySledgehammer=true
SledgehammerOnlyInSafehouse=false
KickFastPlayers=false
ServerPlayerID=1061109567
RCONPort=27015
RCONPassword=changeme456
DiscordEnable=false
DiscordToken=
DiscordChannel=
DiscordChannelID=
server_browser_announced_ip=
Steam1=8766
Steam2=8767
SteamScoreboard=true
SteamVAC=true
UPnP=true
VoiceEnable=true
VoiceMinDistance=10.0
VoiceMaxDistance=100.0
Voice3D=true
SpeedLimit=70.0
LoginQueueEnabled=false
LoginQueueConnectTimeout=60
Server=pzserver
SteamPort1=$((16261 + 1))
SteamPort2=$((16261 + 2))
EOF

    echo -e "${GREEN}✓ Server configuration created${NC}"
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
    echo "   Choose option [1] to start"
    echo ""
    echo -e "${YELLOW}2. Configure Playit.gg tunnels (if installed):${NC}"
    echo "   playit setup"
    echo "   Create UDP tunnels for ports: 16261, 16262, 8766, 8767"
    echo ""
    echo -e "${YELLOW}3. Admin Password:${NC}"
    echo "   Password: $ADMIN_PASS"
    echo "   (Change in: ~/.local/share/Zomboid/Server/pzserver/pzserver.ini)"
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
    setup_playit
    show_completion
}

main
