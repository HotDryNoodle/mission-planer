# Moved: plugin scaffold is now in the Cursor skill

All scaffold files, `init_plugin.sh`, and `smoke_plugin.sh` live in:

```
.cursor/skills/satellite-cli-plugin/
├── SKILL.md
├── scripts/init_plugin.sh
├── scripts/smoke_plugin.sh
└── scaffold/          # full template bundle
```

## Quick start

```bash
.cursor/skills/satellite-cli-plugin/scripts/init_plugin.sh \
  --executable telemetry-query \
  --tool-name telemetry.query \
  --domain telemetry \
  --root .
```

## Copy to other projects

```bash
cp -r .cursor/skills/satellite-cli-plugin ~/.cursor/skills/
```

GMAT script templates (`optical_access.script.in`, etc.) remain in `templates/` at repo root.
