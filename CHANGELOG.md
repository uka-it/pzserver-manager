# Changelog

All notable changes to this project are listed here.
Versions follow [Semantic Versioning](https://semver.org/): MAJOR.MINOR.PATCH.

## [Unreleased]

### Changed
- Release workflow uses `actions/checkout@v5` (v4 runs on a deprecated Node.js version).

### Added
- Buy Me a Coffee links in the README and a GitHub Sponsor button.
- README screenshot of the v2.0.0 menu.

## [2.0.0] - 2026-10-25

### Added
- **Docker support**: `Dockerfile`, `docker-compose.yml` and an entrypoint that installs the server on first start, keeps the container running while you stop/start the server from the menu, and saves the world on `docker stop`. Data lives in named volumes (game files, saves, manager state).
- **Server memory setting** (`SERVER_MEMORY` in `.env`): setup asks for it (with a recommendation based on available RAM, including Docker limits) and the new menu option **[14] Set server memory** changes it. It is applied on every start, so Steam updates no longer reset it.
- **Existing servers**: new `PZ_SERVER_NAME` setting for servers that don't use the name `pzserver`, and a README guide for taking over a running server, with or without Docker.
- Non-interactive setup mode (`PZ_NONINTERACTIVE=1`), used by Docker.
- `HOST_IP` setting to show the right address in the menu when running in Docker.
- The manager version is shown in the main menu.

### Changed
- **Menu numbering**: options after [13] moved down by one to make room for [14] Set server memory: Reset world is now [15], Manage backups [16], View logs [17], Uninstall [18].
- Game branch is shown as the real Steam branch plus the actual game version reported by the server (e.g. `public (v42.21.0)`) instead of fixed labels such as "STABLE (Build 41)".
- Branch menus in setup and branch switching list the descriptions Steam reports; `switch-branch.sh` asks for a branch name instead of offering a fixed (outdated) list.
- Running setup on an existing server keeps its `.ini` (backed up first; only name, description, max players and ports are updated) and keeps the existing admin account.
- The server process is matched by its exact `-servername`, so other servers on the same machine are no longer mistaken for this one.
- Memory shown on the start screens and in the menu is read from the real setting instead of a fixed "8GB".
- Box drawing no longer needs python3 and gives the same result everywhere.

### Fixed
- Stopping the server now waits for the world to finish saving (up to 60s) instead of 3 seconds. Reset world and clean cache no longer delete files while the server is still saving.
- Log viewer: `q` now exits as shown on screen (previously only Ctrl+C then `q` worked), the game console view finds `server-console.txt`, and the combined view no longer leaves a background process running.
- Status screen "Listening Ports" showed the remote address (`0.0.0.0:*`) instead of the ports; it now lists each port and whether it is listening.
- Main menu memory always showed "8G (default)" because the setting was never found.
- Misaligned box borders on lines with ● and ⚙ when python3 is not installed; misaligned "Server Status" value.
- Branch descriptions could be taken from the wrong branch (e.g. `public` shown as "Unstable").

## [1.0.0] - 2025-12-21

First release: an interactive manager for a Project Zomboid dedicated server on Linux.

- Main menu (`server-manager.sh`) with server status, branch, IP, ports and memory
- Automated setup: dependencies, SteamCMD, server download, branch selection from Steam, `.env` configuration (with reuse of an existing `.env`)
- Start, stop, restart and status, with or without the Playit.gg tunnel
- Playit.gg install, setup, start/stop and tunnel overview
- Update server files and switch game branch, with optional world backup
- Server config editor (INI, sandbox variables, spawn points and regions)
- Reset admin password, reset world, manage backups (view/restore/delete)
- Clean cache and workshop files, live log viewer, uninstall
- Admin password used only on first start and then removed from `.env`

[2.0.0]: https://github.com/uka-it/pzserver-manager/releases/tag/v2.0.0
[1.0.0]: https://github.com/uka-it/pzserver-manager/releases/tag/v1.0.0
