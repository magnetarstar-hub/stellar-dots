#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# stellar-dots installer
# One-liner usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/magnetarstar-hub/stellar-dots/main/install.sh)
# Or, if already cloned:
#   cd stellar-dots && ./install.sh
# ─────────────────────────────────────────────────────────────
set -euo pipefail

REPO_URL="https://github.com/magnetarstar-hub/stellar-dots.git"
REPO_DIR="$HOME/stellar-dots"
CONFIG="$HOME/.config"
STAMP="$(date +%Y%m%d-%H%M%S)"

echo "==> stellar-dots installer"
echo

# ── 0. get the repo ──────────────────────────────────────────
if [[ -d "$REPO_DIR/.git" ]]; then
    echo "==> Found existing clone at $REPO_DIR, pulling latest..."
    git -C "$REPO_DIR" pull
elif [[ -f "./install.sh" && -d "./hypr" ]]; then
    echo "==> Running from inside an already-cloned repo."
    REPO_DIR="$(pwd)"
else
    echo "==> Cloning into $REPO_DIR..."
    command -v git >/dev/null 2>&1 || { echo "!! git not found. Installing..."; sudo pacman -S --needed --noconfirm git; }
    git clone "$REPO_URL" "$REPO_DIR"
fi
cd "$REPO_DIR"
echo

# ── 1. packages ──────────────────────────────────────────────
read -rp "Install packages via pacman + AUR helper now? [y/N] " DO_PKGS
if [[ "${DO_PKGS,,}" == "y" ]]; then
    AUR_HELPER=""
    for h in yay paru; do
        if command -v "$h" >/dev/null 2>&1; then AUR_HELPER="$h"; break; fi
    done
    if [[ -z "$AUR_HELPER" ]]; then
        echo "!! No AUR helper (yay/paru) found. Skipping AUR packages — install them manually later." >&2
    fi

    echo "==> Installing core packages (pacman)..."
    sudo pacman -S --needed --noconfirm \
        hyprland hyprpaper waybar kitty fish fastfetch btop \
        rofi-wayland swaync swayidle swaylock wl-clipboard cliphist \
        grim slurp playerctl brightnessctl pavucontrol wireplumber \
        network-manager-applet thunar gnome-keyring qt5ct polkit-gnome \
        ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji \
        xdg-desktop-portal-hyprland git

    if [[ -n "$AUR_HELPER" ]]; then
        echo "==> Installing AUR packages ($AUR_HELPER)..."
        "$AUR_HELPER" -S --needed --noconfirm \
            ttf-nerd-fonts-noto-sans-mono \
            bibata-cursor-theme \
            nordic-theme \
            starship \
            eza bat ripgrep \
            wlogout nwg-look || echo "!! Some AUR packages failed — check names/availability and retry manually."
        echo "    (search AUR yourself for a Nord-styled icon set, e.g. 'Zafiro-Nord' — exact package name shifts over time)"
    fi
else
    echo "==> Skipping package installation."
fi
echo

# ── 2. back up existing configs ─────────────────────────────
BACKUP_DIR="$CONFIG/stellar-dots-backup-$STAMP"
NEED_BACKUP=false
for d in hypr waybar kitty btop fastfetch fish; do
    [[ -e "$CONFIG/$d" ]] && NEED_BACKUP=true
done
if $NEED_BACKUP; then
    echo "==> Backing up existing configs to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    for d in hypr waybar kitty btop fastfetch fish; do
        [[ -e "$CONFIG/$d" ]] && cp -r "$CONFIG/$d" "$BACKUP_DIR/"
    done
fi

# ── 3. copy configs into place ──────────────────────────────
echo "==> Installing configs from $REPO_DIR"
mkdir -p "$CONFIG"/{hypr,waybar,kitty,btop/themes,fastfetch,fish}

cp "$REPO_DIR"/hypr/*.conf              "$CONFIG/hypr/"
cp "$REPO_DIR"/waybar/config.jsonc      "$CONFIG/waybar/"
cp "$REPO_DIR"/waybar/style.css         "$CONFIG/waybar/"
cp "$REPO_DIR"/kitty/kitty.conf         "$CONFIG/kitty/"
cp "$REPO_DIR"/btop/btop.conf           "$CONFIG/btop/"
cp "$REPO_DIR"/btop/themes/*.theme      "$CONFIG/btop/themes/"
cp "$REPO_DIR"/fastfetch/config.jsonc   "$CONFIG/fastfetch/"
cp "$REPO_DIR"/fish/config.fish         "$CONFIG/fish/"
cp "$REPO_DIR"/fish/starship.toml       "$CONFIG/starship.toml"

# ── 4. wallpaper dir ─────────────────────────────────────────
mkdir -p "$HOME/Pictures/wallpapers"
if [[ ! -f "$HOME/Pictures/wallpapers/chrome-bust-starfield.jpg" ]]; then
    echo "==> NOTE: no wallpaper found at ~/Pictures/wallpapers/chrome-bust-starfield.jpg"
    echo "    Drop your own image there, or edit ~/.config/hypr/hyprpaper.conf to point elsewhere."
fi

# ── 5. shell ─────────────────────────────────────────────────
if command -v fish >/dev/null 2>&1; then
    read -rp "Set fish as your default shell now? [y/N] " DO_SHELL
    if [[ "${DO_SHELL,,}" == "y" ]]; then
        chsh -s "$(command -v fish)"
    fi
fi

echo
echo "==> Done."
if $NEED_BACKUP; then
    echo "    - Your previous configs were backed up to: $BACKUP_DIR"
    echo "      To undo this install: ./restore.sh $(basename "$BACKUP_DIR")"
fi
echo "    - Reload Hyprland (hyprctl reload) or re-login to apply everything."
echo "    - Apply GTK/cursor/icon themes with nwg-look (Nordic / Bibata-Modern-Classic / your Nord icon set)."
