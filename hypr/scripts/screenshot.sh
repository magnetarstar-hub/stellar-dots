#!/usr/bin/env bash
set -euo pipefail

mode="${1:-region}"
screenshot_dir="$HOME/Pictures/Screenshots"
timestamp="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$screenshot_dir"

exec 9>"${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/screenshot-taker.lock"
flock -n 9 || exit 0

case "$mode" in
    region)
        input_file="$(mktemp --suffix=.png)"
        trap 'rm -f "$input_file"' EXIT
        grim -g "$(slurp)" "$input_file"
        satty \
            --filename "$input_file" \
            --resize smart \
            --floating-hack \
            --title "Screenshot" \
            --copy-command wl-copy \
            --output-filename "$screenshot_dir/screenshot-$timestamp.png" \
            --actions-on-enter save-to-clipboard \
            --actions-on-escape exit \
            --initial-tool pointer
        ;;
    output)
        grim - | wl-copy
        ;;
    region-save)
        grim -g "$(slurp)" "$screenshot_dir/screenshot-$timestamp.png"
        ;;
    window)
        hyprshot -m window --clipboard-only
        ;;
    *)
        echo "Usage: screenshot.sh {region|output|region-save|window}" >&2
        exit 2
        ;;
esac
