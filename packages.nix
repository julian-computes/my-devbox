{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    helix
    micro
    git
    ripgrep
    fd
    fff
    yazi
    skim
    bat
    bottom
    lazygit
    just
    tshark
    gcc
    gnumake
    python3
    uv
    sqlite
    duckdb
    bun
    nodejs
    gh
    claude-code
    (callPackage ./codex.nix { })
    (callPackage ./herdr.nix { })
  ];
}
