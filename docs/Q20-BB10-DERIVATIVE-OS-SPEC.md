# Q20 BB10-Derivative ChimeraOS Specification (Custom Autoloader Research Track)

This document defines the **BB10-derived OS** path for the BlackBerry Classic (Q20): a research track that preserves the QNX microkernel and BB10 driver stack while installing ChimeraOS components as the dominant user experience via a custom autoloader-based workflow.

## Goals

- Keep the stock QNX kernel and hardware drivers intact.
- Install ChimeraOS UI, services, and tooling as the primary shell and user environment.
- Maintain a recovery path to stock BB10 at all times.
- Treat this as an experimental overlay/installer, not a guaranteed firmware replacement.

## Target Device

- **Device:** BlackBerry Classic (Q20), exact hardware variant (SQC100-1/2/3 or other).
- **OS baseline:** Official BB10 10.3.x autoloader matched to the exact device variant.

## Architecture Overview

- **Base:** Stock BB10 QNX image (signed) loaded via official autoloader.
- **Overlay:** ChimeraOS user-space components installed post-flash via:
  - A signed/verified application set (WebWorks/.bar, native helpers where permitted).
  - Optional modified system-image research only after full backup and recovery validation.
- **Constraint:** BB10 images are signed; arbitrary modified firmware images are not guaranteed to boot on retail Q20 hardware.

## Repository Structure

```
ChimeraOS/
  docs/
    Q20-BB10-DERIVATIVE-OS-SPEC.md
  q20-bb10-overlay/
    manifest/
      device-variants.md
      base-os-versions.md
      chimera-components.md
    install/
      overlay-install-plan.md
      post-install-scripts.md
    uninstall/
      rollback-plan.md
    verification/
      integrity-checks.md
      recovery-tests.md
```

## Step 1: Device and Base OS Inventory

1. Identify the exact Q20 variant:
   - Model (e.g., SQC100-1, SQC100-2, SQC100-3).
   - Current OS version and carrier branding.
2. Acquire the matching official autoloader for that variant from trusted archives.
3. Document the baseline image hash and version in `manifest/base-os-versions.md`.

Do not mix autoloaders across variants. Use only images that match the device exactly.

## Step 2: Baseline Flash and Backup

1. Before any experiment, perform a full backup:
   - Use BB10 backup tools to capture user data and app state.
   - Record the current OS version and build ID.
2. Flash the stock autoloader to ensure a known-good baseline.
3. Verify:
   - Device boots cleanly.
   - All radios, sensors, and basic functions operate.
   - You can re-enter development mode if needed.

Only proceed to overlay experiments after confirming a reliable rollback path.

## Step 3: ChimeraOS Overlay Design

Design the overlay as a set of installable components rather than a monolithic firmware edit:

- **Launcher:** The WebWorks/Cordova `.bar` from `Q20-FULL-LAUNCHER-SPEC.md`.
- **Services:** Optional background helpers permitted by BB10 (notifications, local storage, permitted sensors).
- **Tools:** Diagnostics, package vault, update checker, and configuration UI.
- **Integration:** Document how each component is installed, configured, and removed.

Record all assumptions about available APIs and permissions. Do not assume the ability to replace core system apps unless you have verified evidence on Q20.

## Step 4: Overlay Installation Workflow

Define a reproducible installation sequence in `install/overlay-install-plan.md`:

1. Start from a known-good stock BB10 image.
2. Enable development mode and configure device trust.
3. Deploy the Chimera Launcher `.bar` and supporting apps.
4. Apply configuration profiles (if using enterprise/kiosk features).
5. Validate:
   - Boot-to-user flow.
   - Launcher start and resilience.
   - Recovery to stock home if the launcher crashes or is removed.

Keep the overlay reversible: uninstalling Chimera components should return the device to a stock-like state.

## Step 5: Custom Autoloader Research (Experimental)

This sub-track explores whether a modified BB10 image can be built and flashed:

- Begin with an official autoloader and extract its filesystem image using community tools.
- Research how BB10 packages system applications and configuration.
- Investigate whether Chimera components can be pre-bundled into a custom image that still passes signature checks or is accepted in a development/trust context.
- Maintain strict documentation of:
  - Which files are modified.
  - How signatures and integrity checks are handled.
  - What failure modes exist and how to recover.

Do not claim success until you have a reproducible, documented process that boots on a real Q20 and can be rolled back reliably.

## Step 6: Verification and Recovery

In `verification/`, define:

- Integrity checks for base images and overlay artifacts (hashes, signatures where applicable).
- Recovery tests:
  - Re-flash stock autoloader after overlay experiments.
  - Confirm device returns to normal operation.
  - Document time and steps required for recovery.

The project must treat recovery as a first-class feature, not an afterthought.

## Pipeline Integration

- Add a `build-q20-bb10-overlay` target that:
  - Packages overlay components and manifests.
  - Produces a versioned artifact (ZIP/TAR) with hashes and SBOM entries.
- Link this artifact to the existing ChimeraOS CI workflow, but mark it as experimental and device-variant-specific.

## Safety and Expectations

- This track is experimental and may never achieve a fully custom ROM on retail Q20 hardware due to signature and secure-boot constraints.
- All work must be performed on devices you own and accept the risk of bricking.
- Never distribute modified BB10 images or signing keys.
- Focus on a reversible overlay model that enhances the user experience without breaking the base OS.

**Status:** Research and overlay integration track; firmware-level customization is gated by BB10 signing and secure-boot behavior on Q20.
