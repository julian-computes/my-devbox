#!/usr/bin/env bash
set -euo pipefail

# One-shot, idempotent setup: wires this repo into /etc/nixos and activates
# it. Safe to re-run any time (e.g. after a fresh VM, or to confirm nothing
# has drifted).

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$script_dir/.." && pwd)
target_link=/etc/nixos/my-devbox
config=/etc/nixos/configuration.nix
username=$(id -un)

echo "==> Generating nixos.nix for user $username"
sed "s/@USERNAME@/$username/g" "$repo_dir/nixos.nix.tmpl" > "$repo_dir/nixos.nix"

echo "==> Linking $target_link -> $repo_dir"
if [[ -L "$target_link" ]]; then
  current=$(readlink -f "$target_link")
  if [[ "$current" == "$repo_dir" ]]; then
    echo "    already linked correctly"
  else
    echo "    error: $target_link is a symlink to $current, not $repo_dir" >&2
    echo "    remove it manually if this is intentional, then re-run" >&2
    exit 1
  fi
elif [[ -e "$target_link" ]]; then
  echo "    error: $target_link exists and is not a symlink; refusing to overwrite" >&2
  echo "    inspect it and remove/move it manually, then re-run" >&2
  exit 1
else
  sudo ln -s "$repo_dir" "$target_link"
  echo "    linked"
fi

echo "==> Ensuring home-manager channel is present"
if sudo nix-channel --list | grep -q '^home-manager '; then
  echo "    already added"
else
  sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
  echo "    added"
fi
sudo nix-channel --update home-manager

echo "==> Adding required imports to $config"
sudo "$script_dir/add-import.sh" "<home-manager/nixos>" "$config"
sudo "$script_dir/add-import.sh" "./my-devbox/imports.nix" "$config"

echo "==> Validating configuration syntax"
nix-instantiate --parse "$config" >/dev/null
echo "    parse OK"

echo "==> Building and activating"
sudo nixos-rebuild switch
