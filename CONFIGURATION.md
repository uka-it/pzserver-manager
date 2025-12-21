# Advanced Configuration Guide

This guide is for advanced users who want to customize their server beyond the setup wizard or run scripts directly.

## 📑 Table of Contents

- [Running Scripts Directly](#running-scripts-directly)
- [Server Configuration Files](#server-configuration-files)
- [Environment Variables (.env)](#environment-variables-env)
- [Port Configuration](#port-configuration)
- [Multiple Servers](#multiple-servers)
- [Security Best Practices](#security-best-practices)

---

## 🚀 Running Scripts Directly

While the server manager (`./server-manager.sh`) provides a menu interface, you can run individual scripts directly for automation or scripting purposes.

### Server Control

```bash
# Start server with Playit.gg tunnel
./start-all.sh

# Start server without tunnel
./start-server-only.sh

# Stop everything (server + tunnel)
./stop-all.sh

# Stop server only (keep tunnel running)
./stop-server-only.sh

# View status
./status.sh
```

### Maintenance

```bash
# Update server files (current branch)
./update-server.sh

# Switch game branch
./list-branches.sh

# Clean cache and workshop files
./clean-cache.sh
```

### World Management

```bash
# Reset world (prompts for backup)
./reset-world.sh

# Manage backups (create/restore/delete)
./manage-backups.sh
```

### Configuration

```bash
# Edit server config files
./edit-server-config.sh

# Setup new server
./setup-new-server.sh

# Manage Playit.gg tunnels
./manage-playit.sh

# Uninstall components
./uninstall.sh
```

---

## 📝 Server Configuration Files

Server configuration files are located in `~/Zomboid/Server/pzserver/`

### pzserver.ini

Main server configuration file. Key settings:

```ini
# Server Identity
PublicName=My Server Name
PublicDescription=Server description shown in browser

# Access Control
AdminPassword=your-admin-password
Password=player-password-to-join
Open=true

# Player Limits
MaxPlayers=32
PVP=true

# Ports
DefaultPort=16261
UDPPort=16262

# RCON (Remote Console)
RCONPassword=rcon-password
RCONPort=27015
```

### pzserver_SandboxVars.lua

Gameplay and sandbox settings:

```lua
SandboxVars = {
    -- Zombie Settings
    Zombies = 4,  -- 1=Sprinters, 2=Fast Shamblers, 3=Shamblers, 4=Random
    Distribution = 1,  -- Zombie population
    Speed = 2,  -- Day speed

    -- Loot Settings
    LootRarity = 2,  -- 1=Extremely Rare, 2=Rare, 3=Normal, 4=Abundant

    -- Gameplay
    XpMultiplier = 1.0,
    StatsDecrease = 3,  -- Hunger/thirst rate

    -- More settings...
}
```

### Spawn Files

- **pzserver_spawnpoints.lua** - Define where players spawn
- **pzserver_spawnregions.lua** - Define spawn regions

### Editing Config Files

**Option 1: Use the built-in editor**
```bash
./server-manager.sh → [12] Edit server config files
```

**Option 2: Edit manually**
```bash
nano ~/Zomboid/Server/pzserver/pzserver.ini
```

**Note:** Restart the server for changes to take effect.

---

## 🔧 Environment Variables (.env)

The `.env` file allows you to override default settings. The setup wizard creates this file automatically, but advanced users can manually edit it.

### Creating .env File

```bash
# The setup wizard creates this for you, but you can also:
nano /home/liviouka/pzserver-manager/.env
```

### Available Variables

```bash
# Server Settings
SERVER_NAME="My PZ Server"
SERVER_DESCRIPTION="Server description"
ADMIN_PASSWORD="changeme123"
MAX_PLAYERS=32

# Installation Paths
INSTALL_DIR="$HOME/pzserver"
STEAMCMD_DIR="$INSTALL_DIR/steamcmd"

# Network Ports
DEFAULT_PORT=16261
UDP_PORT=16262
STEAM_PORT1=8766
STEAM_PORT2=8767
RCON_PORT=27015

# Public Access (for status display)
PUBLIC_DOMAIN=""  # e.g., "myserver.example.com"
PUBLIC_IPV6=""    # e.g., "2001:db8::1"
PLAYIT_TUNNEL=""  # e.g., "my-tunnel.gl.at.ply.gg:11128"

# Features
PLAYIT_ENABLED=true
```

### Configuration Loading Order

1. **Built-in defaults** from scripts
2. **.env file** overrides defaults
3. **Environment variables** override .env

### Example: Temporary Override

```bash
# Use different port for this session only
DEFAULT_PORT=17261 ./start-all.sh
```

---

## 🌐 Port Configuration

### Default Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 16261 | UDP | Main game port |
| 16262 | UDP | Secondary UDP port |
| 8766 | UDP | Steam authentication 1 |
| 8767 | UDP | Steam authentication 2 |
| 27015 | TCP | RCON (if enabled) |

### Changing Ports

**Option 1: During Setup**
The setup wizard will prompt for ports.

**Option 2: Edit .env**
```bash
nano .env
# Change:
DEFAULT_PORT=17261
UDP_PORT=17262
STEAM_PORT1=9766
STEAM_PORT2=9767
```

**Option 3: Edit pzserver.ini**
```bash
nano ~/Zomboid/Server/pzserver/pzserver.ini
# Change:
DefaultPort=17261
UDPPort=17262
```

### Firewall Rules

```bash
# Allow server ports
sudo ufw allow 16261/udp
sudo ufw allow 16262/udp
sudo ufw allow 8766/udp
sudo ufw allow 8767/udp

# If using RCON
sudo ufw allow 27015/tcp
```

---

## 🔀 Multiple Servers

To run multiple servers on the same machine, use different installation directories and ports.

### Setup Multiple Servers

```bash
# Server 1 (default)
INSTALL_DIR="$HOME/pzserver1" \
DEFAULT_PORT=16261 \
./setup-new-server.sh

# Server 2 (different ports)
INSTALL_DIR="$HOME/pzserver2" \
DEFAULT_PORT=17261 \
STEAM_PORT1=9766 \
./setup-new-server.sh
```

### Managing Multiple Servers

Create separate directories and run the manager from each:

```bash
# Server 1
cd ~/pzserver1
./server-manager.sh

# Server 2
cd ~/pzserver2
./server-manager.sh
```

**Note:** Each server needs unique ports and its own Playit.gg tunnels (if used).

---

## 🔒 Security Best Practices

### 1. Strong Passwords

```bash
# Generate strong random password
openssl rand -base64 32

# Set in pzserver.ini
AdminPassword=<generated-password>
RCONPassword=<different-password>
```

### 2. Protect Configuration Files

```bash
# Restrict .env permissions
chmod 600 .env

# Only you can read/write
ls -l .env
# Output: -rw------- 1 user user ...
```

### 3. RCON Security

If using RCON, bind to localhost only:

```ini
# In pzserver.ini
RCONBind=127.0.0.1
```

Then use SSH tunneling:
```bash
ssh -L 27015:localhost:27015 user@your-server
```

### 4. Regular Backups

```bash
# Use the backup manager
./manage-backups.sh

# Or automate with cron
0 2 * * * cd /home/liviouka/pzserver-manager && ./manage-backups.sh
```

### 5. Keep Server Updated

```bash
# Check for updates regularly
./server-manager.sh → [8] Update server files
```

### 6. Whitelist Mode

For private servers, enable whitelist:

```ini
# In pzserver.ini
Open=false
AutoCreateUserInWhiteList=false
```

Then manually add players via RCON or server files.

---

## 📚 Additional Resources

- **Project Zomboid Wiki:** https://pzwiki.net/wiki/Dedicated_server
- **Server Settings:** https://pzwiki.net/wiki/Server_Settings
- **Sandbox Options:** https://pzwiki.net/wiki/Sandbox_Options
- **RCON Commands:** https://pzwiki.net/wiki/Server_Commands

---

## 🆘 Advanced Troubleshooting

### Check Configuration Loading

```bash
# See what config is loaded
cd /home/liviouka/pzserver-manager
source ./config.sh
echo "Server: $SERVER_NAME"
echo "Port: $DEFAULT_PORT"
echo "Install Dir: $INSTALL_DIR"
```

### Verify Server Files

```bash
# Check if server is installed
ls -la $INSTALL_DIR/ProjectZomboid64

# Check server version
cat $INSTALL_DIR/ProjectZomboid64.json | grep version
```

### Test Port Binding

```bash
# Check if ports are in use
sudo lsof -i :16261
sudo lsof -i :16262
sudo lsof -i :8766
sudo lsof -i :8767

# Or use ss
ss -ulpn | grep 16261
```

### Reset to Defaults

```bash
# Remove custom config
rm .env

# Remove server config (will regenerate)
rm -rf ~/Zomboid/Server/pzserver/

# Reinstall
./setup-new-server.sh
```

---

**For basic usage, see the main [README.md](README.md)**
