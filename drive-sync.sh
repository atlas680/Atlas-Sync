#!/usr/bin/env bash
# ==============================================================================
# Atlas Drive Sync v2.5 (Ticari Sürüm) — Evrensel Linux Tak-Çalıştır Başlatıcı
# - Herhangi bir Linux dağıtımında (Masaüstü veya Uzak SSH Sunucu) ek ayar
#   gerektirmeden sanal ortamı ve bağımlılıkları otomatik hazırlar.
# - Masaüstü varsa arayüzü açar, SSH/Terminal ortamındaysa doğrudan eşitler.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/main.py" ]]; then
    APP_DIR="$SCRIPT_DIR"
elif [[ -f "$HOME/G-Yazılım/Projeler/AtlasDriveSync/main.py" ]]; then
    APP_DIR="$HOME/G-Yazılım/Projeler/AtlasDriveSync"
elif [[ -f "$HOME/AtlasDriveSync/main.py" ]]; then
    APP_DIR="$HOME/AtlasDriveSync"
else
    FOUND_MAIN="$(find "$HOME" -maxdepth 4 -name "main.py" -path "*AtlasDriveSync*" 2>/dev/null | head -n 1 || true)"
    if [[ -n "$FOUND_MAIN" ]]; then
        APP_DIR="$(dirname "$FOUND_MAIN")"
    else
        echo "Error: AtlasDriveSync application folder not found." >&2
        exit 1
    fi
fi

# Grafik ekran (X11/Wayland) kontrolü ve CLI modu tespiti
NEED_GUI=1
if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
    NEED_GUI=0
fi
for arg in "$@"; do
    case "$arg" in
        --sync-now|--login|--list|--daemon|sync|esitle|eşitle|login|list|status|add|remove|daemon|activate|license|lisans|hwid|cihaz)
            NEED_GUI=0
            ;;
    esac
done

# Uygun Python yorumlayıcısını seç veya Tak-Çalıştır kurulum yap
SHARED_VENV="$HOME/.local/share/atlas-drive-sync/venv"
PYTHON_BIN=""

check_python_env() {
    local py="$1"
    [[ -x "$py" ]] || return 1
    if [[ "$NEED_GUI" -eq 1 ]]; then
        "$py" -c "import requests, PySide6" >/dev/null 2>&1
    else
        "$py" -c "import requests" >/dev/null 2>&1
    fi
}

for candidate in \
    "$APP_DIR/.venv/bin/python3" \
    "$SHARED_VENV/bin/python3" \
    "$HOME/atlasvenv/bin/python3" \
    "$(command -v python3 || true)"; do
    if [[ -n "$candidate" ]] && check_python_env "$candidate"; then
        PYTHON_BIN="$candidate"
        break
    fi
done

# Eğer hazır ortam yoksa otomatik Tak-Çalıştır (Plug & Play) kurulumu başlat
if [[ -z "$PYTHON_BIN" ]]; then
    echo "[Atlas Drive Sync] First run detected — configuring dependencies automatically..."
    mkdir -p "$(dirname "$SHARED_VENV")"
    if [[ ! -x "$SHARED_VENV/bin/python3" ]]; then
        python3 -m venv "$SHARED_VENV"
    fi
    "$SHARED_VENV/bin/pip" install --upgrade pip >/dev/null 2>&1 || true
    if [[ "$NEED_GUI" -eq 1 ]]; then
        echo "[Atlas Drive Sync] Installing desktop UI components (PySide6 & requests)..."
        "$SHARED_VENV/bin/pip" install --quiet requests PySide6
    else
        echo "[Atlas Drive Sync] Installing server/SSH terminal components (requests)..."
        "$SHARED_VENV/bin/pip" install --quiet requests
    fi
    PYTHON_BIN="$SHARED_VENV/bin/python3"
fi

# Terminal 'atlas-sync' komutunu ~/.local/bin içine otomatik kaydet
mkdir -p "$HOME/.local/bin"
if [[ ! -x "$HOME/.local/bin/atlas-sync" ]]; then
    cat > "$HOME/.local/bin/atlas-sync" <<EOF
#!/usr/bin/env bash
if [[ \$# -eq 0 ]]; then
    exec "$APP_DIR/drive-sync.sh" --sync-now
else
    exec "$APP_DIR/drive-sync.sh" "\$@"
fi
EOF
    chmod +x "$HOME/.local/bin/atlas-sync"
fi

export PYTHONUNBUFFERED=1
cd "$APP_DIR"
exec "$PYTHON_BIN" "$APP_DIR/main.py" "$@"
