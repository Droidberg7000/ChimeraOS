# Q20 Recovery and Rollback Procedures (All Three Paths)

This document defines recovery and rollback procedures for the three Q20 ChimeraOS tracks:

1. **Full Launcher** (WebWorks/Cordova `.bar`)
2. **BB10-Derivative OS** (custom autoloader / overlay research)
3. **Standalone OS** (bare-metal Linux/other research)

It is written to keep every experiment reversible and to minimize the risk of leaving a Q20 in an unusable state.

## General Principles

- Always start from a known-good baseline before experiments.
- Maintain a tested path back to stock BB10 for each track.
- Document every change that affects boot, system apps, or user data.
- Never consider an experiment complete until rollback has been verified.

## Prerequisites

- A Windows/macOS/Linux host with:
  - BB10 drivers and device connectivity configured.
  - Access to official Q20 autoloaders matched to your exact device variant.
- A Q20 device with:
  - Development mode enabled (for launcher and overlay work).
  - A known BB10 version and build ID recorded.
- Backups:
  - Full BB10 backup of user data and app state before any major change.
  - Notes on current OS version, hardware variant, and any prior modifications.

## Path 1: Full Launcher Recovery

### Normal Operation

- Chimera Launcher is installed as a regular `.bar` application.
- The stock BB10 home, lock screen, and system UI remain intact.

### Rollback Steps

1. **Uninstall Chimera Launcher:**
   - On-device: Long-press the app icon → Remove, or use Settings → App Manager.
   - Or via CLI:
     ```bash
     blackberry-deploy -uninstallApp -device <Q20_IP> -password <DEVICE_PASSWORD> com.chimeraos.q20launcher
     ```
2. **Reboot the device** to ensure a clean state.
3. **Verify:**
   - Stock home screen operates normally.
   - No residual Chimera services are running.

### Failure Modes

- **Launcher crashes or hangs:**
  - Reboot the device; the stock home will load.
  - Reinstall or update the launcher after confirming stability.
- **Launcher prevents normal use:**
  - Boot into safe mode if supported, or manually uninstall via App Manager.
  - If necessary, re-flash the stock autoloader (see Path 2 recovery).

## Path 2: BB10-Derivative OS Recovery

### Baseline Definition

- Define a baseline image:
  - Exact autoloader filename and version.
  - Device variant (e.g., SQC100-1/2/3).
  - Hash of the autoloader file.
- Record this in `q20-bb10-overlay/manifest/base-os-versions.md`.

### Before Overlay Experiments

1. **Backup:**
   - Perform a full BB10 backup.
   - Export app lists and critical data.
2. **Flash stock autoloader:**
   - Use the official autoloader for your exact Q20 variant.
   - Confirm the device boots and functions normally.
3. **Document:**
   - OS version, build ID, and any carrier branding.

### Overlay Installation

- Install Chimera components as documented in `Q20-BB10-DERIVATIVE-OS-SPEC.md`.
- Keep a list of all installed packages, configuration changes, and modified files.

### Rollback Steps

1. **Remove overlay components:**
   - Uninstall Chimera apps and helpers.
   - Revert configuration changes where possible.
2. **If the system is unstable or modified at the image level:**
   - Re-flash the stock autoloader:
     - Run the official autoloader for your Q20 variant.
     - Allow the process to complete without interruption.
3. **Post-flash validation:**
   - Confirm the device boots to stock BB10.
   - Verify radios, sensors, and basic functions.
   - Restore user data from backup if needed.

### Failure Modes

- **Device fails to boot after overlay changes:**
  - Re-flash the stock autoloader immediately.
  - If the device is not detected, try:
    - Different USB ports/cables.
    - Battery pull (if removable) and reinsert, then retry.
- **Persistent boot loops:**
  - Use the official autoloader in recovery mode as documented for BB10 devices.
  - If recovery fails, seek community support with exact error messages and device state.

## Path 3: Standalone OS Recovery

### Research-Only Status

- This track is explicitly research-only until a verified boot path exists.
- No image is considered ready for general flashing until:
  - A serial or equivalent debug console is available.
  - A tested recovery procedure to stock BB10 is documented.
  - The boot image has been proven on real Q20 hardware in a controlled manner.

### Pre-Experiment Requirements

Before any boot-chain or firmware experiments:

1. **Serial/Debug Access:**
   - Identify and test serial console or debug interfaces.
   - Confirm you can access a boot log or shell in some known state.
2. **Stock Recovery Plan:**
   - Confirm that the official autoloader can restore the device after a failed boot.
   - Practice at least one full stock flash and verification cycle.
3. **Backup:**
   - Full BB10 backup plus notes on partition layout and bootloader state.

### Rollback Steps

1. **If a custom boot image fails:**
   - Use serial/debug access to diagnose the failure.
   - If the device is soft-bricked but still detectable, re-flash the stock autoloader.
2. **If the device appears dead:**
   - Try battery removal/reinsertion (if applicable) and USB reconnection.
   - Retry the official autoloader process.
   - If still unresponsive, document all symptoms and seek hardware-level assistance.
3. **After successful recovery:**
   - Verify full BB10 functionality.
   - Update `Q20-STANDALONE-OS-RESEARCH.md` with lessons learned and any new recovery steps.

### Failure Modes

- **No serial output, no USB detection:**
  - Suspect hardware-level damage or boot ROM lock.
  - Document all steps taken and consider hardware diagnostics.
- **Partial boot (logo, then freeze):**
  - Use serial logs to identify the failure point.
  - Revert to the last known-good image or stock autoloader.

## Common Recovery Commands and Tools

- **Autoloader:** Official BB10 autoloader for Q20, matched to device variant.
- **blackberry-deploy:** For app install/uninstall and device communication.
- **BB10 backup tools:** For user data and app state backups.

Example uninstall command:

```bash
blackberry-deploy -uninstallApp -device <Q20_IP> -password <DEVICE_PASSWORD> <APP_ID>
```

## Documentation Requirements

For every experiment:

- Record:
  - Device variant and OS version before and after.
  - Exact files, images, or packages used.
  - Any errors or unexpected behavior.
- Update:
  - `Q20-RECOVERY-AND-ROLLBACK.md` if new recovery steps are discovered.
  - The relevant path spec (`Q20-FULL-LAUNCHER-SPEC.md`, `Q20-BB10-DERIVATIVE-OS-SPEC.md`, `Q20-STANDALONE-OS-RESEARCH.md`) with new findings.

## Safety Notes

- Only work on devices you own and accept the risk for.
- Do not distribute modified boot images or exploits until they are safe, documented, and reproducible.
- Treat recovery as a first-class feature of every experiment, not an afterthought.

**Status:** This document is a living specification; update it as new recovery methods or risks are discovered for Q20.
