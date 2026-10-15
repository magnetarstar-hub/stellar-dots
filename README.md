# stellar-dots

Linux desktop dotfiles for Hyprland, Waybar, Kitty, Fish, Neovim, GTK, Rofi, btop, and Fastfetch.

## Install

Clone the repository, then run these commands from its root directory:

```bash
mkdir -p "$HOME/.config" "$HOME/Pictures/wallpapers"

for dir in btop fastfetch fish gtk-3.0 gtk-4.0 hypr kitty nvim rofi waybar; do
	cp -a "$dir" "$HOME/.config/"
done

cp -a wallpapers/. "$HOME/Pictures/wallpapers/"
```

The folders are installed here:

| Repository folder | Destination |
| --- | --- |
| `btop/` | `~/.config/btop/` |
| `fastfetch/` | `~/.config/fastfetch/` |
| `fish/` | `~/.config/fish/` |
| `gtk-3.0/` | `~/.config/gtk-3.0/` |
| `gtk-4.0/` | `~/.config/gtk-4.0/` |
| `hypr/` | `~/.config/hypr/` |
| `kitty/` | `~/.config/kitty/` |
| `nvim/` | `~/.config/nvim/` |
| `rofi/` | `~/.config/rofi/` |
| `waybar/` | `~/.config/waybar/` |
| `wallpapers/` | `~/Pictures/wallpapers/` |

## Before starting Hyprland

Some installed files contain paths from the original machine. Replace them with your home directory:

```bash
for file in \
	"$HOME/.config/hypr/hyprland.lua" \
	"$HOME/.config/hypr/hyprlock.conf" \
	"$HOME/.config/hypr/hyprpaper.conf" \
	"$HOME/.config/hypr/scripts/theme-mode.sh" \
	"$HOME/.config/rofi/themes/nordic-pill.rasi" \
	"$HOME/.config/waybar/style.css"; do
	sed -i "s#/home/sam#$HOME#g" "$file"
done
```

The default wallpaper is `~/Pictures/wallpapers/waves.png`. Change the wallpaper path in `hyprpaper.conf` and `hyprlock.conf` if you use a different filename.

## Required software

Install the programs used by the configurations before launching them. The setup expects Hyprland, Kitty, Fish, Neovim, Waybar, Rofi, btop, Fastfetch, GTK, `swww`, Waypaper, `grim`, `slurp`, Satty, `hyprshot`, `wl-clipboard`, `cliphist`, `swaync`, `hypridle`, NetworkManager applet, Blueman, and Python with Pillow.

The theme script creates generated files in `~/.cache/walltheme/` on first run. Start Hyprland after the files are installed, then select a wallpaper with Waypaper or run:

```bash
~/.config/hypr/scripts/wallpaper-theme.sh "$HOME/Pictures/wallpapers/waves.png"
```

## Notes

- Back up existing files in `~/.config` before installing. The copy commands replace files with matching names.
- `fish/fish_variables` contains machine-specific Fish state. Remove it before copying if you do not want to import the original environment.
- Make sure the Hyprland configuration loads `~/.config/hypr/hyprland.lua` using the Lua configuration plugin used by your setup.
