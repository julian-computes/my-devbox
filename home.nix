{ config, lib, ... }:

{
  imports = [
    ./packages.nix
  ];

  # Bump only on a fresh home-manager install; see home-manager release notes.
  home.stateVersion = "25.11";

  home.sessionPath = [
    "$HOME/.bun/bin"
  ];

  programs.bash.enable = true;
  programs.fish.enable = true;

  # Pi installs npm extensions into ~/.pi; pin and provision Plannotator.
  # node-pty, a transitive dependency, builds from source on aarch64 Linux.
  home.activation.installPlannotatorPiExtension = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${config.home.homeDirectory}/.bun/bin:$PATH"
    settings="${config.home.homeDirectory}/.pi/agent/settings.json"
    package="npm:@plannotator/pi-extension@0.27.3"

    if ! grep -Fq "$package" "$settings" 2>/dev/null; then
      pi install "$package"
    fi
  '';

  # Fish loads every *.fish file in conf.d on startup.
  xdg.configFile."fish/conf.d/aliases.fish".source = ./fish/aliases.fish;

  xdg.configFile."herdr/config.toml" = {
    source = ./herdr/config.toml;
    force = true;
  };

  # Keep repository instructions available to locally run coding agents.
  home.file."AGENTS.md".source = ./AGENTS.md;

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
