#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# stellar-dots restore
# Restores ~/.config/{hypr,waybar,kitty,btop,fastfetch,fish} from
# the most recent stellar-dots-backup-* folder created by install.sh
# Usage: ./restore.sh [backup-folder-name]
# ─────────────────────────────────────────────────────────────
set -euo pipefail

CONFIG="$HOME/.config"

if [[ $# -ge 1 ]]; then
    BACKUP_DIR="$CONFIG/$1"
else
    BACKUP_DIR="$(find "$CONFIG" -maxdepth 1 -name 'stellar-dots-backup-*' -type d | sort | tail -n1)"
fi

if [[ -z "${BACKUP_DIR:-}" || ! -d "$BACKUP_DIR" ]]; then
    echo "!! No backup found. Looked for ~/.config/stellar-dots-backup-* folders." >&2
    echo "   Available backups:" >&2
    find "$CONFIG" -maxdepth 1 -name 'stellar-dots-backup-*' -type d 2>/dev/null || echo "   (none)"
    exit 1
fi

echo "==> Restoring from $BACKUP_DIR"
read -rp "This will overwrite current hypr/waybar/kitty/btop/fastfetch/fish configs. Continue? [y/N] " CONFIRM
if [[ "${CONFIRM,,}" != "y" ]]; then
    echo "Aborted."
    exit 0
fi

for d in hypr waybar kitty btop fastfetch fish; do
    if [[ -e "$BACKUP_DIR/$d" ]]; then
        rm -rf "$CONFIG/$d"
        cp -r "$BACKUP_DIR/$d" "$CONFIG/$d"
        echo "    restored $d"
    fi
done

echo "==> Done. Run 'hyprctl reload' or re-login to apply."
