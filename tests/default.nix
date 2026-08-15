# Run with: nix-build tests/default.nix
# This test uses the Nixpkgs/NixOS channel selected by NIX_PATH.
let
  expectedNixosSeries = "25.11";
in
(import <nixpkgs/nixos/tests/make-test-python.nix> ({ lib, pkgs, ... }: {
  name = "my-devbox-fresh-install";

  nodes.machine = { ... }: {
    imports = [
      <home-manager/nixos>
      ../programs.nix
    ];

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [ "claude-code" ];

    programs.fish.enable = true;

    users.users.devbox = {
      isNormalUser = true;
      shell = pkgs.fish;
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.devbox = import ../home.nix;

    system.stateVersion = expectedNixosSeries;
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("home-manager-devbox.service")
    machine.succeed("nixos-version | grep -F ${expectedNixosSeries}")
    machine.succeed("su - devbox -c '/home/devbox/.bun/bin/pi --version | grep -Fx 0.84.2'")
    machine.succeed("grep -F 'npm:@plannotator/pi-extension@0.27.3' /home/devbox/.pi/agent/settings.json")
    machine.succeed("grep -F 'npm:@ff-labs/pi-fff@0.10.3' /home/devbox/.pi/agent/settings.json")
  '';
}) {}).test
