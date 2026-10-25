#!/usr/bin/env bash
###############################################################################
# Reset Project Zomboid World - Fresh Start
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

BACKUP_DIR="$INSTALL_DIR/backups"
SAVE_DIR="$PZ_SAVE_DIR"
DB_FILE="$PZ_DB_FILE"

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

show_header
box_header "${YELLOW}RESET WORLD TOOL${NC}"
echo -e "${RED}This will DELETE all world data and start fresh!${NC}"
echo ""

# Check if server is running
if pgrep -f "$PZ_PROCESS_PATTERN" > /dev/null; then
    echo "⚠ WARNING: Server is currently running!"
    echo ""
    read -p "Stop the server and continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Cancelled."
        exit 0
    fi
    echo "Stopping server..."
    if ! stop_pz_server; then
        echo "✗ Server did not stop - aborting to avoid damaging the save"
        exit 1
    fi
fi

# Check if world exists
if [ ! -d "$SAVE_DIR" ] && [ ! -f "$DB_FILE" ]; then
    echo "ℹ No world found. Nothing to reset."
    echo "The server will create a new world on next start."
    exit 0
fi

echo ""
read -p "Create backup before reset? (yes/no): " do_backup

if [ "$do_backup" = "yes" ]; then
    # Create backup
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/world-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    echo ""
    echo "Creating backup..."

    # Create tar with conditional files
    BACKUP_PATHS=""
    [ -d "$SAVE_DIR" ] && BACKUP_PATHS="$BACKUP_PATHS $SAVE_DIR"
    [ -f "$DB_FILE" ] && BACKUP_PATHS="$BACKUP_PATHS $DB_FILE"

    if [ -n "$BACKUP_PATHS" ]; then
        tar -czf "$BACKUP_FILE" $BACKUP_PATHS 2>/dev/null
    fi

    if [ -f "$BACKUP_FILE" ]; then
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo "✓ Backup created: $BACKUP_FILE ($SIZE)"
    else
        echo "✗ Backup failed!"
        exit 1
    fi
fi

echo ""
read -p "Are you SURE you want to DELETE the world? (type 'DELETE' to confirm): " final_confirm

if [ "$final_confirm" != "DELETE" ]; then
    echo "Cancelled. World preserved."
    exit 0
fi

# Delete world data
echo ""
echo "Deleting world data..."

if [ -d "$SAVE_DIR" ]; then
    rm -rf "$SAVE_DIR"
    echo "✓ Deleted: $SAVE_DIR"
fi

if [ -f "$DB_FILE" ]; then
    rm -f "$DB_FILE"
    echo "✓ Deleted: $DB_FILE (player database)"
fi

echo ""
box_top
box_line "${GREEN}✓ World Reset Complete!${NC}"
box_bottom
echo ""
echo "The server will create a fresh new world on next start."
echo ""
echo -e "${YELLOW}To start the server:${NC}"
echo "  ./start-all.sh"
echo ""

if [ "$do_backup" = "yes" ]; then
    echo -e "${BLUE}Your old world backup is saved at:${NC}"
    echo "  $BACKUP_FILE"
    echo ""
fi
