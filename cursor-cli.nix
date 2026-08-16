{ cursor-cli, fetchurl, zlib }:

cursor-cli.overrideAttrs (oldAttrs: rec {
  version = "2026.08.11-e8db854";

  src = fetchurl {
    url = "https://downloads.cursor.com/lab/${version}/linux/arm64/agent-cli-package.tar.gz";
    sha256 = "sha256-6hP5LilfUjqZzo2PV9aJTSHl0eLQMP+tcYzNWVXKLu0=";
  };

  # Newer releases bundle a native addon linked against zlib; the pinned
  # nixos-25.11 derivation predates that and doesn't list it as a dependency.
  buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ zlib ];
})
