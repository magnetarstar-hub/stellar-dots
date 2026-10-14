#!/usr/bin/env bash
set -euo pipefail

config_dir="$HOME/.config"
cache_dir="$HOME/.cache/walltheme"
mkdir -p "$cache_dir"
mkdir -p "$HOME/.cache/awww"

wallpaper=""
startup=false
if [[ "${1:-}" == "--startup" ]]; then
    startup=true
elif [[ -n "${1:-}" ]]; then
    wallpaper="$1"
fi
if [[ -z "$wallpaper" ]]; then
    wallpaper="$(python3 - <<'PY'
import configparser
import os

path = os.path.expanduser("~/.config/waypaper/config.ini")
parser = configparser.ConfigParser()
parser.read(path)
wallpaper = parser.get("Settings", "wallpaper", fallback="")
print(os.path.expanduser(wallpaper.strip()))
PY
)"
fi

if [[ ! -f "$wallpaper" ]]; then
    echo "wallpaper-theme: wallpaper not found: $wallpaper" >&2
    exit 1
fi

gtk_mode="dark"
if [[ "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || true)" == *prefer-light* ]]; then
    gtk_mode="light"
fi

read -r transition_type transition_step transition_angle transition_duration transition_fps < <(
    python3 - <<'PY'
import configparser
import os

parser = configparser.ConfigParser()
parser.read(os.path.expanduser("~/.config/waypaper/config.ini"))
settings = parser["Settings"]
print(
    settings.get("swww_transition_type", "simple"),
    settings.get("swww_transition_step", "90"),
    settings.get("swww_transition_angle", "0"),
    settings.get("swww_transition_duration", "3"),
    settings.get("swww_transition_fps", "30"),
)
PY
)

# Waypaper handles the selection, while this hook makes the same result
# reliable when it is called from startup or manually.
if [[ "$startup" == true ]] && command -v swww >/dev/null 2>&1; then
    if ! swww query >/dev/null 2>&1; then
        swww-daemon >/dev/null 2>&1 &
        for _ in {1..20}; do
            swww query >/dev/null 2>&1 && break
            sleep 0.1
        done
    fi
    if ! swww query 2>/dev/null | grep -Fq "image: $wallpaper"; then
        swww img "$wallpaper" \
            --transition-type "$transition_type" \
            --transition-step "$transition_step" \
            --transition-angle "$transition_angle" \
            --transition-duration "$transition_duration" \
            --transition-fps "$transition_fps" >/dev/null 2>&1 || true
    fi
fi

WALLPAPER="$wallpaper" CACHE_DIR="$cache_dir" GTK_MODE="$gtk_mode" python3 - <<'PY'
import colorsys
import os
import tempfile
from pathlib import Path

from PIL import Image, ImageStat

wallpaper = Path(os.environ["WALLPAPER"])
cache_dir = Path(os.environ["CACHE_DIR"])
gtk_mode = os.environ.get("GTK_MODE", "dark")

image = Image.open(wallpaper).convert("RGB")
image.thumbnail((160, 160))
if image.width == 0 or image.height == 0:
    raise SystemExit("wallpaper-theme: image has no pixels")

# Quantize the image, then choose distinct colors with useful saturation.
quantized = image.quantize(colors=12, method=Image.Quantize.MEDIANCUT).convert("RGB")
counts = quantized.getcolors(quantized.width * quantized.height) or []
colors = [color for _, color in sorted(counts, reverse=True)]

def hsv(color):
    return colorsys.rgb_to_hsv(*(channel / 255 for channel in color))

def distance(first, second):
    return sum((a - b) ** 2 for a, b in zip(first, second)) ** 0.5

def clamp(value):
    return max(0, min(255, round(value)))

def hex_color(color):
    return "#{:02x}{:02x}{:02x}".format(*[clamp(channel) for channel in color])

def rgb_color(color):
    return ",".join(str(clamp(channel)) for channel in color)

