{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    git
    ripgrep
    fd
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
