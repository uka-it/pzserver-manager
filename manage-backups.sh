#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server - Backup Manager
# View, restore, and delete world backups
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

create_backup() {
    clear
    show_header
    box_header "${YELLOW}CREATE NEW BACKUP${NC}"

    # Check if world exists
    SAVE_DIR="$ZOMBOID_DIR/Saves/Multiplayer/$SERVER_NAME"
    DB_FILE="$ZOMBOID_DIR/db/$SERVER_NAME.db"

    if [ ! -d "$SAVE_DIR" ] && [ ! -f "$DB_FILE" ]; then
        echo -e "${YELLOW}ℹ No world found. Nothing to backup.${NC}"
        echo ""
        echo "The server needs to be run at least once to create a world."
        echo ""
        read -p "Press Enter to return to menu..."
        return
    fi

    # Check if server is running
    if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
        echo -e "${YELLOW}⚠ WARNING: Server is currently running!${NC}"
        echo ""
        echo "It's recommended to stop the server before creating a backup"
        echo "to ensure data consistency."
        echo ""
        read -p "Continue anyway? (yes/no): " continue_confirm
        if [ "$continue_confirm" != "yes" ]; then
            echo "Cancelled."
            return
        fi
        echo ""
    fi

    # Create backup
    BACKUP_FILE="$BACKUP_DIR/world-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    echo -e "${YELLOW}Creating backup...${NC}"
    echo ""

    # Build paths to backup
    BACKUP_PATHS=""
    [ -d "$SAVE_DIR" ] && BACKUP_PATHS="$BACKUP_PATHS $SAVE_DIR"
    [ -f "$DB_FILE" ] && BACKUP_PATHS="$BACKUP_PATHS $DB_FILE"

    if [ -n "$BACKUP_PATHS" ]; then
        tar -czf "$BACKUP_FILE" $BACKUP_PATHS 2>/dev/null
    fi

    if [ -f "$BACKUP_FILE" ]; then
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo -e "${GREEN}✓ Backup created successfully!${NC}"
        echo ""
        box_top
        box_line "${YELLOW}Backup Details:${NC}"
        box_line "  ${BLUE}File:${NC} $BACKUP_FILE"
        box_line "  ${BLUE}Size:${NC} $SIZE"
        box_line "  ${BLUE}Date:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
        box_bottom
    else
        echo -e "${RED}✗ Backup failed!${NC}"
    fi

    echo ""
    read -p "Press Enter to return to menu..."
}

manage_existing_backups() {
    clear
    show_header
    box_header "${YELLOW}MANAGE EXISTING BACKUPS${NC}"

    # Check if there are any backups
    BACKUPS=("$BACKUP_DIR"/world-backup-*.tar.gz)
    if [ ! -f "${BACKUPS[0]}" ]; then
        echo -e "${YELLOW}No backups found in $BACKUP_DIR${NC}"
        echo ""
        echo "You can create a backup using option [1] from the main menu."
        echo ""
        read -p "Press Enter to return to menu..."
        return
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
        sleep 2
        return
    fi

    if [ "$choice" -eq "$CANCEL_NUM" ]; then
        return
    fi

    # Get selected backup
    SELECTED_INDEX=$((choice - 1))
    SELECTED_BACKUP="${BACKUP_FILES[$SELECTED_INDEX]}"
    SELECTED_SIZE="${BACKUP_SIZES[$SELECTED_INDEX]}"
    SELECTED_DATE="${BACKUP_DATES[$SELECTED_INDEX]}"

    echo ""
    box_top
    box_line "${YELLOW}Selected Backup:${NC}"
    box_line "  ${BLUE}Date:${NC} $SELECTED_DATE"
    box_line "  ${BLUE}Size:${NC} $SELECTED_SIZE"
    box_line "  ${BLUE}File:${NC} $SELECTED_BACKUP"
    box_bottom
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
            box_header "${YELLOW}RESTORE BACKUP${NC}"
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
                    sleep 2
                    return
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
                sleep 2
                return
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
                box_top
                box_line "${GREEN}✓ World Restored from $SELECTED_DATE${NC}"
                box_bottom
                echo ""
                echo "Your world has been restored to the backed up state."
                echo ""
                echo "To start the server:"
                echo "  ./start-all.sh"
                echo ""
                box_top
                box_line "${BLUE}Safety backup saved:${NC}"
                box_line "  $SAFETY_BACKUP"
                box_bottom
            else
                echo ""
                echo "✗ Restore failed!"
                echo ""
                echo "Your safety backup is at:"
                echo "  $SAFETY_BACKUP"
            fi

            echo ""
            read -p "Press Enter to return to menu..."
            ;;

        2)
            # Delete backup
            echo ""
            box_header "${YELLOW}DELETE BACKUP${NC}"
            echo -e "${RED}⚠ WARNING: This will permanently delete the backup!${NC}"
            echo ""
            echo "  Date: $SELECTED_DATE"
            echo "  Size: $SELECTED_SIZE"
            echo ""
            read -p "Type 'DELETE' to confirm: " delete_confirm

            if [ "$delete_confirm" != "DELETE" ]; then
                echo "Cancelled."
                sleep 2
                return
            fi

            rm -f "$SELECTED_BACKUP"

            if [ $? -eq 0 ]; then
                echo ""
                echo "✓ Backup deleted successfully!"
                echo "  Freed: $SELECTED_SIZE"
            else
                echo ""
                echo "✗ Failed to delete backup!"
            fi

            echo ""
            read -p "Press Enter to return to menu..."
            ;;

        3)
            # View contents
            echo ""
            box_header "${YELLOW}BACKUP CONTENTS${NC}"
            tar -tzf "$SELECTED_BACKUP" 2>/dev/null | head -50
            echo ""
            echo "... (showing first 50 entries)"
            echo ""
            TOTAL_FILES=$(tar -tzf "$SELECTED_BACKUP" 2>/dev/null | wc -l)
            echo "Total files in backup: $TOTAL_FILES"

            echo ""
            read -p "Press Enter to return to menu..."
            ;;

        4)
            return
            ;;

        *)
            echo "Invalid action."
            sleep 2
            return
            ;;
    esac
}

# Main menu loop
while true; do
    show_header
    box_header "${YELLOW}BACKUP MANAGER${NC}"

    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"

    # Count existing backups
    BACKUPS=("$BACKUP_DIR"/world-backup-*.tar.gz)
    if [ -f "${BACKUPS[0]}" ]; then
        BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/world-backup-*.tar.gz 2>/dev/null | wc -l)
        TOTAL_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)

        box_top
        box_line "${CYAN}Current Backups:${NC} $BACKUP_COUNT"
        box_line "${CYAN}Total Size:${NC}     $TOTAL_SIZE"
        box_bottom
        echo ""
    else
        echo -e "${YELLOW}No backups found${NC}"
        echo ""
    fi

    echo -e "${YELLOW}What would you like to do?${NC}"
    echo ""
    box_top
    box_line "  ${GREEN}[1]${NC} Create new backup"
    box_line "  ${GREEN}[2]${NC} Manage existing backups"
    box_line "  ${GREEN}[3]${NC} Exit"
    box_bottom
    echo ""
    read -p "Choose option (1-3): " main_choice

    case $main_choice in
        1)
            create_backup
            ;;
        2)
            manage_existing_backups
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option."
            sleep 1
            ;;
    esac
done
