#!/usr/bin/env bash
###############################################################################
# Clean Project Zomboid Cache & Force Re-download from Steam
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
box_header "${YELLOW}CACHE CLEANER${NC}"
echo "This will delete cache and downloaded files."
echo "The server will re-download fresh from Steam on next start."
echo ""

# Check if server is running
if pgrep -f "$PZ_PROCESS_PATTERN" > /dev/null; then
    echo "⚠ WARNING: Server is currently running!"
    echo ""
    read -p "Stop the server and continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Cancelled."
        exit 0
    fi
    echo "Stopping server..."
    if ! stop_pz_server; then
        echo "✗ Server did not stop - aborting to avoid damaging the save"
        exit 1
    fi
    pkill playit
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
box_top
box_line "${GREEN}✓ Cache Cleaning Complete!${NC}"
box_bottom
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  ${BLUE}1. Update server files from Steam:${NC}"
echo "     ./update-server.sh"
echo ""
echo -e "  ${BLUE}2. Start the server:${NC}"
echo "     ./start-all.sh"
echo ""
echo "The server will re-download any needed files from Steam."
