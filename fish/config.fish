# ─────────────────────────────────────────────────────────────
# fish config — Nordic clean-cyberpunk
# Place at ~/.config/fish/config.fish
# ─────────────────────────────────────────────────────────────

if status is-interactive
    # run fastfetch once per interactive login shell
    fastfetch

    # starship prompt (palette matched in starship.toml)
    starship init fish | source
end

# ── Environment ─────────────────────────────────────────────
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx TERMINAL kitty
set -gx BROWSER firefox
set -gx XCURSOR_THEME Bibata-Modern-Classic
set -gx XCURSOR_SIZE 24

# ── Sensible fish behavior ──────────────────────────────────
set fish_greeting                       # disable default greeting, fastfetch replaces it
fish_vi_key_bindings                    # comment out if you prefer emacs-style bindings

# ── Aliases ──────────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --group-directories-first'
alias la='eza -lah --icons --group-directories-first'
alias cat='bat'
alias top='btop'
alias grep='rg'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias vim='nvim'
alias hyprconf='$EDITOR ~/.config/hypr/hyprland.conf'
alias fishconf='$EDITOR ~/.config/fish/config.fish'

# quick git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# ── Fish color palette (Nordic) ─────────────────────────────
set -g fish_color_normal        E5E9F0
set -g fish_color_command       88C0D0
set -g fish_color_param         D8DEE9
set -g fish_color_keyword       B48EAD
set -g fish_color_quote         A3BE8C
set -g fish_color_redirection   81A1C1
set -g fish_color_end           EBCB8B
set -g fish_color_error         BF616A
set -g fish_color_comment       4C566A
set -g fish_color_selection     --background=3B4252
set -g fish_color_search_match  --background=434C5E
set -g fish_color_autosuggestion 4C566A
set -g fish_pager_color_prefix       88C0D0
set -g fish_pager_color_completion   E5E9F0
set -g fish_pager_color_description  4C566A
set -g fish_pager_color_selected_background --background=3B4252

# ── Path additions ──────────────────────────────────────────
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
