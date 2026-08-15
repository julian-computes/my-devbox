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
    bun
    nodejs
    gh
    (callPackage ./herdr.nix { })
  ];
}
