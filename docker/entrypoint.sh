#!/usr/bin/env bash
###############################################################################
# Docker entrypoint
# - Syncs the manager scripts into the persistent ~/manager directory
# - Runs a non-interactive install on first start
# - Starts the server (unless AUTOSTART=false) and keeps the container alive,
#   so stopping/restarting from the menu doesn't stop the container
# - Shuts the server down gracefully on docker stop
###############################################################################

SRC_DIR="/opt/pzserver-manager"
MANAGER_DIR="$HOME/manager"
STOP_TIMEOUT="${STOP_TIMEOUT:-50}"

mkdir -p "$MANAGER_DIR"
# Copy scripts but never overwrite user state (.env, .admin_created, logs).
# Files added with "docker cp" are owned by root, so take them back if needed;
# a partial sync would mix old and new scripts.
if ! cp -a "$SRC_DIR/." "$MANAGER_DIR/" 2>/dev/null; then
    sudo chown -R pz:pz "$MANAGER_DIR"
    if ! cp -a "$SRC_DIR/." "$MANAGER_DIR/"; then
        echo "⚠ WARNING: could not update the scripts in $MANAGER_DIR - they may be outdated"
    fi
fi
cd "$MANAGER_DIR"

source "$MANAGER_DIR/config.sh"

shutdown() {
    echo "Received stop signal, shutting down..."
    if ! stop_pz_server "$STOP_TIMEOUT"; then
        echo "Server did not stop within ${STOP_TIMEOUT}s, killing"
        pkill -9 -f "$PZ_PROCESS_PATTERN"
    fi
    pkill -x playit 2>/dev/null
    [ -n "$TAIL_PID" ] && kill "$TAIL_PID" 2>/dev/null
    exit 0
}
trap shutdown TERM INT

if [ ! -f "$INSTALL_DIR/ProjectZomboid64" ]; then
    echo "No server installation found - running first-time setup"
    if ! PZ_NONINTERACTIVE=1 "$MANAGER_DIR/setup-new-server.sh"; then
        echo "✗ Setup failed"
        exit 1
    fi
    # Reload the .env written by setup
    source "$MANAGER_DIR/config.sh"
fi

if [ "${AUTOSTART:-true}" = "true" ]; then
    "$MANAGER_DIR/start-all.sh"
else
    echo "AUTOSTART=false - start the server from the menu:"
    echo "  docker exec -it <container> ./server-manager.sh"
fi

# Stream the server log to docker logs
touch "$MANAGER_DIR/server.log"
tail -n +1 -F "$MANAGER_DIR/server.log" &
TAIL_PID=$!

# Wait in the background so the TERM trap fires immediately
while true; do
    sleep 3600 &
    wait $!
done
