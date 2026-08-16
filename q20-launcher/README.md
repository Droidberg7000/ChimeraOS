# ChimeraOS Q20 Launcher

A local-first WebWorks/Cordova launcher shell for the BlackBerry Classic (Q20) on stock BB10, part of the main **ChimeraOS** project.

## Scope

- Full-screen application-shell experience: launcher tiles, package-vault catalogue, diagnostics, and safe capability telemetry.
- Q20-friendly UI intended for 720x720 display, keyboard, and trackpad use.
- No claim of privileged home-screen replacement, system-wide package control, or privileged system telemetry.
- This is the ChimeraOS launcher for Q20, not the JavaBoyChimera emulator sub-project.

## Local setup

Install a Cordova version compatible with the BB10 tooling you have installed, then:

```bash
cd q20-launcher
npm install
npm run prepare:bb10
npm run build:bb10
```

For a release build, configure BB10 signing locally and run:

```bash
npm run release:bb10
```

Use the repository wrapper to deploy a built `.bar`:

```bash
../scripts/deploy-q20-launcher.sh --device-ip <Q20_IP> --device-password <DEVICE_PASSWORD>
```

Never commit device passwords, signing keys, tokens, CSK/TSK files, or generated signing databases.

## Integration

- Read `docs/Q20-FULL-LAUNCHER-SPEC.md` for the implementation plan.
- Read `docs/Q20-RECOVERY-AND-ROLLBACK.md` before device experiments.
- The main ChimeraOS services and apps live in the parent repo (`services/`, `apps/`, `repos/`); this launcher is the Q20 shell that can surface them.
- JavaBoyChimera is a separate sub-project and is not built or deployed by this launcher.
