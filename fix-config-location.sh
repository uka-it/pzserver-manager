#!/usr/bin/env bash
###############################################################################
# Fix Server Config Location
# Migrates config from old location to correct location
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

OLD_CONFIG="$HOME/.local/share/Zomboid/Server/pzserver/pzserver.ini"
OLD_CONFIG2="$HOME/Zomboid/Server/pzserver/pzserver.ini"
NEW_CONFIG="$SERVER_CONFIG_DIR/pzserver.ini"

echo "=================================================="
echo "Server Config Location Fix"
echo "=================================================="
echo ""

# Check if old config exists
SOURCE_CONFIG=""
if [ -f "$OLD_CONFIG" ]; then
    SOURCE_CONFIG="$OLD_CONFIG"
elif [ -f "$OLD_CONFIG2" ]; then
    SOURCE_CONFIG="$OLD_CONFIG2"
else
    echo "✓ No old config found"
    echo "  Nothing to migrate."
    exit 0
fi

# Check if new config already exists
if [ -f "$NEW_CONFIG" ]; then
    echo "✓ Config already exists at correct location:"
    echo "  $NEW_CONFIG"
    echo ""

    # Show admin password from both
    echo "Current password in correct location:"
    grep "AdminPassword" "$NEW_CONFIG" || echo "  No AdminPassword found"
    echo ""

    read -p "Overwrite with old config? (yes/no): " overwrite
    if [ "$overwrite" != "yes" ]; then
        echo "Skipped."
        exit 0
    fi
fi

echo "Migrating config file..."
echo ""
echo "From: $SOURCE_CONFIG"
echo "To:   $NEW_CONFIG"
echo ""

# Create directory if needed
mkdir -p "$SERVER_CONFIG_DIR"

# Copy the config
cp "$SOURCE_CONFIG" "$NEW_CONFIG"

if [ $? -eq 0 ]; then
    echo "✓ Config file migrated successfully"
    echo ""
    echo "Note: Admin password must be set via command-line parameter"
    echo "      It cannot be stored in the INI file."
    echo ""
    echo "Old config is still at: $SOURCE_CONFIG"
    echo "You can delete it if you want: rm '$SOURCE_CONFIG'"
else
    echo "✗ Failed to copy config file"
    exit 1
fi

echo ""
echo "=================================================="
