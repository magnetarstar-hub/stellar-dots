#!/usr/bin/env bash
set -euo pipefail

mode="${1:-toggle}"
current="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || true)"

case "$mode" in
    toggle)
        if [[ "$current" == *prefer-light* ]]; then
            mode="dark"
        else
            mode="light"
        fi
        ;;
    dark|light)
        ;;
    *)
        echo "Usage: theme-mode.sh {toggle|dark|light}" >&2
        exit 2
        ;;
esac

if [[ "$mode" == "light" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    gsettings set org.gnome.desktop.interface gtk-theme Adwaita
else
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface gtk-theme catppuccin-mocha-sapphire-standard+default
fi

wallpaper="$(swww query 2>/dev/null | sed -n 's/.*image: //p' | head -n 1)"
if [[ -n "$wallpaper" && -f "$wallpaper" ]]; then
    /home/sam/.config/hypr/scripts/wallpaper-theme.sh "$wallpaper"
else
    /home/sam/.config/hypr/scripts/wallpaper-theme.sh
fi
