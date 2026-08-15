{ config, lib, pkgs, ... }:

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

  # Provision Pi before installing its extensions. node-pty, a transitive
  # dependency of Plannotator, builds from source on aarch64 Linux.
  home.activation.installPiCodingAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.bun}/bin:${pkgs.nodejs}/bin:${config.home.homeDirectory}/.bun/bin:$PATH"
    package="@earendil-works/pi-coding-agent@0.84.2"

    if ! pi --version 2>/dev/null | grep -Fxq "0.84.2"; then
      for attempt in $(seq 1 12); do
        if ${pkgs.curl}/bin/curl --fail --silent --show-error \
          --connect-timeout 5 --max-time 10 \
          https://registry.npmjs.org/@earendil-works%2Fpi-coding-agent >/dev/null; then
          break
        elif [ "$attempt" -eq 12 ]; then
          echo "npm registry did not become available" >&2
          exit 1
        fi
        sleep 2
      done

      for attempt in $(seq 1 5); do
        if ${pkgs.coreutils}/bin/timeout 60 bun add --global --exact "$package"; then
          break
        elif [ "$attempt" -eq 5 ]; then
          exit 1
        fi
        sleep 2
      done
    fi
  '';

  home.activation.installPlannotatorPiExtension = lib.hm.dag.entryAfter [ "installPiCodingAgent" ] ''
    export PATH="${pkgs.bun}/bin:${pkgs.nodejs}/bin:${pkgs.python3}/bin:${pkgs.gcc}/bin:${pkgs.gnumake}/bin:${config.home.homeDirectory}/.bun/bin:$PATH"
    settings="${config.home.homeDirectory}/.pi/agent/settings.json"
    package="npm:@plannotator/pi-extension@0.27.3"

    if ! grep -Fq "$package" "$settings" 2>/dev/null; then
      pi install "$package"
    fi
  '';

  # Pi extension for FFF, which replaces Pi's built-in find and grep tools.
  home.activation.installPiFffExtension = lib.hm.dag.entryAfter [ "installPiCodingAgent" ] ''
    export PATH="${pkgs.bun}/bin:${pkgs.nodejs}/bin:${config.home.homeDirectory}/.bun/bin:$PATH"
    settings="${config.home.homeDirectory}/.pi/agent/settings.json"
    package="npm:@ff-labs/pi-fff@0.10.3"

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

  # Keep available-tool instructions and reusable skills accessible to coding agents.
  home.file."AGENTS.md".source = ./agent-instructions.md;
  home.file.".agents/skills".source = ./skills;

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
