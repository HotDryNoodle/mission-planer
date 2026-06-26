#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build"
TM_BUILD="${TASK_MANAGER_BUILD:-$HOME/projects/task-manager/build}"
MP_BUILD="${MISSION_PLANER_BUILD:-$ROOT/build}"
IP_BUILD="${IMAGE_PREPROCESS_BUILD:-$HOME/projects/image-preprocess/build}"

meson subprojects download
meson setup "$BUILD" "$@"
meson compile -C "$BUILD"

echo "==> Contract test (mission-planer)"
"$ROOT/scripts/contract-test-mission-planer.sh"

echo "==> CLI smoke"
"$BUILD/mission-planer" manifest --output json >/dev/null
"$BUILD/mission-planer" --version
"$BUILD/mission-planer" validate --input "$ROOT/samples/remote_sensing_access.json"
"$BUILD/mission-planer" run --input "$ROOT/samples/remote_sensing_access.json" --work-dir /tmp/mp_smoke --dry-run

SKILL_SMOKE="$HOME/projects/satellite-plugin-sdk/.cursor/skills/satellite-cli-plugin/scripts/smoke_plugin.sh"
if [[ -x "$SKILL_SMOKE" ]]; then
  echo "==> SDK skill smoke"
  "$SKILL_SMOKE" --root "$ROOT" --build "$BUILD" mission-planer
fi

if [[ -x "$TM_BUILD/task-client" && -x "$MP_BUILD/mission-planer" ]]; then
  echo "==> Cross-repo TaskManager smoke"
  "$ROOT/scripts/generate-plugins-index.sh" "$ROOT/config/plugins.index.json"
  export SATELLITE_PLUGIN_INDEX="$ROOT/config/plugins.index.json"
  export SATELLITE_PLUGIN_BIN="$MP_BUILD"
  set +e
  "$TM_BUILD/task-client" --plugin-index "$SATELLITE_PLUGIN_INDEX" --plugin-bin "$SATELLITE_PLUGIN_BIN" \
    --work-root /tmp/mp_tasks "$ROOT/samples/task_submit_short.json"
  task_client_status=$?
  set -e
  if [[ "$task_client_status" != "0" && "$task_client_status" != "4" ]]; then
    exit "$task_client_status"
  fi
else
  echo "Skip TaskManager smoke (build ../task-manager first)"
fi

if [[ "${RUN_GMAT_INTEGRATION:-0}" == "1" ]]; then
  echo "==> GMAT integration regression"
  WORK="$ROOT/var/regression/smoke_gmat_compatible_2day"
  mkdir -p "$WORK"
  "$BUILD/mission-planer" run --input "$ROOT/samples/remote_sensing_access_gmat_compatible_2day.json" --work-dir "$WORK" --output json >/dev/null
fi

echo "Build and smoke checks completed."
