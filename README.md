# my-devbox

Reproducible files for my development environment.

```sh
nix-shell -p git
git clone https://github.com/julian-computes/my-devbox.git ~/.config/my-devbox
~/.config/my-devbox/scripts/bootstrap.sh
```

## Local skills and packages

`local/` is gitignored. Use it for checkout-only extras that should not be
committed. After adding files there, run `./scripts/bootstrap.sh`.

### Packages

Copy `local.nix.example` to `local/default.nix` and add Home Manager config.
`home.packages` entries can be nixpkgs packages or local derivations next to
that file:

```nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hello
    (callPackage ./my-tool.nix { })
  ];
}
```

Do not edit `packages.nix` for checkout-only tools. That file is tracked.

### Skills

Put a skill directory in `local/skills/`. Use the same layout as
`skills/tshark/`:

```text
local/skills/my-skill/SKILL.md
```

On activate, those skills are merged with the tracked `skills/` tree into
`~/.agents/skills`. Choose names that do not collide with tracked skills.

Do not put checkout-only skills in `skills/`. That directory is tracked.

## Updating pinned packages

`package-registry.toml` lists packages whose upstream versions are pinned in
this repository. Run `./scripts/update.py` to update every listed package to
its latest stable release and refresh its source hash. Review the diff, then
run `./scripts/bootstrap.sh` to build and activate it.

