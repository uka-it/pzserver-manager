#!/usr/bin/env bash
###############################################################################
# Edit Project Zomboid Server Configuration Files
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Colors
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

source "$SCRIPT_DIR/lib/ui-box.sh"

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

edit_file() {
    local file_path="$1"
    local file_name="$2"

    # Check if file exists
    if [ ! -f "$file_path" ]; then
        echo ""
        echo -e "${YELLOW}⚠ File not found: $file_path${NC}"
        echo ""
        echo "This file is created when the server runs for the first time."
        echo "Start the server at least once to generate this file."
        echo ""
        read -p "Press Enter to return to menu..."
        return
    fi

    # Check if server is running
    if pgrep -f "$PZ_PROCESS_PATTERN" > /dev/null; then
        echo ""
        echo -e "${YELLOW}⚠ WARNING: Server is currently running!${NC}"
        echo ""
        echo "It's recommended to stop the server before editing config files."
        echo "Changes may not take effect until the server is restarted."
        echo ""
        read -p "Continue anyway? (yes/no): " continue_confirm
        if [ "$continue_confirm" != "yes" ]; then
            echo "Cancelled."
            return
        fi
        echo ""
    fi

    # Create backup before editing
    BACKUP_FILE="${file_path}.backup-$(date +%Y%m%d-%H%M%S)"
    cp "$file_path" "$BACKUP_FILE"
    echo -e "${GREEN}✓ Backup created: $BACKUP_FILE${NC}"
    echo ""
    echo "Opening $file_name in nano..."
    echo "Press Ctrl+X to exit, Y to save changes, N to discard"
    echo ""
    sleep 2

    # Open in nano
    nano "$file_path"

    # Check if file was modified
    if ! cmp -s "$file_path" "$BACKUP_FILE"; then
        echo ""
        echo -e "${GREEN}✓ Changes saved to $file_name${NC}"
        echo ""
        if pgrep -f "$PZ_PROCESS_PATTERN" > /dev/null; then
            echo -e "${YELLOW}⚠ Server is running. Restart the server for changes to take effect.${NC}"
        else
            echo -e "${BLUE}ℹ Restart the server for changes to take effect.${NC}"
        fi
        echo ""
        echo "Backup saved at:"
        echo "  $BACKUP_FILE"
    else
        echo ""
        echo "No changes made."
        rm -f "$BACKUP_FILE"
    fi

    echo ""
    read -p "Press Enter to return to menu..."
}

# Main menu loop
while true; do
    show_header
    box_header "${YELLOW}EDIT SERVER CONFIGURATION${NC}"

    # Check if server config directory exists
    if [ ! -d "$SERVER_CONFIG_DIR" ]; then
        echo -e "${YELLOW}⚠ Server configuration directory not found${NC}"
        echo ""
        echo "Location: $SERVER_CONFIG_DIR"
        echo ""
        echo "The server needs to be run at least once to generate config files."
        echo "Run: ./start-all.sh"
        echo ""
        read -p "Press Enter to exit..."
        exit 0
    fi

    # Check which files exist
    CONFIG_EXISTS=""
    SANDBOX_EXISTS=""
    SPAWNPOINTS_EXISTS=""
    SPAWNREGIONS_EXISTS=""

    name="$PZ_SERVER_NAME"
    [ -f "$SERVER_CONFIG_DIR/$name.ini" ] && CONFIG_EXISTS="✓" || CONFIG_EXISTS="✗"
    [ -f "$SERVER_CONFIG_DIR/${name}_SandboxVars.lua" ] && SANDBOX_EXISTS="✓" || SANDBOX_EXISTS="✗"
    [ -f "$SERVER_CONFIG_DIR/${name}_spawnpoints.lua" ] && SPAWNPOINTS_EXISTS="✓" || SPAWNPOINTS_EXISTS="✗"
    [ -f "$SERVER_CONFIG_DIR/${name}_spawnregions.lua" ] && SPAWNREGIONS_EXISTS="✓" || SPAWNREGIONS_EXISTS="✗"

    # Pad labels to the longest one so the ✓/✗ column lines up for any server name
    label1="Server Configuration ($name.ini)"
    label2="Sandbox Variables (${name}_SandboxVars.lua)"
    label3="Spawn Points (${name}_spawnpoints.lua)"
    label4="Spawn Regions (${name}_spawnregions.lua)"
    label_width=${#label2}
    printf -v label1 "%-${label_width}s" "$label1"
    printf -v label2 "%-${label_width}s" "$label2"
    printf -v label3 "%-${label_width}s" "$label3"
    printf -v label4 "%-${label_width}s" "$label4"

    echo -e "${YELLOW}Select configuration file to edit:${NC}"
    echo ""
    box_top
    box_line "  ${GREEN}[1]${NC} $label1 $CONFIG_EXISTS"
    box_line "  ${GREEN}[2]${NC} $label2 $SANDBOX_EXISTS"
    box_line "  ${GREEN}[3]${NC} $label3 $SPAWNPOINTS_EXISTS"
    box_line "  ${GREEN}[4]${NC} $label4 $SPAWNREGIONS_EXISTS"
    box_mid
    box_line "  ${GREEN}[5]${NC} Exit"
    box_bottom
    echo ""
    echo -e "${CYAN}Config Directory:${NC} $SERVER_CONFIG_DIR"
    echo ""
    read -p "Choose option (1-5): " choice

    case $choice in
        1)
            edit_file "$SERVER_CONFIG_DIR/$PZ_SERVER_NAME.ini" "Server Configuration"
            ;;
        2)
            edit_file "$SERVER_CONFIG_DIR/${PZ_SERVER_NAME}_SandboxVars.lua" "Sandbox Variables"
            ;;
        3)
            edit_file "$SERVER_CONFIG_DIR/${PZ_SERVER_NAME}_spawnpoints.lua" "Spawn Points"
            ;;
        4)
            edit_file "$SERVER_CONFIG_DIR/${PZ_SERVER_NAME}_spawnregions.lua" "Spawn Regions"
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option."
            sleep 1
            ;;
    esac
done
