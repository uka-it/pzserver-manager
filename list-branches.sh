#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server - Dynamic Branch Switcher
# Queries Steam for available branches and lets you choose
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

STEAMCMD="$STEAMCMD_DIR/steamcmd.sh"

show_header
box_header "${YELLOW}SWITCH GAME BRANCH${NC}"

# Check if server is running
if pgrep -f "$PZ_PROCESS_PATTERN" > /dev/null; then
    echo "⚠ Server is currently running!"
    echo ""
    read -p "Stop server and continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Cancelled."
        exit 0
    fi
    echo ""
    echo "Stopping server..."
    "$SCRIPT_DIR/stop-all.sh"
    sleep 3
fi

echo "Querying Steam for available branches..."
echo "This may take a moment..."
echo ""

# Query Steam and extract branch info
TEMP_FILE=$(mktemp)
"$STEAMCMD" +login anonymous +app_info_update 1 +app_info_print 380870 +quit > "$TEMP_FILE" 2>&1

parse_steam_branches "$TEMP_FILE"
rm -f "$TEMP_FILE"

if [ ${#BRANCHES[@]} -eq 0 ]; then
    echo "✗ Failed to retrieve branches from Steam!"
    echo "Please try again or use ./switch-branch.sh for manual selection."
    exit 1
fi

# Display branches
echo "Available Branches:"
echo ""

for i in "${!BRANCHES[@]}"; do
    BRANCH="${BRANCHES[$i]}"
    DESC="${DESCRIPTIONS[$i]}"
    NUM=$((i + 1))

    echo "$NUM. $(branch_label "$BRANCH" "$DESC")"
    echo ""
done

CANCEL_NUM=$((${#BRANCHES[@]} + 1))
echo "$CANCEL_NUM. Cancel"
echo ""

read -p "Choose branch (1-$CANCEL_NUM): " choice

# Validate choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$CANCEL_NUM" ]; then
    echo "Invalid choice."
    exit 1
fi

if [ "$choice" -eq "$CANCEL_NUM" ]; then
    echo "Cancelled."
    exit 0
fi

# Get selected branch
SELECTED_BRANCH="${BRANCHES[$((choice - 1))]}"

if [ "$SELECTED_BRANCH" = "public" ]; then
    BETA_OPTION=""
    BRANCH_NAME="public"
else
    BETA_OPTION="-beta $SELECTED_BRANCH"
    BRANCH_NAME="$SELECTED_BRANCH"
fi

echo ""
echo "=================================================="
echo "Switching to: $BRANCH_NAME"
echo "=================================================="
echo ""
echo "⚠ IMPORTANT WARNINGS:"
echo ""
echo "1. Switching branches may break world compatibility!"
echo "2. Your save may not work with the new branch!"
echo "3. Backup your world before switching!"
echo ""
read -p "Create backup before switching? (yes/no): " do_backup

if [ "$do_backup" = "yes" ]; then
    BACKUP_DIR="$INSTALL_DIR/backups"
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/world-backup-$(date +%Y%m%d-%H%M%S).tar.gz"

    echo ""
    echo "Creating backup..."
    tar -czf "$BACKUP_FILE" \
        "$PZ_SAVE_DIR"/ \
        "$PZ_DB_FILE" \
        2>/dev/null

    if [ -f "$BACKUP_FILE" ]; then
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo "✓ Backup created: $BACKUP_FILE ($SIZE)"
    else
        echo "✗ Backup failed!"
        read -p "Continue anyway? (yes/no): " continue_anyway
        if [ "$continue_anyway" != "yes" ]; then
            exit 1
        fi
    fi
fi

echo ""
read -p "Ready to switch to $BRANCH_NAME? (type 'SWITCH' to confirm): " final_confirm

if [ "$final_confirm" != "SWITCH" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "=================================================="
echo "Downloading $BRANCH_NAME from Steam..."
echo "=================================================="
echo ""
echo "This may take several minutes..."
echo ""

# Update to selected branch
"$STEAMCMD" \
    +force_install_dir "$INSTALL_DIR" \
    +login anonymous \
    +app_update 380870 $BETA_OPTION validate \
    +quit

if [ $? -eq 0 ]; then
    echo ""
    echo "=================================================="
    echo "✓ Successfully switched to $BRANCH_NAME!"
    echo "=================================================="
    echo ""
    echo "IMPORTANT: Test that the server starts correctly!"
    echo ""
    echo "To start the server:"
    echo "  ./start-all.sh"
    echo ""
    if [ "$do_backup" = "yes" ]; then
        echo "Your backup is saved at:"
        echo "  $BACKUP_FILE"
        echo ""
    fi
    echo "If the server doesn't start or world is broken:"
    echo "  ./reset-world.sh  (to start fresh world)"
    echo "=================================================="
else
    echo ""
    echo "✗ Failed to switch branches!"
    echo "Check the error messages above."
    exit 1
fi
