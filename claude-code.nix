{ claude-code, fetchurl }:

claude-code.overrideAttrs (oldAttrs: rec {
  version = "2.1.233";

  src = fetchurl {
    url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/linux-arm64/claude";
    sha256 = "sha256-Qt8YQfdOmyrBPywaKoIO9rmsWy77hka7JcmpK4vWkZQ=";
  };
})
