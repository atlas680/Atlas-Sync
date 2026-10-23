#!/usr/bin/env bash
# ==============================================================================
# Atlas Drive Sync v2.5 — Müşteri Dağıtım / Tak-Çalıştır Kurulum Betiği (Linux)
# Masaüstü ve Uzak SSH Sunucular için tek komutla kurulum yapar.
# ==============================================================================
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$APP_DIR/drive-sync.sh" "$APP_DIR/atlas-sync.sh" "$APP_DIR/main.py"

mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"

cat > "$HOME/.local/bin/atlas-sync" <<EOF
#!/usr/bin/env bash
if [[ \$# -eq 0 ]]; then
    exec "$APP_DIR/drive-sync.sh" --sync-now
else
    exec "$APP_DIR/drive-sync.sh" "\$@"
fi
EOF
chmod +x "$HOME/.local/bin/atlas-sync"

# PATH içinde ~/.local/bin yoksa kabuk profil dosyalarına ekle
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$rc" ]] && ! grep -q '.local/bin' "$rc" 2>/dev/null; then
        printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$rc"
    fi
done

# Masaüstü kısayolu oluştur
cat > "$HOME/.local/share/applications/atlas-drive-sync.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Atlas Drive Sync
Comment=Direct HTTPS Google Drive Multi-Folder Synchronization
Exec=$APP_DIR/drive-sync.sh
Icon=folder-cloud
Terminal=false
Categories=Network;FileTransfer;Utility;
StartupNotify=true
EOF

# Bağımlılık kontrolü / kurulumu için durum sorgusunu çalıştır
"$APP_DIR/drive-sync.sh" --list

echo ""
echo "=================================================================="
echo " Atlas Drive Sync Installation Completed!"
echo " - Desktop GUI       : $APP_DIR/drive-sync.sh"
echo " - Terminal Sync     : atlas-sync"
echo " - SSH OAuth Sign-In : atlas-sync login"
echo "=================================================================="
