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

echo "=================================================="
echo "Starting Project Zomboid Server: ${SERVER_NAME}"
echo "=================================================="

# Export environment variables
export PATH="${INSTALL_DIR}/jre64/bin:$PATH"
export LD_LIBRARY_PATH="${INSTALL_DIR}/linux64:${INSTALL_DIR}/natives:${INSTALL_DIR}:${INSTALL_DIR}/jre64/lib/amd64:${LD_LIBRARY_PATH}"

# Set JSIG library
JSIG="libjsig.so"

# Build command with admin password parameter
# The admin password MUST be passed via command line on first run
ADMIN_PARAM=""
if [ -n "$ADMIN_PASSWORD" ]; then
    ADMIN_PARAM="-adminpassword \"$ADMIN_PASSWORD\""
    echo "Admin password will be set from configuration"
fi

echo ""

# Start the server using the ProjectZomboid64 launcher
# Memory is configured in ProjectZomboid64.json (default 8GB, edit if needed)
LD_PRELOAD="${LD_PRELOAD}:${JSIG}" ./ProjectZomboid64 -servername "${SERVER_NAME}" $ADMIN_PARAM

echo "Server stopped."
exit 0
