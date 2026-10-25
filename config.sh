#!/usr/bin/env bash
###############################################################################
# Project Zomboid Server Manager - Configuration Loader
# Source this file in other scripts to load configuration
###############################################################################

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Manager version (see CHANGELOG.md)
PZ_MANAGER_VERSION="$( { tr -d '\r\n' < "$SCRIPT_DIR/VERSION"; } 2>/dev/null )"
PZ_MANAGER_VERSION="${PZ_MANAGER_VERSION:-unknown}"

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

# Server memory (JVM -Xmx), e.g. 6G or 6144M. Empty = keep ProjectZomboid64.json as is
export SERVER_MEMORY="${SERVER_MEMORY:-}"

# Internal server name (-servername). Determines the file names in ~/Zomboid:
# Server/<name>.ini, Saves/Multiplayer/<name>/, db/<name>.db
export PZ_SERVER_NAME="${PZ_SERVER_NAME:-pzserver}"

# Docker (set by the image; HOST_IP is the address players use to reach the host)
export PZ_DOCKER="${PZ_DOCKER:-0}"
export HOST_IP="${HOST_IP:-}"

# Load .env file if it exists (overrides defaults)
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
fi

if ! [[ "$PZ_SERVER_NAME" =~ ^[A-Za-z0-9_-]+$ ]]; then
    echo "Invalid PZ_SERVER_NAME '$PZ_SERVER_NAME' - use only letters, numbers, - and _" >&2
    exit 1
fi

# Zomboid data directory (usually in user's home)
export ZOMBOID_DIR="$HOME/Zomboid"
export SERVER_CONFIG_DIR="$ZOMBOID_DIR/Server"
export SERVER_CONFIG_FILE="$SERVER_CONFIG_DIR/$PZ_SERVER_NAME.ini"
export PZ_SAVE_DIR="$ZOMBOID_DIR/Saves/Multiplayer/$PZ_SERVER_NAME"
export PZ_DB_FILE="$ZOMBOID_DIR/db/$PZ_SERVER_NAME.db"

# pgrep/pkill -f pattern matching this server's process (exact -servername)
export PZ_PROCESS_PATTERN="ProjectZomboid64 .*-servername $PZ_SERVER_NAME( |\$)"

# Set Key=Value in an INI file, replacing an existing line or appending one
set_ini_value() {
    local file="$1" key="$2" value="$3" escaped
    if grep -q "^${key}=" "$file"; then
        escaped=$(printf '%s' "$value" | sed 's/[&|\\]/\\&/g')
        sed -i "s|^${key}=.*|${key}=${escaped}|" "$file"
    else
        printf '%s=%s\n' "$key" "$value" >> "$file"
    fi
}

# Local address for display. Inside Docker, hostname -I returns the
# container's internal IP, which players can't connect to; the published
# ports are reachable on localhost from the Docker host itself.
get_local_ip() {
    if [ -n "$HOST_IP" ]; then
        echo "$HOST_IP"
    elif [ "$PZ_DOCKER" = "1" ]; then
        echo "localhost"
    else
        hostname -I 2>/dev/null | awk '{print $1}'
    fi
}

# Stop the server gracefully. SIGTERM makes it save the world first, which can
# take a while, so wait for the process to exit (default 60s).
# Returns 1 if it is still running after the timeout.
stop_pz_server() {
    local timeout="${1:-${STOP_TIMEOUT:-60}}" i
    pgrep -f "$PZ_PROCESS_PATTERN" > /dev/null || return 0
    pkill -f "$PZ_PROCESS_PATTERN"
    printf "Waiting for the server to save and exit"
    for ((i = 0; i < timeout; i++)); do
        if ! pgrep -f "$PZ_PROCESS_PATTERN" > /dev/null; then
            echo " done (${i}s)"
            return 0
        fi
        printf "."
        sleep 1
    done
    echo " timed out after ${timeout}s"
    return 1
}

# Installed game branch from the Steam manifest ("public" unless a beta is set)
get_installed_branch() {
    local manifest="$INSTALL_DIR/steamapps/appmanifest_380870.acf" branch=""
    if [ -f "$manifest" ]; then
        branch=$(grep '"BetaKey"' "$manifest" | head -1 | sed 's/.*"BetaKey"[[:space:]]*"\([^"]*\)".*/\1/')
    fi
    echo "${branch:-public}"
}

