# Atlas Drive Sync

High-performance Google Drive synchronization client for Linux desktop and headless server environments. Operates directly over HTTPS without FUSE virtual filesystem overhead.

## Key Features

- Direct HTTPS Transfers: Chunked resumable file transfers directly to Google Drive API. No FUSE overhead, no kernel mount instabilities.
- Multi-Folder Pairings: Configure multiple local directories mapped to different Google Drive remote directories simultaneously.
- Dual Operating Modes: Clean graphical desktop application (Qt6 / PySide6) and full-featured headless terminal CLI (`atlas-sync`).
- Flexible Sync Modes: Bidirectional synchronization, upload-only, or download-only per folder mapping.
- Conflict Resolution Policies: Supports newest-file priority, automatic copy retention, or single-source priority rules.
- Real-Time Watcher & Periodic Daemon: Kernel inotify file monitoring with debounced triggers, plus continuous background daemon mode.
- Trash Protection: Remote file deletions are safely backed up to local trash before removal, allowing immediate restoration.
- Machine-Bound Encryption: OAuth tokens and secrets encrypted with PBKDF2-HMAC-SHA256 (200,000 rounds) + SHA256-CTR keystream bound to local machine hardware.
- Universal Linux Setup: Self-bootstrapping installer supporting Ubuntu, Debian, Fedora, Arch Linux, CentOS, Rocky Linux, and derivatives.

## System Requirements

- Operating System: Any Linux distribution (kernel 3.10+ recommended).
- Architecture: x86_64, aarch64, or armv7l.
- Python: Python 3.8 or newer (standard system installation or virtual environment).
- Desktop GUI Mode: X11 or Wayland display server with PySide6 (auto-installed in isolated venv by install script).
- Headless Server Mode: Minimal dependencies only (`requests`), no graphical or display libraries required.

## Installation

Extract the package or clone the repository to your chosen location:

```bash
cd AtlasDriveSync
chmod +x install.sh drive-sync.sh atlas-sync.sh
./install.sh
```

The installation script:
1. Validates the environment and prepares an isolated virtual environment (`~/.local/share/atlas-drive-sync/venv`).
2. Installs required runtime packages.
3. Configures the `atlas-sync` command in `~/.local/bin/atlas-sync` for terminal access.
4. Creates a desktop application launcher for desktop environments.

## License Activation

Atlas Drive Sync uses hardware-bound and Google Account-bound licensing to ensure each license is tied to an authorized workstation or server.

### Option 1: Desktop GUI Activation
1. Launch the application:
   ```bash
   ./drive-sync.sh
   ```
2. The License Activation dialog opens on first run, showing your 16-character Hardware ID (HWID).
3. Paste your license key (`ATLAS-PRO-...` or Gumroad license key) and click "Verify and Lock to Device".

### Option 2: Headless SSH Server Activation
1. View your machine Hardware ID:
   ```bash
   atlas-sync hwid
   ```
2. Activate your license key:
   ```bash
   atlas-sync activate <YOUR_LICENSE_KEY>
   ```

## Google Account Authentication

### Desktop Workflow
Click "Login" in the bottom-left sidebar panel. The system will launch your default web browser to complete standard Google OAuth 2.0 consent.

### Headless SSH Workflow
1. Run:
   ```bash
   atlas-sync login
   ```
2. Open the printed Google authentication URL in any browser on your workstation.
3. Sign in and approve Google Drive permissions.
4. When redirected to `http://localhost:53682/?code=...`, copy the entire address from your browser address bar.
5. Paste the address into the SSH terminal prompt and press Enter.

## CLI Command Reference

The `atlas-sync` CLI tool is available across all terminal sessions:

| Command | Action |
| :--- | :--- |
| `atlas-sync` | Immediately runs synchronization across all active folder pairs |
| `atlas-sync list` | Displays system status, license validity, HWID, and configured pairs |
| `atlas-sync hwid` | Prints the 16-character machine Hardware ID |
| `atlas-sync activate <KEY>` | Validates and activates a license key on this machine |
| `atlas-sync login` | Performs terminal-based Google OAuth authentication |
| `atlas-sync add <LOCAL> <DRIVE> [--mode ...]` | Adds a new folder mapping (modes: `bidirectional`, `upload_only`, `download_only`) |
| `atlas-sync remove <INDEX>` | Removes a configured folder pair by index |
| `atlas-sync daemon [--interval MINUTES]` | Runs continuous periodic synchronization in background |

For comprehensive configuration guides, folder mapping examples, and troubleshooting, consult `USER_GUIDE.md`.
