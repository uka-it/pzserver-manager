#!/usr/bin/env bash
###############################################################################
# Clean Project Zomboid Cache & Force Re-download from Steam
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "=================================================="
echo "Project Zomboid Cache Cleaner"
echo "=================================================="
echo ""
echo "This will delete cache and downloaded files."
echo "The server will re-download fresh from Steam on next start."
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
    pkill playit
    sleep 3
fi

# Calculate actual sizes
WORKSHOP_SIZE=$(du -sh $INSTALL_DIR/steamapps/workshop $ZOMBOID_DIR/Workshop 2>/dev/null | awk '{sum+=$1} END {print sum}' | numfmt --to=iec 2>/dev/null || echo "0")
LOGS_SIZE=$(du -sh $ZOMBOID_DIR/Logs 2>/dev/null | awk '{print $1}')
BACKUP_SIZE=$(du -sh $ZOMBOID_DIR/Server/backup 2>/dev/null | awk '{print $1}')

# If numfmt failed, use du directly
if [ "$WORKSHOP_SIZE" = "0" ]; then
    WORKSHOP_SIZE=$(du -sh $INSTALL_DIR/steamapps/workshop 2>/dev/null | awk '{print $1}' || echo "0")
fi

echo ""
echo "What do you want to clean?"
echo ""
echo "1. Workshop mods & cache [$WORKSHOP_SIZE] - Forces mod re-download"
echo "2. Server logs [$LOGS_SIZE]"
echo "3. Server config backups [$BACKUP_SIZE]"
echo "4. Everything above (recommended for fresh start)"
echo "5. Cancel"
echo ""
read -p "Choose option (1-5): " option

case $option in
    1)
        echo "Cleaning workshop cache..."
        rm -rf $INSTALL_DIR/steamapps/workshop/*
        rm -rf $ZOMBOID_DIR/Workshop/*
        echo "✓ Workshop cache cleaned ($WORKSHOP_SIZE freed)"
        ;;
    2)
        echo "Cleaning logs..."
        rm -rf $ZOMBOID_DIR/Logs/*
        echo "✓ Logs cleaned ($LOGS_SIZE freed)"
        ;;
    3)
        echo "Cleaning server backups..."
        rm -rf $ZOMBOID_DIR/Server/backup/*
        echo "✓ Server backups cleaned ($BACKUP_SIZE freed)"
        ;;
    4)
        echo "Cleaning everything..."
        TOTAL_SIZE=$(echo "$WORKSHOP_SIZE $LOGS_SIZE $BACKUP_SIZE" | awk '{print $1+$2+$3}')
        rm -rf $INSTALL_DIR/steamapps/workshop/*
        rm -rf $ZOMBOID_DIR/Workshop/*
        rm -rf $ZOMBOID_DIR/Logs/*
        rm -rf $ZOMBOID_DIR/Server/backup/*
        echo "✓ All cache cleaned"
        ;;
    5)
        echo "Cancelled."
        exit 0
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
esac

echo ""
echo "=================================================="
echo "✓ Cache Cleaning Complete!"
echo "=================================================="
echo ""
echo "Next steps:"
echo "1. Update server files from Steam:"
echo "   ./update-server.sh"
echo ""
echo "2. Start the server:"
echo "   ./start-all.sh"
echo ""
echo "The server will re-download any needed files from Steam."
echo "=================================================="
