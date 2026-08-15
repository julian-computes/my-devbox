{ config, pkgs, modulesPath, ... }:

{
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}

