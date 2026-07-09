# mission-planer

> **Deprecated (2026-07-09)** — This repository has been renamed to [`access-computer`](https://github.com/HotDryNoodle/access-computer). Use `satellite-workspace` with `plugins/access-computer/` for all new work. Distributed mission orchestration remains in [`task-manager`](https://github.com/HotDryNoodle/task-manager).

GMAT-based mission planning CLI plugin (`mission.remote_sensing_access`).

This repository contains **planning business logic only** — three mission planning scenarios backed by GMAT.

## Build

```bash
meson subprojects download
meson setup build
meson compile -C build
```

Depends on **satellite-plugin-sdk** via Meson wrap (`subprojects/satellite-plugin-sdk.wrap`).

## Contract test

```bash
./scripts/contract-test-mission-planer.sh
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
