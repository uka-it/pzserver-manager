#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server - Backup Manager
# View, restore, and delete world backups
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

BACKUP_DIR="$INSTALL_DIR/backups"
SERVER_NAME="pzserver"

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
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                             ${YELLOW}BACKUP MANAGER${CYAN}                                    ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check if there are any backups
BACKUPS=("$BACKUP_DIR"/world-backup-*.tar.gz)
if [ ! -f "${BACKUPS[0]}" ]; then
    echo -e "${YELLOW}No backups found in $BACKUP_DIR${NC}"
    echo ""
    echo "Backups are created when you:"
    echo "  - Use ./reset-world.sh"
    echo "  - Use ./switch-branch.sh"
    echo "  - Manually create one with tar"
    exit 0
fi

# List all backups with details
echo -e "${YELLOW}Available Backups:${NC}"
echo ""

declare -a BACKUP_FILES
declare -a BACKUP_SIZES
declare -a BACKUP_DATES

INDEX=0
for backup in "${BACKUPS[@]}"; do
    if [ -f "$backup" ]; then
        BACKUP_FILES[$INDEX]="$backup"

        # Get file size
        SIZE=$(du -h "$backup" | cut -f1)
        BACKUP_SIZES[$INDEX]="$SIZE"

        # Extract date from filename (format: world-backup-YYYYMMDD-HHMMSS.tar.gz)
        FILENAME=$(basename "$backup")
        DATETIME=$(echo "$FILENAME" | sed 's/world-backup-\(.*\)\.tar\.gz/\1/')

        # Format date nicely
        if [[ "$DATETIME" =~ ^([0-9]{8})-([0-9]{6})$ ]]; then
            DATE_PART="${BASH_REMATCH[1]}"
            TIME_PART="${BASH_REMATCH[2]}"

            YEAR="${DATE_PART:0:4}"
            MONTH="${DATE_PART:4:2}"
            DAY="${DATE_PART:6:2}"
            HOUR="${TIME_PART:0:2}"
            MIN="${TIME_PART:2:2}"
            SEC="${TIME_PART:4:2}"

            FORMATTED_DATE="$YEAR-$MONTH-$DAY $HOUR:$MIN:$SEC"
        else
            FORMATTED_DATE="$DATETIME"
        fi

        BACKUP_DATES[$INDEX]="$FORMATTED_DATE"

        NUM=$((INDEX + 1))
        echo "$NUM. $FORMATTED_DATE [$SIZE]"
        echo "   $backup"
        echo ""

        INDEX=$((INDEX + 1))
    fi
done

CANCEL_NUM=$((INDEX + 1))
echo "$CANCEL_NUM. Cancel"
echo ""

# Select a backup
read -p "Select backup to manage (1-$CANCEL_NUM): " choice

# Validate choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$CANCEL_NUM" ]; then
    echo "Invalid choice."
    exit 1
fi

if [ "$choice" -eq "$CANCEL_NUM" ]; then
    echo "Cancelled."
    exit 0
fi

# Get selected backup
SELECTED_INDEX=$((choice - 1))
SELECTED_BACKUP="${BACKUP_FILES[$SELECTED_INDEX]}"
SELECTED_SIZE="${BACKUP_SIZES[$SELECTED_INDEX]}"
SELECTED_DATE="${BACKUP_DATES[$SELECTED_INDEX]}"

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Selected Backup:${NC}"
echo -e "  ${BLUE}Date:${NC} $SELECTED_DATE"
echo -e "  ${BLUE}Size:${NC} $SELECTED_SIZE"
echo -e "  ${BLUE}File:${NC} $SELECTED_BACKUP"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}What would you like to do?${NC}"
echo ""
echo -e "  ${GREEN}[1]${NC} Restore this backup (replaces current world)"
echo -e "  ${GREEN}[2]${NC} Delete this backup"
echo -e "  ${GREEN}[3]${NC} View backup contents (list files)"
echo -e "  ${GREEN}[4]${NC} Cancel"
echo ""
read -p "Choose action (1-4): " action

