#!/bin/bash
###############################################################################
# Project Zomboid Server Startup Script
# Server: pzserver
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

cd "${INSTALL_DIR}"

# Server name
SERVER_NAME="pzserver"

# Flag file to track if admin has been created
ADMIN_FLAG="$SCRIPT_DIR/.admin_created"

echo "=================================================="
echo "Starting Project Zomboid Server: ${SERVER_NAME}"
echo "=================================================="

# Export environment variables
export PATH="${INSTALL_DIR}/jre64/bin:$PATH"
export LD_LIBRARY_PATH="${INSTALL_DIR}/linux64:${INSTALL_DIR}/natives:${INSTALL_DIR}:${INSTALL_DIR}/jre64/lib/amd64:${LD_LIBRARY_PATH}"

# Set JSIG library
JSIG="libjsig.so"

# Check if this is first run (admin not created yet)
ADMIN_PARAM=""

if [ ! -f "$ADMIN_FLAG" ] && [ -n "$ADMIN_PASSWORD" ]; then
    # First run - pass admin password
    ADMIN_PARAM="-adminpassword \"$ADMIN_PASSWORD\""
    echo "First run detected - admin password will be set"
    echo ""

    # Create flag file immediately to prevent re-use
    touch "$ADMIN_FLAG"

    # Remove admin password from .env file for security (do it now, not after server stops)
    if [ -f "$SCRIPT_DIR/.env" ]; then
        echo "Removing admin password from .env for security..."
        sed -i '/^ADMIN_PASSWORD=/d' "$SCRIPT_DIR/.env"
        echo "✓ Admin password removed from .env file"
        echo "  (Password will be used this one time, then stored in server database)"
        echo ""
    fi
else
    echo "Admin already configured"
    echo ""
fi

# Start the server using the ProjectZomboid64 launcher
# Memory is configured in ProjectZomboid64.json (default 8GB, edit if needed)
LD_PRELOAD="${LD_PRELOAD}:${JSIG}" ./ProjectZomboid64 -servername "${SERVER_NAME}" $ADMIN_PARAM

SERVER_EXIT_CODE=$?
echo "Server stopped."
exit $SERVER_EXIT_CODE
