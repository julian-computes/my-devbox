{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "herdr";
  version = "0.8.0";

  src = fetchurl {
    url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-linux-aarch64";
    sha256 = "11yalf10vz4d03y0c5k4c3m0m3s6hjr4ylzy8b3gp7ld8rkaqizn";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/herdr
    runHook postInstall
  '';

  meta = {
    description = "Terminal workspace manager for AI coding agents";
    homepage = "https://herdr.dev";
    license = lib.licenses.asl20;
    mainProgram = "herdr";
    platforms = [ "aarch64-linux" ];
  };
}
