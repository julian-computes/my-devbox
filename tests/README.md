# Fresh-install test

`default.nix` boots a new NixOS 25.11 VM, activates the Home Manager profile
for a new `devbox` user, and verifies Pi plus its extensions were installed.

Run it from the repository root:

```sh
sudo nix-build --option sandbox false tests/default.nix
```

The test uses the Nixpkgs and Home Manager channels in `NIX_PATH`. Use the
NixOS 25.11 and matching Home Manager channels. It deliberately disables the
Nix build sandbox so the VM can access npm and install the real Pi packages.
`sudo` is required because changing Nix's sandbox setting is restricted to
trusted users.