def brighten(color, amount):
    h, s, v = hsv(color)
    return tuple(channel * 255 for channel in colorsys.hsv_to_rgb(
        h, max(0.35, min(1, s)), max(0.68, min(1, v + amount))
    ))

def readable_text(color):
    luminance = (0.299 * color[0] + 0.587 * color[1] + 0.114 * color[2]) / 255
    return (20, 24, 30) if luminance > 0.58 else (238, 242, 247)

def pick_accent(start, minimum_saturation=0.28):
    candidates = [color for color in colors if hsv(color)[1] >= minimum_saturation]
    candidates.sort(key=lambda color: hsv(color)[1] * 0.65 + hsv(color)[2] * 0.35, reverse=True)
    return candidates[0] if candidates else start

average = tuple(channel for channel in ImageStat.Stat(image).mean)
if gtk_mode == "light":
    background = tuple(round(218 + channel * 0.12) for channel in average)
    background_alt = tuple(round(232 + channel * 0.08) for channel in average)
    surface = tuple(round(246 + channel * 0.035) for channel in average)
    text = (28, 32, 38)
else:
    dark = tuple(channel * 0.22 for channel in average)
    background = tuple(min(channel, 42) for channel in dark)
    background_alt = tuple(min(58, channel + 14) for channel in background)
    surface = tuple(min(76, channel + 27) for channel in background)
    text = readable_text(background)
muted = tuple((channel + 120) / 2 for channel in text)
accent = pick_accent(average)
accent_alt = pick_accent(accent, 0.18)
if distance(accent, accent_alt) < 35:
    accent_alt = brighten(accent, 0.18)
accent_soft = brighten(accent, 0.08)
red = (224, 108, 116)
green = (151, 203, 132)
yellow = (235, 203, 139)
blue = accent_alt
selected_text = readable_text(accent_soft)

palette = {
    "background": hex_color(background),
    "background_alt": hex_color(background_alt),
    "surface": hex_color(surface),
    "text": hex_color(text),
    "muted": hex_color(muted),
    "accent": hex_color(accent_soft),
    "accent_alt": hex_color(accent_alt),
    "red": hex_color(red),
    "green": hex_color(green),
    "yellow": hex_color(yellow),
    "blue": hex_color(blue),
    "selected_text": hex_color(selected_text),
}