# Game version (e.g. 42.21.0) as logged by the server on its last start.
# Cached per Steam build ID so it isn't shown for files that were updated
# since; empty until the server has been started on the installed build.
get_installed_version() {
    local manifest="$INSTALL_DIR/steamapps/appmanifest_380870.acf"
    local console="$ZOMBOID_DIR/server-console.txt"
    local cache="$SCRIPT_DIR/.game_version"
    local build version cached_build cached_version

    [ -f "$manifest" ] || return
    build=$(grep -m1 '"buildid"' "$manifest" | sed 's/.*"buildid"[[:space:]]*"\([^"]*\)".*/\1/')

    # Only trust the console log if it was written after the last Steam update
    if [ -f "$console" ] && [ "$console" -nt "$manifest" ]; then
        version=$(grep -a -m1 -o 'version=[^ ]*' "$console" | cut -d= -f2)
        [ -n "$version" ] && echo "$build $version" > "$cache"
    fi

    if [ -f "$cache" ]; then
        read -r cached_build cached_version < "$cache"
        [ "$cached_build" = "$build" ] && echo "$cached_version"
    fi
}

# Parse the "branches" section of steamcmd +app_info_print output (file $1)
# into the BRANCHES and DESCRIPTIONS arrays. Password-protected branches are
# skipped since anonymous login can't download them.
parse_steam_branches() {
    local name desc
    BRANCHES=()
    DESCRIPTIONS=()
    while IFS=$'\t' read -r name desc; do
        [ -n "$name" ] || continue
        BRANCHES+=("$name")
        DESCRIPTIONS+=("$desc")
    done < <(awk '
        !inb && /^[[:space:]]*"branches"[[:space:]]*$/ { inb = 1; next }
        !inb { next }
        /^[[:space:]]*\{/ { depth++; next }
        /^[[:space:]]*\}/ {
            depth--
            if (depth == 1 && !pwd) print name "\t" desc
            if (depth == 1) { name = ""; desc = ""; pwd = 0 }
            if (depth == 0) exit
            next
        }
        depth == 1 && /^[[:space:]]*"[^"]*"[[:space:]]*$/ {
            gsub(/^[[:space:]]*"|"[[:space:]]*$/, ""); name = $0; next
        }
        depth == 2 && /"description"/ {
            sub(/.*"description"[[:space:]]*"/, ""); sub(/".*$/, ""); desc = $0
        }
        depth == 2 && /"pwdrequired"[[:space:]]*"1"/ { pwd = 1 }
    ' "$1")
}

# Menu label for a Steam branch, e.g. "unstable - Unstable"
branch_label() {
    local branch="$1" desc="$2"
    if [ "$branch" = "public" ]; then
        echo "public - Default release branch"
    elif [ -n "$desc" ] && [ "$desc" != "$branch" ]; then
        echo "$branch - $desc"
    else
        echo "$branch"
    fi
}

# Max server memory from the -Xmx JVM option in ProjectZomboid64.json, e.g. "8G"
get_json_memory() {
    local xmx
    xmx=$(grep -o '"-Xmx[0-9]*[gGmMkK]"' "$INSTALL_DIR/ProjectZomboid64.json" 2>/dev/null | head -1 | tr -d '"')
    if [ -n "$xmx" ]; then
        echo "${xmx#-Xmx}" | tr '[:lower:]' '[:upper:]'
    else
        echo "Unknown"
    fi
}

# Server memory for display: SERVER_MEMORY from .env, else the JSON value
get_server_memory() {
    local mem
    if [ -n "$SERVER_MEMORY" ] && mem=$(normalize_memory "$SERVER_MEMORY"); then
        echo "$mem"
    else
        get_json_memory
    fi
}

