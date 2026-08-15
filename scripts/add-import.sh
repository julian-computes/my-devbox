#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: add-import.sh <import-expression> [target-file]

Adds <import-expression> as a new entry in the `imports = [ ... ];` list of
a NixOS/home-manager module file, preserving existing formatting.
Idempotent: if the expression already appears anywhere in the file, this is
a no-op. Validates the resulting file with `nix-instantiate --parse` before
writing it, and never touches the target file if parsing fails.

target-file defaults to /etc/nixos/configuration.nix.

Examples:
  add-import.sh ./my-devbox/imports.nix
  add-import.sh '<home-manager/nixos>'
  add-import.sh ./packages.nix ~/.config/my-devbox/home.nix
USAGE
}

if [[ $# -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  [[ $# -lt 1 ]] && exit 1 || exit 0
fi

import_expr=$1
target=${2:-/etc/nixos/configuration.nix}

if [[ ! -f "$target" ]]; then
  echo "error: $target does not exist" >&2
  exit 1
fi

if grep -qF -- "$import_expr" "$target"; then
  echo "already present in $target: $import_expr"
  exit 0
fi

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

awk -v newimport="$import_expr" '
BEGIN { in_imports=0; depth=0; inserted=0; indent="  " }
{
  orig=$0
  if (!inserted) {
    if (in_imports==0 && orig ~ /imports[ \t]*=/) { in_imports=1 }
    if (in_imports==1) {
      tmp=orig; open_c=gsub(/\[/,"[",tmp)
      tmp2=orig; close_c=gsub(/\]/,"]",tmp2)
      prev_depth=depth
      depth+=open_c-close_c
      if (prev_depth>0 && depth>0) {
        match(orig, /^[ \t]*/)
        cand=substr(orig, RSTART, RLENGTH)
        if (cand != "") indent=cand
      }
      if (prev_depth>0 && depth<=0) {
        print indent newimport
        print orig
        inserted=1
        next
      }
    }
  }
  print orig
}
END {
  if (!inserted) {
    print "error: no imports = [ ... ] list found in target file" > "/dev/stderr"
    exit 1
  }
}
' "$target" > "$tmp"

if command -v nix-instantiate >/dev/null 2>&1; then
  if ! nix-instantiate --parse "$tmp" >/dev/null 2>&1; then
    echo "error: resulting file failed to parse; aborting, nothing written" >&2
    nix-instantiate --parse "$tmp"
    exit 1
  fi
fi

cp "$tmp" "$target"
echo "added '$import_expr' to $target"
