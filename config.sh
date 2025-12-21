#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server Manager - Configuration Loader
# Source this file in other scripts to load configuration
###############################################################################

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default configuration
export SERVER_NAME="${SERVER_NAME:-My PZ Server}"
export SERVER_DESCRIPTION="${SERVER_DESCRIPTION:-A Project Zomboid Dedicated Server - Welcome Survivors!}"
export ADMIN_PASSWORD="${ADMIN_PASSWORD:-changeme123}"
export MAX_PLAYERS="${MAX_PLAYERS:-32}"

# Installation paths
export INSTALL_DIR="${INSTALL_DIR:-$HOME/pzserver}"
export STEAMCMD_DIR="${STEAMCMD_DIR:-$INSTALL_DIR/steamcmd}"

# Ports
export DEFAULT_PORT="${DEFAULT_PORT:-16261}"
export UDP_PORT="${UDP_PORT:-16262}"
export STEAM_PORT1="${STEAM_PORT1:-8766}"
export STEAM_PORT2="${STEAM_PORT2:-8767}"
export RCON_PORT="${RCON_PORT:-27015}"

# Network configuration (optional)
export PUBLIC_DOMAIN="${PUBLIC_DOMAIN:-}"
export PUBLIC_IPV6="${PUBLIC_IPV6:-}"
export PLAYIT_TUNNEL="${PLAYIT_TUNNEL:-}"

# Playit.gg
export PLAYIT_ENABLED="${PLAYIT_ENABLED:-true}"

# Load .env file if it exists (overrides defaults)
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
fi

# Zomboid data directory (usually in user's home)
export ZOMBOID_DIR="$HOME/Zomboid"
export SERVER_CONFIG_DIR="$ZOMBOID_DIR/Server"
export SERVER_CONFIG_FILE="$SERVER_CONFIG_DIR/pzserver.ini"
