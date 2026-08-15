default:
    @just --list

reload:
    ./scripts/bootstrap.sh

test:
    sudo nix-build --option sandbox false tests/default.nix
