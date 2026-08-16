# Q20 ChimeraOS Three-Paths Index

This document is the master index for the three Q20 ChimeraOS tracks. It links specifications, scripts, and recovery procedures, and explains how they relate to each other and to the existing ChimeraOS build pipeline.

## Paths Overview

| Path | Spec | Goal | Risk | Maturity |
|------|------|------|------|----------|
| **Full Launcher** | `Q20-FULL-LAUNCHER-SPEC.md` | Signed WebWorks/Cordova `.bar` that acts as a full-screen custom home on stock BB10 | Low (app-level) | Near-term, achievable |
| **BB10-Derivative OS** | `Q20-BB10-DERIVATIVE-OS-SPEC.md` | Custom autoloader / overlay research that keeps QNX/BB10 kernel and drivers while installing Chimera as the dominant user experience | Medium (firmware experiments, but reversible) | Experimental |
| **Standalone OS** | `Q20-STANDALONE-OS-RESEARCH.md` | Bare-metal Linux/other on Q20 hardware, bypassing BB10 boot chain | High (boot-chain, potential bricking) | Long-term research |

All three paths share:

- Recovery and rollback procedures: `Q20-RECOVERY-AND-ROLLBACK.md`
- Build and verification scripts: `scripts/build-q20-launcher.sh`, `scripts/deploy-q20-launcher.sh`, `scripts/q20-backup-state.sh`, `scripts/q20-verify-artifacts.sh`
- CI scaffolding: `.github/workflows/q20-launcher-build.yml` (and future workflows for overlay/research)

## Relationship to Existing Docs

- `BUILD-Q20.md`: Existing Q20 build notes; treat this index as the updated, three-path view.
- `BB10-Mac-Linux-Bootstrap.md`: Environment setup for BB10 tooling; used primarily by the Full Launcher and BB10-Derivative tracks.
- `blackberry-package-source-index.md`, `blackberry-devices-tls-workaround-pack.md`, `BB10_APK_Compatibility_Repository.pdf`: Reference material for BB10 packages and compatibility; relevant to launcher and overlay component selection.
- `chimeraos_workflow_README.md`: Existing ChimeraOS workflow documentation; extend it with Q20-specific targets once the three-path structure is stable.

## Directory Map

```
ChimeraOS/
  docs/
    BUILD-Q20.md
    BB10-Mac-Linux-Bootstrap.md
    Q20-THREE-PATHS-INDEX.md
    Q20-FULL-LAUNCHER-SPEC.md
    Q20-BB10-DERIVATIVE-OS-SPEC.md
    Q20-STANDALONE-OS-RESEARCH.md
    Q20-RECOVERY-AND-ROLLBACK.md
    blackberry-package-source-index.md
    blackberry-devices-tls-workaround-pack.md
    BB10_APK_Compatibility_Repository.pdf
    chimeraos_workflow_README.md
  q20-launcher/
    (Cordova/WebWorks project; see Q20-FULL-LAUNCHER-SPEC.md)
  q20-bb10-overlay/
    (BB10-derived OS research; see Q20-BB10-DERIVATIVE-OS-SPEC.md)
  q20-standalone/
    (Standalone OS research; see Q20-STANDALONE-OS-RESEARCH.md)
  scripts/
    build-q20-launcher.sh
    deploy-q20-launcher.sh
    q20-backup-state.sh
    q20-verify-artifacts.sh
  build/
    q20-launcher/
    q20-bb10-overlay/
    q20-standalone/
    q20-artifacts.sha256
  .github/workflows/
    q20-launcher-build.yml
    (future: q20-bb10-overlay-build.yml, q20-standalone-research.yml)
```

## How to Use This Index

1. **Choose your path:**
   - If you want a working, flashable experience on stock Q20: start with **Full Launcher**.
   - If you want to experiment with BB10 images while keeping recovery: follow **BB10-Derivative OS**.
   - If you want to research bare-metal OS on Q20 long-term: follow **Standalone OS**.

2. **Read the corresponding spec:**
   - Each spec defines goals, architecture, steps, and constraints for its path.

3. **Use shared scripts and recovery docs:**
   - All paths rely on `Q20-RECOVERY-AND-ROLLBACK.md` for safety.
   - Launcher scripts are primarily for the Full Launcher path but can be adapted.

4. **Integrate with ChimeraOS workflow:**
   - Extend the existing ChimeraOS CI and workflow bundle to include Q20 targets.
   - Keep JavaBoyChimera and other components as first-class citizens in the launcher vault and rootfs plans.

## Status Summary

- **Full Launcher:** Ready for implementation on stock Q20; no boot-chain changes required.
- **BB10-Derivative OS:** Experimental overlay/installer track; must maintain a tested rollback to stock.
- **Standalone OS:** Long-term research; no flashable images until a verified boot path and recovery are established.

## Note on JavaBoyChimera

JavaBoyChimera is a separate sub-project (Game Boy Color/Java emulator work) and is not part of this Q20 launcher build. The Q20 launcher targets the main ChimeraOS project and its services (`services/`, `apps/`, `repos/`).

Update this index as new scripts, workflows, or milestones are added.
