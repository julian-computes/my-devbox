{ lib, stdenvNoCC, fetchurl, versionCheckHook }:

stdenvNoCC.mkDerivation rec {
  pname = "codex";
  version = "0.147.0";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-aarch64-unknown-linux-musl.tar.gz";
    sha256 = "62d8gPZmsauLSx0IO2bo1hSxKB2WC7b5/Yypj1izi5A=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/codex-aarch64-unknown-linux-musl
    ln -s codex-aarch64-unknown-linux-musl $out/bin/codex
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    platforms = [ "aarch64-linux" ];
  };
}
