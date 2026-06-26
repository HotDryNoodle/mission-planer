#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="${BUILD:-$ROOT/build}"
OUT="${1:-$ROOT/config/plugins.index.json}"
GENERATED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

python3 - "$ROOT" "$BUILD" "$OUT" "$GENERATED_AT" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
build = pathlib.Path(sys.argv[2])
out = pathlib.Path(sys.argv[3])
generated_at = sys.argv[4]
plugins = []

for manifest_path in sorted((root / "configs/plugins").glob("*.json")):
    if manifest_path.name == "plugins.index.json":
        continue
    manifest = json.loads(manifest_path.read_text())
    exe_name = manifest["executable"]
    exe_resolved = build / exe_name
    if not exe_resolved.exists():
        exe_resolved = build / exe_name
    plugins.append(
        {
            "tool_name": manifest["name"],
            "manifest_path": str(manifest_path.resolve()),
            "executable_resolved": str(exe_resolved.resolve()),
            "plugin_version": manifest.get("version", "0.0.0"),
            "schema_version": manifest.get("schema_version", "1.0"),
        }
    )

index = {
    "schema_version": "1.0",
    "generated_at_utc": generated_at,
    "plugins": plugins,
}
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(index, indent=2) + "\n")
print(f"wrote {out}")
PY
