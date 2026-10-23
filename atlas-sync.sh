#!/usr/bin/env bash
# ==============================================================================
# Atlas Drive Sync — Uzak SSH / Terminal Hızlı Eşitleme Komutu (atlas-sync)
# Parametresiz çalıştırıldığında doğrudan tüm aktif klasörleri eşitler!
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -x "$SCRIPT_DIR/drive-sync.sh" ]]; then
    LAUNCHER="$SCRIPT_DIR/drive-sync.sh"
elif [[ -x "$HOME/G-Yazılım/Projeler/AtlasDriveSync/drive-sync.sh" ]]; then
    LAUNCHER="$HOME/G-Yazılım/Projeler/AtlasDriveSync/drive-sync.sh"
elif [[ -x "$HOME/drive-sync.sh" ]]; then
    LAUNCHER="$HOME/drive-sync.sh"
else
    echo "Error: drive-sync.sh not found." >&2
    exit 1
fi

if [[ $# -eq 0 ]]; then
    exec "$LAUNCHER" --sync-now
else
    exec "$LAUNCHER" "$@"
fi
