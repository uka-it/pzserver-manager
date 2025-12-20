# Configuration Guide

## 📝 Environment Configuration

All server settings can be customized using a `.env` file.

### Quick Start

1. Copy the example configuration:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your settings:
   ```bash
   nano .env
   ```

3. Run any script - it will automatically load your configuration

---

## ⚙️ Configuration Options

### Server Settings

```bash
# Server Name (shown to players)
SERVER_NAME="My Awesome PZ Server"

# Server Description
SERVER_DESCRIPTION="Welcome survivors! PvP enabled, friendly community."

# Admin Password (used in-game to become admin)
ADMIN_PASSWORD="your-secure-password-here"

# Maximum Players
MAX_PLAYERS=32
```

### Installation Paths

```bash
# Where to install the server
INSTALL_DIR="$HOME/pzserver"

# SteamCMD location
STEAMCMD_DIR="$INSTALL_DIR/steamcmd"
```

### Network Ports

```bash
# Main server port (UDP)
DEFAULT_PORT=16261

# Secondary UDP port
UDP_PORT=16262

# Steam authentication ports
STEAM_PORT1=8766
STEAM_PORT2=8767

# RCON port (if enabled)
RCON_PORT=27015
```

### Public Access (Optional)

These are shown in the status display for player connections:

```bash
# Your public domain (if you have one)
PUBLIC_DOMAIN="myserver.example.com"

# Your public IPv6 address (if you have one)
PUBLIC_IPV6="2001:db8::1"

# Your Playit.gg tunnel address
PLAYIT_TUNNEL="your-tunnel.gl.at.ply.gg:11128"
```

**Note:** Leave empty (`=""`) if not applicable.

### Playit.gg Configuration

```bash
# Enable/disable Playit.gg integration
PLAYIT_ENABLED=true
```

---

## 📖 Examples

### Example 1: Basic Setup

```bash
SERVER_NAME="Zombie Apocalypse"
ADMIN_PASSWORD="changeme123"
MAX_PLAYERS=16
```

Everything else uses defaults. Perfect for getting started quickly!

### Example 2: Public Server with Custom Domain

```bash
SERVER_NAME="Official Survival Server"
SERVER_DESCRIPTION="Hardcore survival | PvP | Active admins"
ADMIN_PASSWORD="super-secret-admin-pass"
MAX_PLAYERS=64
PUBLIC_DOMAIN="pz.myserver.com"
PLAYIT_TUNNEL="awesome-server.gl.at.ply.gg:12345"
```

### Example 3: Private LAN Server

```bash
SERVER_NAME="Friends Only Server"
ADMIN_PASSWORD="friends123"
MAX_PLAYERS=8
PLAYIT_ENABLED=false
```

No public access needed - just LAN play!

---

## 🔧 How Configuration Works

### Loading Order

1. **Defaults** - Built-in defaults from `config.sh`
2. **Environment** - `.env` file overrides defaults
3. **Script Variables** - Can be overridden per script

### Example

```bash
# Default (config.sh)
SERVER_NAME="My PZ Server"

# Your .env file
SERVER_NAME="Zombie Haven"

# Final result: "Zombie Haven"
```

---

## 🚀 Advanced Usage

### Per-Script Override

You can override settings when running a script:

```bash
# Use different port temporarily
DEFAULT_PORT=16999 ./start-all.sh

# Different server name
SERVER_NAME="Test Server" ./server-manager.sh
```

### Multiple Servers

To run multiple servers, use different installation directories:

```bash
# Server 1
INSTALL_DIR="$HOME/pzserver1" DEFAULT_PORT=16261 ./setup-new-server.sh

# Server 2
INSTALL_DIR="$HOME/pzserver2" DEFAULT_PORT=17261 ./setup-new-server.sh
```

---

## 🔒 Security Notes

1. **NEVER commit your `.env` file** - It's in `.gitignore`
2. **Change default passwords** - Don't use "changeme123" in production
3. **Restrict file permissions**:
   ```bash
   chmod 600 .env
   ```
4. **Use strong admin passwords** - They're stored in plain text

---

## 🆘 Troubleshooting

### Configuration not loading?

```bash
# Check if .env exists
ls -la .env

# Verify it's being sourced
grep "source.*config.sh" server-manager.sh
```

### Wrong values being used?

```bash
# Check what config is loaded
source ./config.sh
echo "Server: $SERVER_NAME"
echo "Port: $DEFAULT_PORT"
```

### Reset to defaults

```bash
# Remove your custom config
rm .env

# Copy fresh example
cp .env.example .env
```

---

## 📋 Complete .env Template

```bash
# Project Zomboid Server Configuration
SERVER_NAME="My PZ Server"
SERVER_DESCRIPTION="A Project Zomboid Dedicated Server - Welcome Survivors!"
ADMIN_PASSWORD="changeme123"
MAX_PLAYERS=32

INSTALL_DIR="$HOME/pzserver"
STEAMCMD_DIR="$INSTALL_DIR/steamcmd"

DEFAULT_PORT=16261
UDP_PORT=16262
STEAM_PORT1=8766
STEAM_PORT2=8767
RCON_PORT=27015

PUBLIC_DOMAIN=""
PUBLIC_IPV6=""
PLAYIT_TUNNEL=""

PLAYIT_ENABLED=true
```

Save this as `.env` and customize to your needs!