files = {
    "waybar-colors.css": f'''@define-color base alpha({palette["background"]}, 0.86);\n@define-color mantle alpha({palette["background_alt"]}, 0.92);\n@define-color surface {palette["surface"]};\n@define-color surface2 {palette["background_alt"]};\n@define-color text {palette["text"]};\n@define-color subtext {palette["muted"]};\n@define-color teal {palette["accent"]};\n@define-color frost {palette["accent"]};\n@define-color blue {palette["blue"]};\n@define-color red {palette["red"]};\n@define-color green {palette["green"]};\n@define-color yellow {palette["yellow"]};\n@define-color purple {palette["accent_alt"]};\n''',
    "gtk.css": f'''@define-color theme_bg_color {palette["background"]};
@define-color theme_fg_color {palette["text"]};
@define-color theme_base_color {palette["background_alt"]};
@define-color theme_text_color {palette["text"]};
@define-color theme_selected_bg_color {palette["accent"]};
@define-color theme_selected_fg_color {palette["selected_text"]};
@define-color accent_color {palette["accent"]};
@define-color accent_bg_color {palette["accent"]};
@define-color accent_fg_color {palette["selected_text"]};
@define-color headerbar_bg_color {palette["background"]};
@define-color headerbar_fg_color {palette["text"]};
@define-color card_bg_color {palette["background_alt"]};
@define-color card_fg_color {palette["text"]};

window, dialog, popover, menu {{
    background-color: @theme_bg_color;
    color: @theme_fg_color;
}}

headerbar, .titlebar, .csd {{
    background-color: @headerbar_bg_color;
    color: @headerbar_fg_color;
}}

button, .card {{
    background-color: @card_bg_color;
    color: @card_fg_color;
    border-color: @accent_color;
}}

entry, textview, view, list, treeview {{
    background-color: @theme_base_color;
    color: @theme_text_color;
    caret-color: @accent_color;
}}

selection {{
    background-color: @theme_selected_bg_color;
    color: @theme_selected_fg_color;
}}

*:focus {{
    outline-color: @accent_color;
}}
''',
    "kdeglobals": f'''[General]
ColorScheme=Wallpaper

[Colors:Window]
BackgroundNormal={rgb_color(background)}
ForegroundNormal={rgb_color(text)}

[Colors:View]
BackgroundNormal={rgb_color(background_alt)}
ForegroundNormal={rgb_color(text)}

[Colors:Button]
BackgroundNormal={rgb_color(surface)}
ForegroundNormal={rgb_color(text)}

[Colors:Selection]
BackgroundNormal={rgb_color(accent_soft)}
ForegroundNormal={rgb_color(selected_text)}
BackgroundAlternate={rgb_color(accent_alt)}

[Colors:Tooltip]
BackgroundNormal={rgb_color(surface)}
ForegroundNormal={rgb_color(text)}

[Colors:Complementary]
BackgroundNormal={rgb_color(background)}
ForegroundNormal={rgb_color(text)}
''',
    "kitty.conf": f'''foreground {palette["text"]}\nbackground {palette["background"]}\nselection_foreground {palette["background"]}\nselection_background {palette["accent"]}\ncursor {palette["accent"]}\ncursor_text_color {palette["background"]}\nurl_color {palette["accent"]}\nactive_border_color {palette["accent"]}\ninactive_border_color {palette["surface"]}\nbell_border_color {palette["red"]}\ncolor0 {palette["background_alt"]}\ncolor1 {palette["red"]}\ncolor2 {palette["green"]}\ncolor3 {palette["yellow"]}\ncolor4 {palette["blue"]}\ncolor5 {palette["accent_alt"]}\ncolor6 {palette["accent"]}\ncolor7 {palette["text"]}\ncolor8 {palette["surface"]}\ncolor9 {palette["red"]}\ncolor10 {palette["green"]}\ncolor11 {palette["yellow"]}\ncolor12 {palette["blue"]}\ncolor13 {palette["accent_alt"]}\ncolor14 {palette["accent"]}\ncolor15 {palette["text"]}\n''',
    "rofi.rasi": f'''* {{
    bg0: {palette["background"]}ff;
    bg1: {palette["background_alt"]}ff;
    bg2: {palette["surface"]}ff;
    bg3: {palette["surface"]}cc;
    teal: {palette["accent"]}ff;
    teal-dim: {palette["accent"]}55;
    purple: {palette["accent_alt"]}ff;
    purple-dim: {palette["accent_alt"]}55;
    red: {palette["red"]}ff;
    green: {palette["green"]}ff;
    yellow: {palette["yellow"]}ff;
    fg0: {palette["text"]}ff;
    fg1: {palette["text"]}dd;
    fg2: {palette["blue"]}ff;
    fg-dim: {palette["muted"]}ff;
}}
''',
    "btop.theme": "\n".join([
        f"theme[main_bg]=\"{palette['background']}\"",
        f"theme[main_fg]=\"{palette['text']}\"",
        f"theme[title]=\"{palette['text']}\"",
        f"theme[hi_fg]=\"{palette['accent']}\"",
        f"theme[selected_bg]=\"{palette['surface']}\"",
        f"theme[selected_fg]=\"{palette['text']}\"",
        f"theme[inactive_fg]=\"{palette['muted']}\"",
        f"theme[graph_text]=\"{palette['text']}\"",
        f"theme[meter_bg]=\"{palette['background_alt']}\"",
        f"theme[proc_misc]=\"{palette['accent_alt']}\"",
        f"theme[cpu_box]=\"{palette['accent']}\"",
        f"theme[mem_box]=\"{palette['accent_alt']}\"",
        f"theme[net_box]=\"{palette['blue']}\"",
        f"theme[proc_box]=\"{palette['accent']}\"",
        f"theme[div_line]=\"{palette['surface']}\"",
        f"theme[temp_start]=\"{palette['green']}\"",
        f"theme[temp_mid]=\"{palette['yellow']}\"",
        f"theme[temp_end]=\"{palette['red']}\"",
        f"theme[cpu_start]=\"{palette['blue']}\"",
        f"theme[cpu_mid]=\"{palette['accent']}\"",
        f"theme[cpu_end]=\"{palette['accent_alt']}\"",
        f"theme[free_start]=\"{palette['green']}\"",
        f"theme[free_mid]=\"{palette['accent']}\"",
        f"theme[free_end]=\"{palette['blue']}\"",
        f"theme[cached_start]=\"{palette['blue']}\"",
        f"theme[cached_mid]=\"{palette['accent']}\"",
        f"theme[cached_end]=\"{palette['accent_alt']}\"",
        f"theme[available_start]=\"{palette['yellow']}\"",
        f"theme[available_mid]=\"{palette['accent']}\"",
        f"theme[available_end]=\"{palette['red']}\"",
        f"theme[used_start]=\"{palette['accent_alt']}\"",
        f"theme[used_mid]=\"{palette['blue']}\"",
        f"theme[used_end]=\"{palette['accent']}\"",
        f"theme[download_start]=\"{palette['green']}\"",
        f"theme[download_mid]=\"{palette['accent']}\"",
        f"theme[download_end]=\"{palette['blue']}\"",
        f"theme[upload_start]=\"{palette['accent_alt']}\"",
        f"theme[upload_mid]=\"{palette['accent']}\"",
        f"theme[upload_end]=\"{palette['red']}\"",
        f"theme[process_start]=\"{palette['green']}\"",
        f"theme[process_mid]=\"{palette['accent']}\"",
        f"theme[process_end]=\"{palette['accent_alt']}\"",
    ]) + "\n",
}

