#!/bin/bash
# ~/.config/hypr/scripts/wallpaper.sh

exec >> /tmp/wallpaper.log 2>&1
echo "=== $(date) ==="

# Prevent double-run (waypaper calls once per monitor)
[ -f /tmp/wal.lock ] && exit 0
touch /tmp/wal.lock
trap "rm -f /tmp/wal.lock" EXIT

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.local/bin"

# Wait for waypaper to finish writing the new wallpaper to its config
sleep 1

# Read current wallpaper from waypaper config
WALLPAPER=$(grep "^wallpaper" "$HOME/.config/waypaper/config.ini" | head -1 | cut -d= -f2 | xargs)
WALLPAPER="${WALLPAPER/#\~/$HOME}"

echo "Detected wallpaper: $WALLPAPER"

if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
    echo "ERROR: wallpaper file not found: $WALLPAPER"
    exit 1
fi

# ── 1. Extract colors with pywal ────────────────────────────
wal -i "$WALLPAPER" -n -q

# ── 2. Reload waybar ────────────────────────────────────────
killall -w waybar
waybar &

# ── 3. Reload swaync theme ──────────────────────────────────
swaync-client --reload-css

# ── 4. Reload hyprland border colors ────────────────────────
python3 - <<'PYEOF'
import json, subprocess, os

cache = os.path.expanduser("~/.cache/wal/colors.json")
if not os.path.exists(cache):
    exit()

with open(cache) as f:
    data = json.load(f)

c1       = data["colors"]["color4"].replace("#", "") + "ff"
c2       = data["colors"]["color2"].replace("#", "") + "ff"
inactive = data["colors"]["color0"].replace("#", "") + "aa"

subprocess.run(["hyprctl", "keyword", "general:col.active_border",
                f"rgba({c1}) rgba({c2}) 45deg"])
subprocess.run(["hyprctl", "keyword", "general:col.inactive_border",
                f"rgba({inactive})"])
PYEOF