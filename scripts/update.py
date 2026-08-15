#!/usr/bin/env python3
"""Update all source-controlled package pins in package-registry.toml."""

import json
import pathlib
import re
import subprocess
import sys
import tomllib

root = pathlib.Path(__file__).resolve().parent.parent
registry = tomllib.loads((root / "package-registry.toml").read_text())["packages"]
changes = []

for name, spec in registry.items():
    tags = subprocess.check_output(
        ["git", "ls-remote", "--refs", "--tags", f"https://github.com/{spec['repository']}.git", f"{spec['tag_prefix']}*"],
        text=True,
    )
    stable = []
    for line in tags.splitlines():
        tag = line.rsplit("/", 1)[-1]
        version = tag.removeprefix(spec["tag_prefix"])
        if re.fullmatch(r"\d+\.\d+\.\d+", version):
            stable.append((tuple(map(int, version.split("."))), tag, version))
    if not stable:
        raise SystemExit(f"{name}: no stable upstream version found")
    _, tag, version = max(stable)

    url = f"https://github.com/{spec['repository']}/releases/download/{tag}/{spec['asset']}"
    prefetched = json.loads(subprocess.check_output(
        ["nix", "--extra-experimental-features", "nix-command", "store", "prefetch-file", "--json", url],
        text=True,
    ))
    source_hash = prefetched["hash"]
    path = root / spec["file"]
    text = path.read_text()
    current = re.search(r'^  version = "([^"]+)";', text, re.MULTILINE)
    if current is None:
        raise SystemExit(f"{name}: version assignment not found in {path}")
    if current.group(1) == version:
        print(f"{name}: already at {version}")
        continue
    text, version_count = re.subn(
        r'^(  version = ")[^"]+(";)$', rf'\g<1>{version}\2', text, count=1, flags=re.MULTILINE
    )
    text, hash_count = re.subn(
        r'^(    sha256 = ")[^"]+(";)$', rf'\g<1>{source_hash}\2', text, count=1, flags=re.MULTILINE
    )
    if version_count != 1 or hash_count != 1:
        raise SystemExit(f"{name}: expected one version and one sha256 assignment in {path}")
    changes.append((name, current.group(1), version, path, text))

# Do not modify any file until every upstream version and hash has succeeded.
for name, old, new, path, text in changes:
    path.write_text(text)
    print(f"{name}: {old} -> {new}")

subprocess.run(["nix-instantiate", "--parse", str(root / "nixos.nix.tmpl")], check=True, stdout=subprocess.DEVNULL)
for _, _, _, path, _ in changes:
    subprocess.run(["nix-instantiate", "--parse", str(path)], check=True, stdout=subprocess.DEVNULL)
print("Review the changes, then activate with ./scripts/bootstrap.sh.")
