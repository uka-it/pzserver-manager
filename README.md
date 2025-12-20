# 🧟 Project Zomboid Dedicated Server Manager

A comprehensive, beautiful CLI management suite for Project Zomboid dedicated servers on Linux.

![Project Zomboid](https://img.shields.io/badge/Project%20Zomboid-Dedicated%20Server-red)
![License](https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-orange)
![Platform](https://img.shields.io/badge/platform-Linux-blue)
![Non-Commercial](https://img.shields.io/badge/use-non--commercial-green)

## ✨ Features

### 🎮 Beautiful CLI Interface
- **Retro ASCII Art** - Red Project Zomboid logo with CRT green "Dedicated Server"
- **Color-Coded Menus** - Cyan borders, yellow headers, green options
- **Real-time Status** - Live server/tunnel status display
- **Interactive Prompts** - User-friendly navigation

### 🚀 Automated Setup
- **One-Command Installation** - Complete server setup from scratch
- **Dependency Management** - Auto-installs SteamCMD, Playit.gg, system packages
- **Branch Selection** - Choose Stable, 42.13.1, or Unstable
- **Configuration Wizard** - Interactive server configuration

### 🔧 Server Management
- **Start/Stop/Restart** - Full server control with background execution
- **Branch Switching** - Dynamic branch selection from Steam
- **Auto-Updates** - Update to latest version of current branch
- **Cache Cleaning** - Remove workshop files, logs, backups

### 🌍 World Management
- **World Reset** - Fresh start with backup option
- **Backup Manager** - View, restore, delete world backups
- **Safe Restoration** - Auto-creates safety backup before restore

### 📊 Monitoring
- **Live Logs** - View server/console logs with `less +F`
- **Status Dashboard** - Server, Playit.gg, branch info
- **Log Viewer** - Server output, game console, or combined view

### 🌐 Network Tunneling
- **Playit.gg Integration** - Built-in tunneling for CGNAT/NAT
- **Auto-Setup** - Guided Playit.gg configuration
- **Status Monitoring** - Real-time tunnel status

## 📦 Installation

### Prerequisites
- Debian/Ubuntu Linux
- Sudo access
- Internet connection

### Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/pzserver-manager.git
cd pzserver-manager

# Run the automated setup
./setup-new-server.sh
```

The setup script will:
1. Install system dependencies (lib32gcc-s1, curl)
2. Download and install SteamCMD
3. Ask for your server preferences
4. Download Project Zomboid server files
5. Create initial configuration
6. Optionally install Playit.gg

### Manual Installation

If you prefer manual setup:

```bash
# 1. Clone repository
git clone https://github.com/yourusername/pzserver-manager.git
cd pzserver-manager

# 2. Make scripts executable
chmod +x *.sh

# 3. Install dependencies
sudo apt update
sudo apt install -y lib32gcc-s1 curl

# 4. Run setup
./setup-new-server.sh
```

## 🎯 Usage

### Main Menu

Launch the management console:

```bash
./server-manager.sh
```

**Menu Options:**

**⚙ SERVER CONTROL**
- `[1]` Start server (with Playit.gg)
- `[2]` Stop server (and Playit.gg)
- `[3]` Restart server
- `[4]` View server status

**🔧 MAINTENANCE**
- `[5]` Update server files
- `[6]` Switch game branch/version
- `[7]` Clean cache & workshop files
- `[8]` Setup new server (automated install)

**🌍 WORLD MANAGEMENT**
- `[9]` Reset world (fresh start)
- `[10]` Manage backups (view/restore/delete)

**📋 OTHER**
- `[11]` View server logs (live)
- `[12]` Exit

### Individual Scripts

You can also run scripts directly:

```bash
# Start server
./start-all.sh

# Stop server
./stop-all.sh

# View status
./status.sh

# Switch branches
./list-branches.sh

# Update server
./update-server.sh

# Clean cache
./clean-cache.sh

# Reset world
./reset-world.sh

# Manage backups
./manage-backups.sh
```

## 📁 File Structure

```
pzserver-manager/
├── README.md                   # This file
├── server-manager.sh          # Main management console
├── setup-new-server.sh        # Automated installation
├── start-all.sh               # Start server + Playit.gg
├── stop-all.sh                # Stop all services
├── status.sh                  # Show server status
├── list-branches.sh           # Dynamic branch switcher
├── switch-branch.sh           # Manual branch switcher
├── update-server.sh           # Update current branch
├── clean-cache.sh             # Cache/workshop cleaner
├── reset-world.sh             # World reset tool
├── manage-backups.sh          # Backup manager
├── start-pzserver.sh          # PZ server starter
├── start-ipv6-proxy.sh        # IPv6 proxy (optional)
└── stop-ipv6-proxy.sh         # Stop IPv6 proxy
```

## 🔑 Default Configuration

After installation, your server will have these defaults:

- **Server Name:** ShadowZombie Server
- **Admin Password:** changeme123
- **Max Players:** 32
- **Main Port:** 16261 (UDP)
- **Secondary Port:** 16262 (UDP)
- **Steam Ports:** 8766, 8767 (UDP)

**⚠️ IMPORTANT:** Change the admin password in:
```
~/.local/share/Zomboid/Server/pzserver/pzserver.ini
```

## 🌐 Playit.gg Tunneling

If you're behind CGNAT/NAT, use Playit.gg for tunneling:

### Setup Tunnels

1. Run: `playit setup`
2. Create 4 UDP tunnels:
   - Port 16261 → Main server
   - Port 16262 → Secondary
   - Port 8766 → Steam 1
   - Port 8767 → Steam 2

3. Share your Playit.gg address with players:
   ```
   your-tunnel.gl.at.ply.gg:PORT
   ```

## 🎨 Features Showcase

### Beautiful ASCII Art Header
```
Red "PROJECT ZOMBOID" logo + Green CRT "Dedicated Server" subtitle
```

### Color-Coded Status
- 🟢 Green: Server RUNNING
- 🔴 Red: Server STOPPED
- 🟡 Yellow: Playit.gg STOPPED

### Branch Auto-Detection
Shows current branch in status: `UNSTABLE (Build 42)`, `Build 42.13.1`, `STABLE (Build 41)`

### Dynamic Size Calculation
Cache cleaner shows actual sizes, not hardcoded values

### Log Viewer with 'q' to Exit
No more Ctrl+C issues - press 'q' to return to menu

## 🛠️ Troubleshooting

### Server won't start
```bash
# Check logs
tail -50 server.log

# Or use the menu
./server-manager.sh
# Choose [11] View server logs
```

### Playit.gg not working
```bash
# Check if running
pgrep playit

# Restart
pkill playit
playit start
```

### Branch switch failed
```bash
# Verify current branch
cat steamapps/appmanifest_380870.acf | grep BetaKey

# Clean and retry
./clean-cache.sh
./list-branches.sh
```

### Port conflicts
```bash
# Check what's using ports
sudo lsof -i :16261
sudo lsof -i :16262
```

## 📝 Logs Location

- **Server output:** `~/pzserver/server.log`
- **Playit.gg:** `~/pzserver/playit.log`
- **Game console:** `~/Zomboid/Logs/*/console.txt`

## 🔄 Updating the Server

The manager will auto-detect your current branch and update to the latest version:

```bash
./server-manager.sh
# Choose [5] Update server files
```

Or directly:
```bash
./update-server.sh
```

## 🗑️ Uninstallation

To completely remove the server:

```bash
# Stop services
./stop-all.sh

# Remove server files
rm -rf ~/pzserver

# Remove server data
rm -rf ~/Zomboid

# Remove Playit.gg (optional)
sudo apt remove playit
```

## 🤝 Contributing

Contributions welcome! Please feel free to submit a Pull Request.

## 📄 License

**CC BY-NC-SA 4.0** - Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International

### ✅ You ARE allowed to:
- Use for personal/non-commercial purposes
- Modify and improve the code
- Share with others
- Create derivative works

### ❌ You are NOT allowed to:
- Use commercially without permission
- Sell or profit from this software
- Use in commercial products/services

### 💼 Commercial Licensing
For commercial use, please contact the author for licensing arrangements.

See [LICENSE](LICENSE) file for full terms.

## 🙏 Credits

- **Project Zomboid** - The Indie Stone
- **Playit.gg** - Tunneling service
- **SteamCMD** - Valve Corporation

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/pzserver-manager/issues)
- **Wiki:** [Project Zomboid Wiki](https://pzwiki.net/wiki/Dedicated_server)

## ⚡ Quick Reference

```bash
# Start server
./server-manager.sh → [1]

# Stop server
./server-manager.sh → [2]

# View logs
./server-manager.sh → [11] → [1/2/3]

# Switch branch
./server-manager.sh → [6]

# Backup world
./server-manager.sh → [10]

# Reset world
./server-manager.sh → [9]
```

---

**Made with 💀 for the Project Zomboid community**