case $action in
    1)
        # Restore backup
        echo ""
        echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}RESTORE BACKUP${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${RED}⚠ WARNING: This will REPLACE your current world!${NC}"
        echo ""
        echo "Current world will be deleted and replaced with:"
        echo "  Backup from: $SELECTED_DATE"
        echo ""

        # Check if server is running
        if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
            echo "⚠ Server is currently running!"
            echo ""
            read -p "Stop server and continue? (yes/no): " stop_confirm
            if [ "$stop_confirm" != "yes" ]; then
                echo "Cancelled."
                exit 0
            fi
            echo ""
            echo "Stopping server..."
            "$SCRIPT_DIR/stop-all.sh"
            sleep 3
        fi

        echo ""
        read -p "Type 'RESTORE' to confirm: " restore_confirm

        if [ "$restore_confirm" != "RESTORE" ]; then
            echo "Cancelled."
            exit 0
        fi

        echo ""
        echo "Backing up current world before restore..."
        SAFETY_BACKUP="$BACKUP_DIR/pre-restore-backup-$(date +%Y%m%d-%H%M%S).tar.gz"

        tar -czf "$SAFETY_BACKUP" \
            $ZOMBOID_DIR/Saves/Multiplayer/pzserver/ \
            $ZOMBOID_DIR/db/pzserver.db \
            2>/dev/null

        if [ -f "$SAFETY_BACKUP" ]; then
            SAFETY_SIZE=$(du -h "$SAFETY_BACKUP" | cut -f1)
            echo "✓ Safety backup created: $SAFETY_SIZE"
        fi

        echo ""
        echo "Deleting current world..."
        rm -rf $ZOMBOID_DIR/Saves/Multiplayer/pzserver/
        rm -f $ZOMBOID_DIR/db/pzserver.db
        echo "✓ Current world and player database deleted"

        echo ""
        echo "Restoring backup..."
        tar -xzf "$SELECTED_BACKUP" -C / 2>/dev/null

        if [ $? -eq 0 ]; then
            echo "✓ Backup restored successfully!"
            echo ""
            echo "=================================================="
            echo "✓ World Restored from $SELECTED_DATE"
            echo "=================================================="
            echo ""
            echo "Your world has been restored to the backed up state."
            echo ""
            echo "To start the server:"
            echo "  ./start-all.sh"
            echo ""
            echo "A safety backup of your previous world was saved:"
            echo "  $SAFETY_BACKUP"
            echo "=================================================="
        else
            echo ""
            echo "✗ Restore failed!"
            echo ""
            echo "Your safety backup is at:"
            echo "  $SAFETY_BACKUP"
            exit 1
        fi
        ;;

    2)
        # Delete backup
        echo ""
        echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}DELETE BACKUP${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${RED}⚠ WARNING: This will permanently delete the backup!${NC}"
        echo ""
        echo "  Date: $SELECTED_DATE"
        echo "  Size: $SELECTED_SIZE"
        echo ""
        read -p "Type 'DELETE' to confirm: " delete_confirm

        if [ "$delete_confirm" != "DELETE" ]; then
            echo "Cancelled."
            exit 0
        fi

        rm -f "$SELECTED_BACKUP"

        if [ $? -eq 0 ]; then
            echo ""
            echo "✓ Backup deleted successfully!"
            echo "  Freed: $SELECTED_SIZE"
        else
            echo ""
            echo "✗ Failed to delete backup!"
            exit 1
        fi
        ;;

    3)
        # View contents
        echo ""
        echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}BACKUP CONTENTS${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        tar -tzf "$SELECTED_BACKUP" 2>/dev/null | head -50
        echo ""
        echo "... (showing first 50 entries)"
        echo ""
        TOTAL_FILES=$(tar -tzf "$SELECTED_BACKUP" 2>/dev/null | wc -l)
        echo "Total files in backup: $TOTAL_FILES"
        ;;

    4)
        echo "Cancelled."
        exit 0
        ;;

    *)
        echo "Invalid action."
        exit 1
        ;;
esac
