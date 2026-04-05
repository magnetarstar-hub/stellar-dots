if status is-interactive
# Commands to run in interactive sessions can go here
end
set -x GNOME_KEYRING_CONTROL /run/user/1000/keyring
set -x SSH_AUTH_SOCK /run/user/1000/keyring/ssh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/sam/anaconda3/bin/conda
    eval /home/sam/anaconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/home/sam/anaconda3/etc/fish/conf.d/conda.fish"
        . "/home/sam/anaconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/home/sam/anaconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

set -x LD_LIBRARY_PATH /usr/lib /opt/cuda/lib64 $LD_LIBRARY_PATH
