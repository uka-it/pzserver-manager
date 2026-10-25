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

echo "Current branch: $(get_branch_display)"
echo ""
echo "Enter the Steam branch to install. Common branches:"
echo "  public    - Default release branch"
echo "  unstable  - Latest experimental build"
echo ""
echo "For the full, current list run: ./list-branches.sh"
echo ""
read -p "Branch name (press Enter for 'public', 'cancel' to quit): " SELECTED_BRANCH
SELECTED_BRANCH="${SELECTED_BRANCH:-public}"

if [ "$SELECTED_BRANCH" = "cancel" ]; then
    echo "Cancelled."
    exit 0
fi
if ! [[ "$SELECTED_BRANCH" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "Invalid branch name."
    exit 1
fi

BRANCH_NAME="$SELECTED_BRANCH"
if [ "$SELECTED_BRANCH" = "public" ]; then
    BETA_OPTION=""
else
    BETA_OPTION="-beta $SELECTED_BRANCH"
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
