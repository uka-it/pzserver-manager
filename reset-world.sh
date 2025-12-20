#!/usr/bin/env bash
###############################################################################
# Reset Project Zomboid World - Fresh Start
###############################################################################

BACKUP_DIR="/home/liviouka/pzserver/backups"
SERVER_NAME="pzserver"
SAVE_DIR="$HOME/Zomboid/Saves/Multiplayer/$SERVER_NAME"
DB_FILE="$HOME/Zomboid/db/$SERVER_NAME.db"

echo "=================================================="
echo "Project Zomboid World Reset Tool"
echo "=================================================="
echo ""
echo "This will DELETE all world data and start fresh!"
echo ""

# Check if server is running
if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
    echo "⚠ WARNING: Server is currently running!"
    echo ""
    read -p "Stop the server and continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Cancelled."
        exit 0
    fi
    echo "Stopping server..."
    pkill -f "ProjectZomboid64.*pzserver"
    sleep 3
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
echo "=================================================="
echo "✓ World Reset Complete!"
echo "=================================================="
echo ""
echo "The server will create a fresh new world on next start."
echo ""
echo "To start the server:"
echo "  ./start-all.sh"
echo ""

if [ "$do_backup" = "yes" ]; then
    echo "Your old world backup is saved at:"
    echo "  $BACKUP_FILE"
    echo ""
fi