rofi_template = Path.home() / ".config/rofi/themes/nordic-pill.rasi"
if rofi_template.exists():
    layout = "\n".join(
        line for line in rofi_template.read_text().splitlines()
        if not line.startswith("@import ")
    )
    files["rofi.rasi"] += layout + "\n"

for name, content in files.items():
    destination = cache_dir / name
    with tempfile.NamedTemporaryFile("w", dir=cache_dir, delete=False) as temporary:
        temporary.write(content)
        temporary_path = Path(temporary.name)
    temporary_path.replace(destination)

(Path.home() / ".config/btop/themes/walltheme.theme").write_text(files["btop.theme"])
(Path.home() / ".config/kdeglobals").write_text(files["kdeglobals"])
for gtk_dir in ("gtk-3.0", "gtk-4.0"):
    destination = Path.home() / ".config" / gtk_dir / "gtk.css"
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.is_symlink():
        destination.unlink()
    destination.write_text(files["gtk.css"])

(cache_dir / "palette.env").write_text("\n".join(f"{key.upper()}={value}" for key, value in palette.items()) + "\n")
print("wallpaper-theme: generated palette for", wallpaper)
PY

# Reload live clients. Their configs include the generated fragments below.
hyprctl keyword general:col.active_border "rgba($(sed -n 's/^ACCENT=/#/p' "$cache_dir/palette.env" | tr -d '\n')ff) rgba($(sed -n 's/^ACCENT_ALT=/#/p' "$cache_dir/palette.env" | tr -d '\n')ff) 45deg" >/dev/null 2>&1 || true
hyprctl keyword general:col.inactive_border "rgba($(sed -n 's/^BACKGROUND_ALT=/#/p' "$cache_dir/palette.env" | tr -d '\n')aa)" >/dev/null 2>&1 || true

pkill -x waybar >/dev/null 2>&1 || true
nohup waybar >/tmp/waybar.log 2>&1 &
pkill -USR1 kitty 2>/dev/null || true
btop_pid=$(pgrep -f 'btop-scratch' || true)
if [[ -n "$btop_pid" ]]; then
    kill -USR1 $btop_pid 2>/dev/null || true
fi
swaync-client --reload-css >/dev/null 2>&1 || true
