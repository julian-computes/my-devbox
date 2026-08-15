{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    git
    ripgrep
    fd
    fff
    yazi
    skim
    bat
    bottom
    lazygit
    tshark
    gcc
    gnumake
    python3
    uv
    bun
    nodejs
    gh
    claude-code
    (callPackage ./codex.nix { })
    (callPackage ./herdr.nix { })
  ];
}
