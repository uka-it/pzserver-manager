#!/usr/bin/env bash
###############################################################################
# Fix Server Config Location
# Migrates config from old location to correct location
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

OLD_CONFIG="$HOME/.local/share/Zomboid/Server/pzserver/pzserver.ini"
NEW_CONFIG="$SERVER_CONFIG_DIR/pzserver.ini"

echo "=================================================="
echo "Server Config Location Fix"
echo "=================================================="
echo ""

# Check if old config exists
if [ ! -f "$OLD_CONFIG" ]; then
    echo "✓ No old config found at: $OLD_CONFIG"
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
echo "From: $OLD_CONFIG"
echo "To:   $NEW_CONFIG"
echo ""

# Create directory if needed
mkdir -p "$SERVER_CONFIG_DIR"

# Copy the config
cp "$OLD_CONFIG" "$NEW_CONFIG"

if [ $? -eq 0 ]; then
    echo "✓ Config file migrated successfully"
    echo ""
    echo "Admin password from config:"
    grep "AdminPassword" "$NEW_CONFIG"
    echo ""
    echo "You can now start the server and it will find the admin password."
    echo ""
    echo "Old config is still at: $OLD_CONFIG"
    echo "You can delete it if you want: rm '$OLD_CONFIG'"
else
    echo "✗ Failed to copy config file"
    exit 1
fi

echo ""
echo "=================================================="
