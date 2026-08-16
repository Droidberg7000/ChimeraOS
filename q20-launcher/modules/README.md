# ChimeraOS Modules (App-Level)

These modules are **app-level configuration packs** for the Q20 launcher. They are not OS packages and do not modify BB10 system partitions, boot images, or privileged services.

## Allowed

- Local UI themes (colors, spacing, icon references).
- Tile layout presets for the launcher grid.
- Local configuration (feature flags, experiment toggles).

## Not Allowed

- Root, privilege escalation, or QNX system writes.
- Boot image or system partition modification.
- LED driver, keyboard driver, or baseband modification.
- Process injection or exploit code.

## Format

```
modules/
  example-theme/
    module.json
    theme.json
```

`module.json` defines metadata and version. `theme.json` defines UI-only values used by the launcher.
