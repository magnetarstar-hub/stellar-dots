-- Personal Hyprland configuration.
-- This is the Lua equivalent of the previous hyprland.conf.

local mainMod = "SUPER"
local terminal = "kitty"
local launcher = "rofi -show drun -theme ~/.cache/walltheme/rofi.rasi"
local fileManager = "dolphin"
local browser = "brave"
local colorPicker = "hyprpicker -a"
local screenshot = "/home/sam/.config/hypr/scripts/screenshot.sh"
local themeMode = "/home/sam/.config/hypr/scripts/theme-mode.sh toggle"

hl.monitor({
    output = "HDMI-A-4",
    mode = "1920x1080@100",
    position = "auto",
    scale = 1,
})

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

hl.on("hyprland.start", function()
    hl.exec_cmd("swww-daemon")
    hl.exec_cmd("/home/sam/.config/hypr/scripts/wallpaper-theme.sh --startup")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd('fish -c "hyprctl setcursor Bibata-Modern-Classic 24"')
    hl.exec_cmd("wl-paste --watch cliphist store")
end)

hl.config({
    input = {
        kb_layout = "fr,ara,us",
        kb_variant = ",,",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity = 0,
        numlock_by_default = true,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            drag_lock = true,
            disable_while_typing = true,
        },
    },
    general = {
        gaps_in = 5,
        gaps_out = 12,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(88C0D0ee)", "rgba(B48EADee)" }, angle = 45 },
            inactive_border = "rgba(3B4252aa)",
        },
        layout = "dwindle",
        resize_on_border = true,
        allow_tearing = false,
    },
    decoration = {
        rounding = 16,
        active_opacity = 0.96,
        inactive_opacity = 0.90,
        fullscreen_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.08,
        blur = {
            enabled = true,
            size = 6,
            passes = 3,
            new_optimizations = true,
            ignore_opacity = true,
            xray = false,
            vibrancy = 0.18,
            popups = true,
        },
        shadow = {
            enabled = true,
            range = 18,
            render_power = 3,
            color = "rgba(00000099)",
        },
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        background_color = "0x0d0f14",
        font_family = "JetBrainsMono Nerd Font",
        enable_swallow = false,
        swallow_regex = "^(kitty)$",
        focus_on_activate = false,
    },
    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true,
    },
    master = {
        new_status = "master",
    },
})

hl.curve("softAcDc", { type = "bezier", points = { { 0.19, 1 }, { 0.22, 1 } } })
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOut", { type = "bezier", points = { { 0.5, 0 }, { 0.5, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "easeOutQuint", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "easeOutQuint", style = "popin 85%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "easeOutQuint" })
hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "softAcDc" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 20, bezier = "softAcDc", loop = true })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "softAcDc" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 4, bezier = "softAcDc" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 4, bezier = "softAcDc" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "softAcDc", style = "slidevert" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "easeInOut", style = "slide" })

local function rule(name, match, values)
    values.name = name
    values.match = match
    hl.window_rule(values)
end

rule("pavucontrol", { class = "^(pavucontrol)$" }, { float = true })
rule("blueman-manager", { class = "^(blueman-manager)$" }, { float = true })
rule("network-manager", { class = "^(nm-connection-editor)$" }, { float = true })
rule("picture-in-picture", { title = "^(Picture-in-Picture)$" }, { float = true, pin = true })
rule("kitty-opacity", { class = "^(kitty)$" }, { opacity = "0.95 0.85" })
rule("dolphin-opacity", { class = "^(dolphin)$" }, { opacity = "0.95 0.90" })
rule("brave-opacity", { class = "^(brave-browser)$" }, { opacity = "0.95 0.90" })
rule("pavu-size", { class = "^(pavucontrol)$" }, { size = "800 550" })
rule("calculator", { class = "^(org.gnome.Calculator)$" }, { float = true })
rule("screenshot", { title = "^(Screenshot)$" }, { float = true })
rule("btop-scratch", { class = "^(btop-scratch)$" }, { workspace = "special:magic" })
rule("no-auto-maximize", { class = ".*" }, { suppress_event = "maximize" })

