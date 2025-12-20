#!/bin/bash
###############################################################################
# Project Zomboid Server Startup Script
# Server: pzserver
# Branch: unstable-unstable
###############################################################################

# Server directory
INSTDIR="/home/liviouka/pzserver"
cd "${INSTDIR}"

# Server name (must match the directory in ~/.local/share/Zomboid/Server/)
SERVER_NAME="pzserver"

echo "=================================================="
echo "Starting Project Zomboid Server: ${SERVER_NAME}"
echo "Branch: unstable-unstable"
echo "=================================================="

# Export environment variables
export PATH="${INSTDIR}/jre64/bin:$PATH"
export LD_LIBRARY_PATH="${INSTDIR}/linux64:${INSTDIR}/natives:${INSTDIR}:${INSTDIR}/jre64/lib/amd64:${LD_LIBRARY_PATH}"

# Set JSIG library
JSIG="libjsig.so"

# Start the server using the ProjectZomboid64 launcher
# Memory is configured in ProjectZomboid64.json (default 8GB, edit if needed)
LD_PRELOAD="${LD_PRELOAD}:${JSIG}" ./ProjectZomboid64 -servername "${SERVER_NAME}"

echo "Server stopped."
exit 0
