#!/usr/bin/env bash
###############################################################################
# Reset Project Zomboid Server Admin Password
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
    local CRT_GREEN=$'\033[1;92m'

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
box_header "${YELLOW}RESET ADMIN PASSWORD${NC}"

echo -e "${YELLOW}This will set a new admin password for your server.${NC}"
echo ""
echo "How it works:"
echo "  1. Enter new password"
echo "  2. Password is saved to .env file"
echo "  3. Admin flag is removed"
echo "  4. Password will be applied on next server start"
echo ""

# Check if server is running
if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
    echo -e "${YELLOW}⚠ Server is currently running${NC}"
    echo ""
    echo "The password will be changed on next server restart."
    echo ""
    read -p "Continue? (yes/no): " continue_confirm
    if [ "$continue_confirm" != "yes" ]; then
        echo "Cancelled."
        exit 0
    fi
    echo ""
fi

# Ask for new password
while true; do
    read -p "Enter new admin password: " NEW_PASSWORD

    if [ -z "$NEW_PASSWORD" ]; then
        echo -e "${RED}Password cannot be empty!${NC}"
        echo ""
        continue
    fi

    if [ ${#NEW_PASSWORD} -lt 6 ]; then
        echo -e "${YELLOW}Warning: Password is very short (less than 6 characters)${NC}"
        read -p "Use it anyway? (yes/no): " short_confirm
        if [ "$short_confirm" != "yes" ]; then
            echo ""
            continue
        fi
    fi

    echo ""
    read -p "Confirm password: " CONFIRM_PASSWORD

    if [ "$NEW_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
        echo -e "${RED}Passwords don't match! Try again.${NC}"
        echo ""
        continue
    fi

    break
done

echo ""
echo -e "${YELLOW}Setting new admin password...${NC}"
echo ""

# Update or add ADMIN_PASSWORD to .env file
ENV_FILE="$SCRIPT_DIR/.env"

# Create .env if it doesn't exist
if [ ! -f "$ENV_FILE" ]; then
    echo "# Project Zomboid Server Configuration" > "$ENV_FILE"
    echo "# Generated on $(date)" >> "$ENV_FILE"
    echo "" >> "$ENV_FILE"
fi

# Check if ADMIN_PASSWORD already exists in .env
if grep -q "^ADMIN_PASSWORD=" "$ENV_FILE" 2>/dev/null; then
    # Replace existing password
    sed -i "s/^ADMIN_PASSWORD=.*/ADMIN_PASSWORD=\"$NEW_PASSWORD\"/" "$ENV_FILE"
    echo "✓ Updated ADMIN_PASSWORD in .env file"
else
    # Add new password entry
    echo "ADMIN_PASSWORD=\"$NEW_PASSWORD\"" >> "$ENV_FILE"
    echo "✓ Added ADMIN_PASSWORD to .env file"
fi

# Remove admin created flag
ADMIN_FLAG="$SCRIPT_DIR/.admin_created"
if [ -f "$ADMIN_FLAG" ]; then
    rm -f "$ADMIN_FLAG"
    echo "✓ Removed admin flag"
else
    echo "ℹ Admin flag not found (this is normal for first-time setup)"
fi

echo ""
box_top
box_line "${GREEN}✓ Admin Password Reset Complete!${NC}"
box_bottom
echo ""
echo -e "${CYAN}New password:${NC} $NEW_PASSWORD"
echo ""

if pgrep -f "ProjectZomboid64.*pzserver" > /dev/null; then
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Stop the server: ./server-manager.sh → [2]"
    echo "  2. Start the server: ./server-manager.sh → [1]"
    echo "  3. The new password will be applied"
else
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Start the server: ./server-manager.sh → [1]"
    echo "  2. The new password will be applied"
fi

echo ""
echo -e "${BLUE}Note:${NC} The password is stored in .env and will be removed"
echo "      after the server starts (for security)."
echo ""
