#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server - Branch Switcher
# Switch between different game versions/branches
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

STEAMCMD="$STEAMCMD_DIR/steamcmd.sh"

echo "=================================================="
echo "Project Zomboid Server - Branch Switcher"
echo "=================================================="
echo ""

# Check if server is running
if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
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

echo "Available Branches:"
echo ""
echo "1. STABLE (Build 41) - Recommended for public servers"
echo "   Most stable, widely tested, full features"
echo ""
echo "2. Build 42.13.1 - Specific stable Build 42 version"
echo "   Fixed version of Build 42, recommended for multiplayer"
echo ""
echo "3. UNSTABLE (Build 42) - Latest experimental build"
echo "   Latest features, may have bugs, frequent updates"
echo ""
echo "4. PUBLIC_BETA - Public testing branch"
echo "   Beta features before going to unstable"
echo ""
echo "5. IWILLBACKUPMYSAVE - Unstable testing branch"
echo "   Newest experimental features, use with caution"
echo ""
echo "6. Cancel"
echo ""
read -p "Choose branch (1-6): " choice

case $choice in
    1)
        BRANCH=""
        BRANCH_NAME="STABLE (Build 41)"
        BETA_OPTION=""
        ;;
    2)
        BRANCH="-beta 42.13.1"
        BRANCH_NAME="Build 42.13.1"
        BETA_OPTION="-beta 42.13.1"
        ;;
    3)
        BRANCH="-beta unstable"
        BRANCH_NAME="UNSTABLE (Build 42)"
        BETA_OPTION="-beta unstable"
        ;;
    4)
        BRANCH="-beta public_beta"
        BRANCH_NAME="PUBLIC_BETA"
        BETA_OPTION="-beta public_beta"
        ;;
    5)
        BRANCH="-beta iwillbackupmysave"
        BRANCH_NAME="IWILLBACKUPMYSAVE"
        BETA_OPTION="-beta iwillbackupmysave"
        ;;
    6)
        echo "Cancelled."
        exit 0
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

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
        $ZOMBOID_DIR/Saves/Multiplayer/pzserver/ \
        $ZOMBOID_DIR/db/pzserver.db \
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
