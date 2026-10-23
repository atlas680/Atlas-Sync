# Atlas Drive Sync — User Guide & Technical Manual

This manual provides detailed instructions for deploying, configuring, and operating Atlas Drive Sync across Linux desktop environments and headless SSH servers.

## 1. Architectural Overview

Atlas Drive Sync replaces fragile FUSE filesystem mounts (such as google-drive-ocamlfuse or rclone mount) with an intelligent, state-tracking synchronization engine:
- Direct HTTPS Operations: Communicates with Google Drive v3 REST API directly. Files are uploaded in chunked streams and downloaded with verified byte checksums.
- State Tracking Database: Local SQLite database (`~/.config/atlas-drive-sync/sync_state.db`) records file modification timestamps, sizes, and remote file IDs to detect local additions, remote modifications, moves, and deletions accurately.
- Machine-Bound Security: All sensitive tokens are encrypted using `ATLAS_VAULT_V2` (PBKDF2-HMAC-SHA256 with 200,000 iterations, SHA256-CTR keystream encryption, and HMAC-SHA256 authentication). Moving encrypted files to another machine will not expose tokens.

## 2. Installation Details

### Standard Installation
Run the automated installer:
```bash
./install.sh
```

The script performs the following actions:
- Checks for Python 3.8+.
- Prepares an isolated virtual environment at `~/.local/share/atlas-drive-sync/venv`.
- Installs `requests` (for headless server CLI) and `PySide6` (if a graphical display server is detected).
- Adds `~/.local/bin/atlas-sync` and ensures `PATH` is updated in `~/.bashrc` and `~/.zshrc`.
- Generates a desktop entry at `~/.local/share/applications/atlas-drive-sync.desktop`.

### Manual / Custom Python Environment
If you prefer to run inside an existing virtual environment:
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install requests PySide6
./main.py
```

## 3. Licensing Model

Every license key is cryptographically signed and bound to two attributes:
1. Machine Hardware ID (HWID): Derived from CPU signature, motherboard serial/UUID, and system machine ID.
2. Google Drive Email: Bound to the Google account authenticated with the installation.

This prevents unauthorized redistribution where a single license key is shared across multiple machines or accounts.

### Checking License Status
In any terminal:
```bash
atlas-sync list
```

Sample output:
```
==================================================================
 Atlas Drive Sync — Status, License and Folder Pairings
==================================================================
 Machine HWID     : RXFJ-JNJA-N57H-UZRP
 License Status   : License Active (PRO — Device: RXFJ-JNJA-N57H-UZRP)
 Google Session   : Connected (user@example.com)
 Token Encryption : Active (ATLAS_VAULT_V2 / PBKDF2-SHA256)
 Conflict Policy  : newest
------------------------------------------------------------------
 [1] (ACTIVE) /home/user/Work  <-->  Drive:/Work  [bidirectional]
==================================================================
```

## 4. Multi-Folder Pair Configuration

You can configure multiple independent local folders mapped to different remote folders.

### Via Desktop GUI
1. Navigate to the "Synchronization" tab.
2. Click "Add Folder Pair".
3. Select the local directory from the filesystem browser.
4. Select or type the target Google Drive folder path (e.g., `/Backups/Projects`).
5. Choose the synchronization mode:
   - Bidirectional: Changes on both sides are synchronized.
   - Upload Only: Local changes are uploaded to Google Drive; remote modifications are not downloaded.
   - Download Only: Remote changes are downloaded locally; local modifications are not uploaded.

### Via Terminal CLI
Add folder mappings using `atlas-sync add`:
```bash
# Add a bidirectional folder pair:
atlas-sync add ~/Documents /Documents --mode bidirectional

# Add an upload-only backup folder:
atlas-sync add ~/Projects /CloudProjects --mode upload_only

# Add a download-only shared folder:
atlas-sync add ~/SharedAssets /Assets --mode download_only
```

List configured mappings:
```bash
atlas-sync list
```

Remove a mapping by index:
```bash
atlas-sync remove 2
```

## 5. Synchronization & Conflict Handling

### Conflict Policies
Configurable in the "Settings" page of the GUI:
- Enforce Newest (Default): Compares file modification timestamps; the most recently modified file takes precedence.
- Keep Both: Renames the conflicting local file with a `_conflict_YYYYMMDD_HHMMSS` suffix and retains both versions.
- Local Wins: Overwrites remote file with local file on conflict.
- Remote Wins: Overwrites local file with remote file on conflict.

### Deletion Propagation & Trash Safety
When a file is deleted remotely, Atlas Drive Sync moves the local file to a local trash archive (`~/.config/atlas-drive-sync/local_trash`) rather than deleting it permanently. You can restore trashed files at any time via the "Activity Logs -> Local Trash" panel.

## 6. Running Headless on Linux Servers (Systemd Service)

To run continuous periodic synchronization on a server without an active user session, create a user systemd service:

1. Create service directory:
   ```bash
   mkdir -p ~/.config/systemd/user
   ```

2. Create service file `~/.config/systemd/user/atlas-sync.service`:
   ```ini
   [Unit]
   Description=Atlas Drive Sync Background Daemon
   After=network-online.target
   Wants=network-online.target

   [Service]
   Type=simple
   ExecStart=%h/.local/bin/atlas-sync daemon --interval 5
   Restart=on-failure
   RestartSec=30

   [Install]
   WantedBy=default.target
   ```

3. Enable and start the service:
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now atlas-sync.service
   ```

4. View service status and live logs:
   ```bash
   systemctl --user status atlas-sync.service
   journalctl --user -u atlas-sync.service -f
   ```

## 7. Configuration Files & Locations

All application state is stored inside the user configuration directory:
- Path: `~/.config/atlas-drive-sync/`
- `settings.json`: Folder pairs, sync interval, conflict policy, ignore patterns.
- `auth_token.json`: Encrypted OAuth credentials envelope (`ATLAS_VAULT_V2`).
- `license.vault`: Encrypted machine-bound license certificate.
- `sync_state.db`: SQLite database tracking synced files and hashes.
- `atlas_sync.log`: Rolling application log file.
- `local_trash/`: Local backup archive for deleted or replaced files.

## 8. Troubleshooting

### Issue: Graphical window does not open over SSH or minimal desktop
Explanation: Desktop mode requires an active X11 or Wayland session. If no graphical environment exists, run via CLI:
```bash
atlas-sync
```

### Issue: Google OAuth redirect does not open on server
Explanation: Use `atlas-sync login` in the terminal. It provides an authentication URL to open in any web browser and accepts the redirect URL pasted directly back into the terminal.

### Issue: Permission denied during installation
Solution: Ensure user write permissions on home directory and execute permissions on scripts:
```bash
chmod +x install.sh drive-sync.sh atlas-sync.sh
```

### Issue: Inotify watcher limit reached
Explanation: For very large local directory trees, increase the Linux inotify user limit:
```bash
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```
