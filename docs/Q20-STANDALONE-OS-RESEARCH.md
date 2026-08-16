# Q20 Standalone ChimeraOS Research Specification (Bare-Metal OS on Q20)

This document defines the **Standalone OS** path for the BlackBerry Classic (Q20): a long-term research effort to boot a non-BB10 operating system (e.g., mainline Linux) directly on Q20 hardware, bypassing or replacing the stock boot chain.

## Goals

- Achieve bare-metal execution of a custom OS on Q20.
- Preserve or re-implement hardware support (display, input, radios, sensors, storage).
- Maintain a clear boundary between research artifacts and flashable firmware; nothing is considered flashable until a verified, reproducible boot path exists.

## Target Device

- **Device:** BlackBerry Classic (Q20), Qualcomm Snapdragon S4 Plus (MSM8960-class).
- **Current OS:** BB10 (QNX-based) with signed boot chain.

## Architecture Overview

- **Boot chain:** Retail Q20 devices use a signed boot process (PBL/SBL1/hypervisor/QNX). Public, turnkey exploits for Q20 are not established in the same way as limited Passport/Priv work.
- **SoC:** MSM8960 has mainline Linux support in principle, but device-specific enablement (display, power, peripherals) requires significant work.
- **Strategy:** Treat this as a research tree that produces knowledge, prototypes, and eventually a bootable image only after all safety and recovery criteria are met.

## Repository Structure

```
ChimeraOS/
  docs/
    Q20-STANDALONE-OS-RESEARCH.md
  q20-standalone/
    boot-research/
      boot-chain-notes.md
      exploit-leads.md
      serial-debug-notes.md
    kernel/
      kernel-config-notes.md
      msm8960-upstream-status.md
      patch-queue.md
    device-tree/
      q20-dts-plan.md
      hardware-mapping-notes.md
    initramfs/
      base-initramfs-plan.md
      console-and-recovery.md
    rootfs-overlay/
      chimera-rootfs-plan.md
      package-selection.md
    hardware-inventory/
      display.md
      input.md
      storage.md
      power-and-battery.md
      radios.md
      sensors.md
      audio.md
      cameras.md
```

## Step 1: Boot-Chain Research

In `boot-research/`:

- Document the Q20 boot sequence as understood from public sources and community reports.
- Collect leads on:
  - Bootloader vulnerabilities or debug paths.
  - Serial/JTAG interfaces and pinouts.
  - Any existing Q20-specific boot exploits or prototype firmware work.
- Maintain a clear status field for each lead:
  - Unverified, partially verified, reproducible, or abandoned.

Current public reporting indicates that Q20 lacks a widely confirmed, turnkey bootloader unlock comparable to the limited Passport/Priv efforts. This track must not assume a boot path exists until it is demonstrated and documented.

## Step 2: Serial and Debug Access

Before attempting any firmware modification:

- Identify and document serial console or debug interfaces on Q20.
- Define a recovery procedure that uses serial or other low-level access to restore a working state after a failed boot experiment.
- Treat any experiment that could leave the device unbootable as unacceptable without a tested recovery path.

## Step 3: Kernel Strategy

In `kernel/`:

- Track mainline Linux support for MSM8960:
  - CPU, interrupt controller, timers.
  - GPIO, pinmux, clocks, regulators.
  - Display, touch, storage, USB, Wi‑Fi/BT, audio, sensors.
- Maintain a `patch-queue.md` for any out-of-tree patches required for Q20.
- Define a minimal kernel configuration that can:
  - Boot to a serial console.
  - Drive the display and basic input.
  - Access storage for rootfs.

Do not claim kernel success until you can boot to a usable console or framebuffer on real Q20 hardware with a known-good image.

## Step 4: Device Tree and Hardware Mapping

In `device-tree/`:

- Create a plan for the Q20 device tree (`q20.dts`):
  - Map SoC peripherals to board-level components.
  - Define nodes for display, touch, keyboard, trackpad, buttons, LEDs, sensors, audio, cameras, and power management.
- Use existing MSM8960 device trees as references, but treat Q20 as a unique board.
- Document unknowns and TODOs explicitly.

## Step 5: Initramfs and Rootfs

In `initramfs/` and `rootfs-overlay/`:

- Define a minimal initramfs that:
  - Mounts the root filesystem.
  - Starts a shell or simple init system.
  - Provides serial and/or display console.
- Plan a ChimeraOS rootfs that:
  - Includes your launcher and core services in a userspace that can eventually run on top of this kernel.
  - Uses a package set appropriate for an embedded ARM device.

This work can proceed in parallel on other hardware or in emulation, but it is not Q20-specific until tied to a verified boot path.

## Step 6: Hardware Inventory

In `hardware-inventory/`, document each subsystem:

- **Display:** Panel type, interface, resolution (720×²720), backlight control.
- **Input:** Keyboard matrix, trackpad, side buttons, power/volume keys.
- **Storage:** eMMC layout, partition scheme, filesystem types.
- **Power and battery:** PMIC, charging, fuel gauge, suspend/resume behavior.
- **Radios:** Cellular modem, Wi‑Fi, Bluetooth, GPS, NFC.
- **Sensors:** Accelerometer, gyroscope, magnetometer, ambient light, proximity.
- **Audio:** Codec, speakers, microphone, headset jack.
- **Cameras:** Front and rear sensors, interfaces.

For each, note:
- Known drivers (mainline, downstream, or proprietary).
- Reverse-engineering leads.
- Risks and unknowns.

## Step 7: Recovery and Rollback

Define a strict rule:

- No Q20-specific boot image is considered ready for flashing until:
  - A serial or equivalent recovery path is documented and tested.
  - A known-good stock autoloader restore procedure is verified after experiments.
  - The boot image has been proven to start on real hardware in a controlled test.

This track must never leave a device in an unrecoverable state by design.

## Relationship to Other Q20 Tracks

- **Full Launcher:** Independent, runs on stock BB10, no boot-chain changes.
- **BB10-Derivative OS:** Uses stock BB10 as the base; experiments are at the user-space or image-overlay level with rollback to stock.
- **Standalone OS:** Only this track modifies or bypasses the BB10 boot chain; it is explicitly long-term and research-only.

## Pipeline Integration

- Add a `build-q20-standalone-research` target that:
  - Collects research notes, device-tree drafts, kernel configs, and initramfs plans into a versioned artifact.
  - Does not produce any flashable firmware until explicit readiness criteria are met.
- Mark all standalone artifacts as research-only in CI metadata.

## Safety and Expectations

- This work carries a real risk of bricking devices if mishandled.
- Only perform experiments on devices you own and accept the risk for.
- Do not distribute boot images or exploits unless and until they are safe, documented, and reproducible.
- Focus on knowledge accumulation and incremental, reversible progress.

**Status:** Long-term research track; no guaranteed path to a bootable standalone OS on retail Q20 hardware at this time.
