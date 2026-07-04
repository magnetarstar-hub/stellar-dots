# stellar-dots 🌟

![screenshot](./screenshot.png)

## 🖥️ System Info
| Component | Details |
|---|---|
| **OS** | Arch Linux |
| **WM** | Hyprland |
| **Shell** | Fish |
| **Terminal** | Kitty |
| **Theme** | Nordic (GTK2/3/4) |
| **Icons** | Zafiro-Nord-Black (or closest Nord-styled set) |
| **Cursor** | Bibata-Modern-Classic (24px) |
| **Font** | NotoSansMono Nerd Font (bar/terminal), Rubik (waybar UI) |
| **Prompt** | Starship |
| **Monitoring** | btop (custom Nordic pill theme), fastfetch |

## 🎨 Aesthetic
Dark, minimal "clean cyberpunk" — near-black backgrounds, blur, soft rounded corners, and a Nord-derived accent palette (teal, frost blue, dusty purple, sage green, soft yellow, muted red). Rounded-pill UI throughout: the waybar workspace switcher renders as numbered pills, with the active workspace shown as a filled teal-to-purple gradient pill.

## 📁 Contents
- `hypr/` — Hyprland config (gaps, blur, rounded corners, keybinds, autostart) + hyprpaper wallpaper config
- `waybar/` — Pill-shaped floating status bar (`config.jsonc` + `style.css`)
- `kitty/` — Terminal config, ~90% opacity with blur, Nordic ANSI colors
- `btop/` — Config + `nordic-pill.theme`, rounded borders, 4-pane dashboard (CPU / mem+disks / net / process list)
- `fastfetch/` — System info panel on shell login, with a color-swatch bar
- `fish/` — Shell config + `starship.toml` prompt matching the palette

## ⚙️ Installation

**One command** — clones the repo, optionally installs all dependencies (pacman + AUR), backs up any existing configs, and drops everything into `~/.config`:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/magnetarstar-hub/stellar-dots/main/install.sh)
```

<details>
<summary>Prefer to clone manually first?</summary>

```bash
git clone https://github.com/magnetarstar-hub/stellar-dots.git
cd stellar-dots
chmod +x install.sh
./install.sh
```
</details>

<details>
<summary>Prefer to copy configs by hand instead of running the script?</summary>

```bash
mkdir -p ~/.config/{hypr,waybar,kitty,btop/themes,fastfetch,fish}
cp hypr/*.conf                            ~/.config/hypr/
cp waybar/config.jsonc waybar/style.css   ~/.config/waybar/
cp kitty/kitty.conf                       ~/.config/kitty/
cp btop/btop.conf                         ~/.config/btop/
cp btop/themes/*.theme                    ~/.config/btop/themes/
cp fastfetch/config.jsonc                 ~/.config/fastfetch/
cp fish/config.fish                       ~/.config/fish/
cp fish/starship.toml                     ~/.config/starship.toml
```

Dependencies (Arch):
```bash
sudo pacman -S hyprland hyprpaper waybar kitty fish fastfetch btop \
    rofi-wayland swaync swayidle swaylock wl-clipboard cliphist \
    grim slurp playerctl brightnessctl pavucontrol wireplumber \
    network-manager-applet thunar gnome-keyring qt5ct polkit-gnome \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji \
    xdg-desktop-portal-hyprland
```
AUR (via `yay`/`paru`):
```bash
yay -S bibata-cursor-theme nordic-theme starship eza bat ripgrep wlogout nwg-look
```
</details>

After installing, apply the GTK theme, icon set, and cursor with `nwg-look` so they take effect and fastfetch reports them correctly.

### Undoing an install
`install.sh` backs up any existing `hypr`/`waybar`/`kitty`/`btop`/`fastfetch`/`fish` configs to `~/.config/stellar-dots-backup-<timestamp>` before copying anything in, and prints that path when it finishes. To roll back:
```bash
cd stellar-dots
./restore.sh                          # restores from the most recent backup
./restore.sh stellar-dots-backup-...  # or restore a specific one by name
```

## 🖼️ Wallpaper
Primary vibe: a polished chrome/liquid-metal humanoid bust floating in a black starfield, moody rim lighting. Point `hypr/hyprpaper.conf` at your own copy — it isn't bundled in this repo.

## 📝 Credits
Made with ❤️ by magnetarstar