# Normalize a memory size ("8", "8g", "8GB", "6144m") to JVM form ("8G", "6144M").
# Prints nothing and returns 1 if invalid or below the 2G minimum.
normalize_memory() {
    local value
    value=$(echo "$1" | tr '[:lower:]' '[:upper:]' | tr -d ' ')
    value="${value%B}"
    [[ "$value" =~ ^[0-9]+$ ]] && value="${value}G"
    [[ "$value" =~ ^[1-9][0-9]*[GM]$ ]] || return 1
    [ "$(memory_to_mb "$value")" -ge 2048 ] || return 1
    echo "$value"
}

# "8G" -> 8192, "6144M" -> 6144
memory_to_mb() {
    case "$1" in
        *G) echo $(( ${1%G} * 1024 )) ;;
        *M) echo "${1%M}" ;;
    esac
}

# RAM available to the server in MB, honoring Docker/cgroup memory limits
get_total_memory_mb() {
    local total limit
    total=$(awk '/^MemTotal:/ {print int($2 / 1024)}' /proc/meminfo)
    limit=$(cat /sys/fs/cgroup/memory.max 2>/dev/null || cat /sys/fs/cgroup/memory/memory.limit_in_bytes 2>/dev/null)
    if [[ "$limit" =~ ^[0-9]+$ ]] && [ $((limit / 1048576)) -lt "$total" ]; then
        total=$((limit / 1048576))
    fi
    echo "$total"
}

# Suggested memory: total RAM minus 2G for the system, between 2G and 8G
get_recommended_memory() {
    local gb=$(( $(get_total_memory_mb) / 1024 - 2 ))
    [ "$gb" -gt 8 ] && gb=8
    [ "$gb" -lt 2 ] && gb=2
    echo "${gb}G"
}

# Ask the user for the server memory and store it in CHOSEN_MEMORY.
# $1 = value offered as default (defaults to the recommendation)
prompt_server_memory() {
    local default="${1:-$(get_recommended_memory)}" total_mb input mem confirm
    total_mb=$(get_total_memory_mb)

    echo "Available RAM: $((total_mb / 1024))G"
    echo "Recommended:   $(get_recommended_memory) (leaves ~2G for the system)"
    echo "Examples:      4G, 6G, 8G, 12G, 6144M (minimum 2G)"
    echo ""
    while true; do
        read -p "Server memory (press Enter for '$default'): " input
        input="${input:-$default}"
        if ! mem=$(normalize_memory "$input"); then
            echo "Invalid value '$input' - use a size like 6G or 6144M (minimum 2G)"
            continue
        fi
        if [ "$(memory_to_mb "$mem")" -gt $((total_mb - 1024)) ]; then
            read -p "⚠ $mem leaves less than 1G for the system. Use it anyway? (yes/no): " confirm
            [ "$confirm" = "yes" ] || continue
        fi
        CHOSEN_MEMORY="$mem"
        return 0
    done
}

# Write SERVER_MEMORY into ProjectZomboid64.json. Steam "validate" restores the
# original file on every update, so this runs before each server start.
apply_server_memory() {
    local json="$INSTALL_DIR/ProjectZomboid64.json" mem
    [ -n "$SERVER_MEMORY" ] || return 0
    [ -f "$json" ] || return 1
    if ! mem=$(normalize_memory "$SERVER_MEMORY"); then
        echo "⚠ Invalid SERVER_MEMORY '$SERVER_MEMORY' in .env - keeping $(get_json_memory)"
        return 1
    fi
    sed -i "s/\"-Xmx[0-9]*[gGmMkK]\"/\"-Xmx${mem}\"/" "$json"
}

# Set KEY="VALUE" in .env, replacing an existing line or appending one
set_env_value() {
    local key="$1" value="$2" env_file="$SCRIPT_DIR/.env"
    touch "$env_file"
    if grep -q "^${key}=" "$env_file"; then
        sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$env_file"
    else
        echo "${key}=\"${value}\"" >> "$env_file"
    fi
}

# Branch + version for display, e.g. "public (v42.21.0)"
get_branch_display() {
    local version
    if [ ! -f "$INSTALL_DIR/steamapps/appmanifest_380870.acf" ]; then
        echo "Not installed"
        return
    fi
    version=$(get_installed_version)
    if [ -n "$version" ]; then
        echo "$(get_installed_branch) (v$version)"
    else
        echo "$(get_installed_branch) (version shown after next start)"
    fi
}
