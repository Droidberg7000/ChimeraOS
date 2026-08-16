# Q20 Test and Recovery Gate

## Purpose

Before any experimental overlay or firmware work, you must prove you can reliably restore the device to a known-good stock state. This gate defines the minimum tests and recovery requirements.

## Prerequisites

- Exact Q20 variant recorded (e.g., SQC100-1/2/3).
- A stock, matching autoloader archived and hash-verified.
- A current user backup (contacts, media, app data).
- A documented rollback procedure reviewed before each test.

## Required Test Matrix

### T1: Stock restore

1. Record current OS version and build ID.
2. Perform a full user backup.
3. Flash the exact-match stock autoloader.
4. Verify:
   - Device boots to stock BB10.
   - Radios, sensors, and basic functions operate.
   - User data can be restored.

### T2: App lifecycle

1. Sideload the ChimeraOS `.bar`.
2. Validate:
   - Launch, navigation, storage, suspend/resume, and close.
   - Uninstall returns the device to prior behavior.

### T3: Capability degradation

1. Disable or omit optional BB10 APIs.
2. Confirm the launcher degrades safely (no crashes, visible fallbacks).

### T4: Module safety

1. Install an example theme module.
2. Activate and verify UI changes are app-local only.
3. Uninstall and verify no persistent side effects.

## Exit Criteria

All of the following must be true before Stage D (overlay research):

- T1–T4 pass on the same physical device to be used for experiments.
- Stock autoloader hash matches the archived copy.
- Rollback procedure is documented and practiced.
- A second, independent reviewer confirms the restore steps.

## Safety Notes

- Never flash untested images.
- Keep a serial/JTAG recovery path available if you have one.
- Maintain backups of all partitions before any experiment.
