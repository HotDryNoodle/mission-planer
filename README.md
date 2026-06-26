# mission-planer

GMAT-based mission planning CLI plugin (`mission.remote_sensing_access`).

This repository contains **planning business logic only**. Task orchestration and other plugins live in sibling repos under `~/projects/`.

## Multi-repo layout

| Repository | Path | Role |
|------------|------|------|
| **satellite-plugin-sdk** | `~/projects/satellite-plugin-sdk` | `satellite_common`, schemas, `satellite-cli-plugin` skill |
| **task-manager** | `~/projects/task-manager` | TaskManager + task-client + ZMQ |
| **mission-planer** | `~/projects/mission-planer` | This repo — GMAT planning plugin |
| **image-preprocess** | `~/projects/image-preprocess` | Placeholder plugin |
| **satellite-workspace** | `~/projects/satellite-workspace` | Integration: `build-all-local.sh`, `plugins.index.json` |

```
Agent -> task-manager -> plugins (manifest + CLI) -> GMAT (mission-planer)
```

## Build

```bash
cd ~/projects/mission-planer
meson subprojects download
meson setup build
meson compile -C build
```

Depends on **satellite-plugin-sdk** via Meson wrap (`subprojects/satellite-plugin-sdk.wrap`).

## Contract test (run before integration)

```bash
./scripts/contract-test-mission-planer.sh
```

## Environment (TaskManager integration)

Prefer `SATELLITE_*` variables (see `task-manager` README):

| Variable | Purpose |
|----------|---------|
| `SATELLITE_PLUGIN_INDEX` | `plugins.index.json` (preferred) |
| `SATELLITE_PLUGIN_DIR` | Colon-separated manifest directories |
| `SATELLITE_PLUGIN_BIN` | Plugin executable search root |
| `SATELLITE_TASK_WORK_ROOT` | Task work directories |

Legacy `MISSION_PLANER_ROOT` / `MISSION_PLANER_BIN` are deprecated (one release).

## Full-stack integration

```bash
cd ~/projects/satellite-workspace
./scripts/build-all-local.sh
source install/env.sh
./install/bin/task-client --plugin-index "$SATELLITE_PLUGIN_INDEX" \
  --plugin-bin "$SATELLITE_PLUGIN_BIN" \
  ~/projects/mission-planer/samples/task_submit_short.json
```

## Business scenarios

| Scenario | Horizon | Step | Sensor | Key outputs |
|----------|---------|------|--------|-------------|
| `remote_sensing_access` | 2 days (`172800 s`) | `10 s` | optical linescan / area array | access windows, `t0_utc`, `phi_deg` |
| `attitude_estimation` | 5-30 min (`300-1800 s`) | `1 s` | optical area array (`stare`) | `attitude.t0_utc`, `attitude.phi_deg` |
| `downlink_window` | 1-2 h (`3600-7200 s`) | `5 s` | `downlink_cone` (optional) | `[start_utc, end_utc]` contact windows |

### Sensor support matrix (v0.1.0)

| Sensor | Access windows | Attitude | Notes |
|--------|----------------|----------|-------|
| `optical_linescan` + `side_roll_only` | supported | supported | Matches GMAT `Ex_OpticalSSO_Access` geometry |
| `optical_area_array` + `stare` | supported | supported | `pitch_deg` is placeholder only |
| `sar` | not implemented | not implemented | rejected unless `experimental.allow_sar=true` |
| `downlink_cone` | n/a | n/a | Downlink only; `cone_angle_deg` default `65` |

## CLI usage

```bash
./build/mission-planer manifest --output json
./build/mission-planer validate --input samples/remote_sensing_access.json
./build/mission-planer run --input samples/remote_sensing_access_gmat_compatible_2day.json --work-dir /tmp/mp_gmat_2day --output json
```

Environment: `GMAT_ROOT` — default GMAT install root if not set in request JSON.

## GMAT optical regression

Set `RUN_GMAT_INTEGRATION=1` with `./scripts/build_and_smoke.sh` for full GMAT regression.

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | success |
| 2 | validation error |
| 3 | missing dependency |
| 4 | no business result |
| 5 | retryable failure |
| 6 | fatal failure |

## New plugins

Use the skill in **satellite-plugin-sdk**:

```bash
cp -r ~/projects/satellite-plugin-sdk/.cursor/skills/satellite-cli-plugin ~/.cursor/skills/
```

See `~/projects/satellite-plugin-sdk/.cursor/skills/satellite-cli-plugin/SKILL.md`.
