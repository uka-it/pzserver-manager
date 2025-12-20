#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server Update Script
# Updates the server to the latest version of the current branch
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "=================================================="
echo "Updating Project Zomboid Server"
echo "=================================================="
echo ""

# Detect current branch from Steam manifest
MANIFEST="$INSTALL_DIR/steamapps/appmanifest_380870.acf"

if [ -f "$MANIFEST" ]; then
    CURRENT_BRANCH=$(grep "BetaKey" "$MANIFEST" | head -1 | sed 's/.*"BetaKey".*"\([^"]*\)".*/\1/')

    if [ -z "$CURRENT_BRANCH" ] || [ "$CURRENT_BRANCH" = "BetaKey" ]; then
        CURRENT_BRANCH="public"
        BRANCH_DISPLAY="STABLE (Build 41)"
        BETA_OPTION=""
    else
        BRANCH_DISPLAY="$CURRENT_BRANCH"
        BETA_OPTION="-beta $CURRENT_BRANCH"
    fi
else
    echo "⚠ Warning: Could not detect current branch"
    echo "Defaulting to public (stable) branch"
    CURRENT_BRANCH="public"
    BRANCH_DISPLAY="STABLE (Build 41)"
    BETA_OPTION=""
fi

echo "Current branch: $BRANCH_DISPLAY"
echo ""
echo "This will update to the latest version of this branch."
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Updating $BRANCH_DISPLAY from Steam..."
echo ""

# Update the server using SteamCMD
$STEAMCMD_DIR/steamcmd.sh \
    +force_install_dir $INSTALL_DIR \
    +login anonymous \
    +app_update 380870 $BETA_OPTION validate \
    +quit

if [ $? -eq 0 ]; then
    echo ""
    echo "=================================================="
    echo "✓ Update complete!"
    echo "=================================================="
    echo ""
    echo "Branch: $BRANCH_DISPLAY"
    echo ""
    echo "Restart the server to use the updated files:"
    echo "  ./stop-all.sh && ./start-all.sh"
    echo "=================================================="
else
    echo ""
    echo "✗ Update failed!"
    echo "Check the error messages above."
    exit 1
fi