hl.layer_rule({ name = "waybar-blur", match = { namespace = "waybar" }, blur = true, ignore_alpha = true })
hl.layer_rule({ name = "notifications-blur", match = { namespace = "notifications" }, blur = true })
hl.layer_rule({ name = "rofi-blur", match = { namespace = "rofi" }, blur = true })

local function bind(key, dispatcher)
    hl.bind(mainMod .. " + " .. key, dispatcher)
end

bind("Q", hl.dsp.exec_cmd(terminal))
bind("R", hl.dsp.exec_cmd(launcher))
bind("E", hl.dsp.exec_cmd(fileManager))
bind("B", hl.dsp.exec_cmd(browser))
bind("C", hl.dsp.window.close())
bind("SHIFT + Q", hl.dsp.exec_cmd("hyprctl dispatch 'hl.dsp.exit()'"))
bind("V", hl.dsp.window.float({ action = "toggle" }))
bind("F", hl.dsp.window.fullscreen())
bind("P", hl.dsp.window.pseudo())
bind("J", hl.dsp.layout("togglesplit"))
bind("L", hl.dsp.exec_cmd("hyprlock"))
bind("SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
bind("S", hl.dsp.workspace.toggle_special("magic"))
bind("SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
bind("TAB", hl.dsp.exec_cmd("hyprctl dispatch cyclenext"))
bind("SHIFT + TAB", hl.dsp.exec_cmd("hyprctl dispatch cyclenext prev"))
bind("K", hl.dsp.exec_cmd(colorPicker))
bind("SHIFT + N", hl.dsp.exec_cmd("swaync-client -t"))
bind("X", hl.dsp.exec_cmd("wlogout"))
bind("W", hl.dsp.exec_cmd("waypaper"))
bind("T", hl.dsp.exec_cmd(themeMode))
bind("Z", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -theme ~/.cache/walltheme/rofi.rasi | cliphist decode | wl-copy"))
bind("M", hl.dsp.exec_cmd("kitty --class btop-scratch -e btop"))

for _, direction in ipairs({ "left", "right", "up", "down" }) do
    bind(direction, hl.dsp.exec_cmd("hyprctl dispatch movefocus " .. direction))
    hl.bind(mainMod .. " + SHIFT + " .. direction, hl.dsp.exec_cmd("hyprctl dispatch movewindow " .. direction))
end

hl.bind(mainMod .. " + ALT + left", hl.dsp.exec_cmd("hyprctl dispatch resizeactive -40 0"))
hl.bind(mainMod .. " + ALT + right", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 40 0"))
hl.bind(mainMod .. " + ALT + up", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -40"))
hl.bind(mainMod .. " + ALT + down", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 40"))

local frenchNumberRow = { "ampersand", "eacute", "quotedbl", "apostrophe", "parenleft", "minus", "egrave", "underscore", "ccedilla" }
for i = 1, 9 do
    local workspaceFocus = hl.dsp.focus({ workspace = i })
    local windowMove = hl.dsp.window.move({ workspace = i })
    hl.bind(mainMod .. " + code:" .. (i + 9), workspaceFocus)
    hl.bind(mainMod .. " + " .. frenchNumberRow[i], workspaceFocus)
    hl.bind(mainMod .. " + SHIFT + code:" .. (i + 9), windowMove)
    hl.bind(mainMod .. " + SHIFT + " .. frenchNumberRow[i], windowMove)
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("Print", hl.dsp.exec_cmd(screenshot .. " region"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(screenshot .. " output"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(screenshot .. " region-save"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd(screenshot .. " window"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Study Lock popup + routine-driven desktop
hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/local/bin/studylock-ask")
    hl.exec_cmd("/home/sam/.local/bin/routine-desktop")
end)
