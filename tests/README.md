# Fresh-install test

`default.nix` boots a new NixOS 25.11 VM, activates the Home Manager profile
for a new `devbox` user, and verifies Pi plus its extensions were installed.

Run it from the repository root:

```sh
nix-build tests/default.nix
```

The test uses the Nixpkgs and Home Manager channels in `NIX_PATH`. Use the
NixOS 25.11 and matching Home Manager channels.
