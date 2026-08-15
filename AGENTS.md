# my-devbox

A NixOS and Home Manager configuration for a reproducible development environment.
`script/bootstrap.sh` links this checkout into `/etc/nixos`, generates the
user-specific `nixos.nix`, adds the required imports, and runs
`nixos-rebuild switch`.

## Layout

- `home.nix`: per-user Home Manager configuration and dotfiles.
- `packages.nix`: user packages.
- `programs.nix`: NixOS program configuration.
- `fish/aliases.fish`: Fish aliases, loaded through Fish's `conf.d` directory.
- `nvim/`: Neovim configuration.

## Extending

Keep user dotfiles in this repository and deploy them from `home.nix` with
`home.file` or `xdg.configFile`. Add packages in `packages.nix`; add system
configuration in `programs.nix` or a focused module imported by `imports.nix`.
Keep `bootstrap.sh` idempotent, and validate changes with a Nix evaluation or
`nixos-rebuild` before applying them.
