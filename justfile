default:
    @just --list

reload:
    ./scripts/bootstrap.sh

test:
    nix-build --option sandbox false tests/default.nix
