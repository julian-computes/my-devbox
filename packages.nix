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
    glab
    (callPackage ./claude-code.nix { })
    (callPackage ./codex.nix { })
    (callPackage ./cursor-cli.nix { })
    (callPackage ./herdr.nix { })
  ];
}
