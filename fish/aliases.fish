# Fish aliases managed by my-devbox.
# Add aliases here; this file is loaded automatically by fish via conf.d.
alias gsw='git switch'
alias gst='git status'
alias gco='git checkout'

# Create a directory, including parents, then enter it.
function take --description 'Create a directory and enter it'
    if test (count $argv) -ne 1
        echo 'usage: take DIRECTORY' >&2
        return 2
    end

    mkdir -p -- $argv[1]; and cd -- $argv[1]
end

function rebuild-my-devbox --description 'Rebuild NixOS from my-devbox'
    "$HOME/.config/my-devbox/scripts/bootstrap.sh"
end
