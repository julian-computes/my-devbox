# AGENTS.md

Write plans in simplified technical English.

Make configuration changes in this repository so they are source controlled. Do not edit deployed files in the home directory directly.

After changing configuration, always apply it from this repository before replying. Use the repository's supported activation command; do not apply changes by editing deployed files directly.

When adding tools, update the installed-tool list in `agent-instructions.md`.

Checkout-only skills and packages go in gitignored `local/`. See README.md.
Do not commit `local/` or put those extras in tracked `skills/` or `packages.nix`.

Herdr is a terminal multiplexer.

For Herdr usage instructions, run `herdr --skill`.
