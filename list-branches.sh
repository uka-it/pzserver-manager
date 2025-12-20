#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server - Dynamic Branch Switcher
# Queries Steam for available branches and lets you choose
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

echo "Querying Steam for available branches..."
echo "This may take a moment..."
echo ""

# Query Steam and extract branch info
TEMP_FILE=$(mktemp)
"$STEAMCMD" +login anonymous +app_info_update 1 +app_info_print 380870 +quit > "$TEMP_FILE" 2>&1

# Extract branches section
BRANCHES_DATA=$(sed -n '/"branches"/,/"privatebranches"/p' "$TEMP_FILE")

# Parse branch names and descriptions
declare -a BRANCHES
declare -a DESCRIPTIONS

# Extract each branch
while read -r line; do
    # Check if line contains a branch name (quoted string on its own line)
    if echo "$line" | grep -q '^\s*"[^"]*"\s*$'; then
        BRANCH=$(echo "$line" | sed 's/^\s*"\([^"]*\)"\s*$/\1/')

        # Skip metadata fields
        if [[ "$BRANCH" == "branches" || "$BRANCH" == "buildid" || "$BRANCH" == "timeupdated" || "$BRANCH" == "description" || "$BRANCH" == "pwdrequired" ]]; then
            continue
        fi

        # Look for description in the next few lines
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

    # Add helpful labels for known branches
    if [ "$BRANCH" = "public" ]; then
        echo "$NUM. STABLE (Build 41) - public branch"
        echo "   Most stable, recommended for public servers"
    elif [ "$BRANCH" = "42.13.1" ]; then
        echo "$NUM. Build 42.13.1"
        echo "   Specific stable Build 42 version, recommended for multiplayer"
    elif [ "$BRANCH" = "unstable" ]; then
        echo "$NUM. UNSTABLE - Latest Build 42 experimental"
        echo "   Latest features, may have bugs, frequent updates"
    else
        echo "$NUM. $BRANCH"
        if [ "$DESC" != "$BRANCH" ]; then
            echo "   $DESC"
        fi
    fi
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
    BRANCH_NAME="STABLE (Build 41)"
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
