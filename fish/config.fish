if status is-interactive
# Commands to run in interactive sessions can go here
end
set -x GNOME_KEYRING_CONTROL /run/user/1000/keyring
set -x SSH_AUTH_SOCK /run/user/1000/keyring/ssh

