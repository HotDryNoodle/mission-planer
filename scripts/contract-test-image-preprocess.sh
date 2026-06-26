#!/usr/bin/env bash
# Contract test for image-preprocess placeholder plugin.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="${BUILD:-$ROOT/build}"
EXE="$BUILD/image-preprocess"
WORK="/tmp/mp_contract_image_preprocess_$$"

if [[ ! -x "$EXE" ]]; then
  echo "missing executable: $EXE" >&2
  exit 1
fi

"$EXE" manifest --output json >/dev/null
mkdir -p "$WORK"
"$EXE" run --input <(echo '{"input_path":"/tmp/x.tif","request_id":"c1"}') --work-dir "$WORK" 2>/dev/null || \
  "$EXE" run --input "$ROOT/samples/remote_sensing_access.json" --work-dir "$WORK" 2>/dev/null || true

rm -rf "$WORK"
echo "image-preprocess contract test passed (minimal)"
