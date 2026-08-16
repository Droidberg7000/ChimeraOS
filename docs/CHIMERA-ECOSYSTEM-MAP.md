# Chimera Ecosystem Map

## Purpose

This document maps the first-party Chimera projects and defines the boundary for Q20/BB10 work. It is a coordination guide, not a claim that software or firmware is interchangeable across platforms.

## Project Roles

| Repository | Role | Relationship to Q20 work |
| --- | --- | --- |
| `Droidberg7000/ChimeraOS` | Q20 BB10 delivery workspace | Primary repository for Q20-targeted documentation, implementation planning, test gates, recovery guidance, and device-specific integration work. |
| `agentb113-jpg/ChimeraOS` | Web hub | Publishes discovery, documentation, downloads, and links to supported Chimera projects. It does not replace the Q20 delivery workspace. |
| `chimera-launcher` | Launcher and UI project | Owns launcher concepts, navigation, and UI-facing components that may be documented or adapted for Q20 only after compatibility is verified. |
| `ChimeraCarPal` | Vehicle companion project | Owns vehicle-companion workflows. Q20 integration must remain optional, local, permission-aware, and separated from safety-critical vehicle functions. |
| `JavaBoyChimera` | Emulator sub-project | Owns emulation-focused work. Treat it as an independent component with its own compatibility and distribution constraints. |

## Q20 Boundary

The Q20 target is a BlackBerry 10 device. Any repository integration must preserve that reality:

- Record local metadata, documentation, and explicit user-opened links safely.
- Verify runtime, packaging, signing, permissions, device APIs, and recovery paths before describing an integration as supported.
- Keep experimental work opt-in and reversible.
- Do not imply Android APK compatibility, root access, jailbreak capability, bootloader control, firmware flashing, or native BB10 support unless it has been independently verified for the exact device and software version.
- Do not treat web, launcher, vehicle, or emulator projects as automatic substitutes for a BB10-native implementation.

## Integration Model

1. The web hub may link to Q20 documentation and clearly label the Q20 support status.
2. The launcher project may contribute design and workflow requirements, subject to Q20 compatibility validation.
3. CarPal-related links or metadata must be user initiated and must not control, diagnose, or alter vehicle systems.
4. JavaBoyChimera may be referenced as a distinct optional project; it must not be bundled or advertised as Q20-ready without test evidence.
5. `Droidberg7000/ChimeraOS` is the source of truth for Q20-specific acceptance criteria, tests, rollback instructions, and release decisions.

## Evidence Before Promotion

Before a cross-project feature is promoted from planning to supported status, record:

- The exact repository, revision, and artifact examined.
- The Q20/BB10 device and operating-system version tested.
- Installation, launch, permission, and rollback results.
- Known limitations, privacy implications, and user-visible failure behavior.
- A maintainer decision that distinguishes verified support from research or an external link.

## Maintenance

Update this map whenever a repository changes ownership, scope, integration status, or the evidence required for Q20 support. Keep project boundaries explicit so users can distinguish documentation, optional links, experiments, and verified device behavior.
