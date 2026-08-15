# my-devbox

Reproducible files for my development environment.

1. `git clone https://github.com/julian-computes/my-devbox.git ~/.config/my-devbox`
2. `~/.config/my-devbox/scripts/bootstrap.sh`

## Updating pinned packages

`package-registry.toml` lists packages whose upstream versions are pinned in
this repository. Run `./scripts/update.py` to update every listed package to
its latest stable release and refresh its source hash. Review the diff, then
run `./scripts/bootstrap.sh` to build and activate it.

