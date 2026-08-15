default:
    @just --list

reload:
    ./scripts/bootstrap.sh

test:
    nix-build tests/default.nix
