# Fish aliases managed by my-devbox.
# Add aliases here; this file is loaded automatically by fish via conf.d.
alias gsw='git switch'
alias gst='git status'
alias gco='git checkout'

function rebuild-my-devbox --description 'Rebuild NixOS from my-devbox'
    "$HOME/.config/my-devbox/scripts/bootstrap.sh"
end
