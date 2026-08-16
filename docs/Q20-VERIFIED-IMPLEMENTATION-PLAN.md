# Verified Q20 BB10 Implementation Plan

## Purpose

This plan defines the practical, installable ChimeraOS path for the BlackBerry Classic Q20 on stock BB10. It separates verified application-level work from unverified privileged-system research.

## Product Definition

**ChimeraOS Q20** is a signed BB10 WebWorks/Cordova `.bar` that provides a full-screen launcher-style environment: home surface, local app catalogue, diagnostics, themes, keyboard/trackpad-aware navigation, and optional web-hub access.

It is not a QNX kernel replacement, a bootloader replacement, a root framework, or a guaranteed replacement for BB10 Home/lock screen.

## Verified Scope

- Package and sign a WebWorks/Cordova `.bar` for BB10.
- Render a Q20-optimized UI for 720x720 display.
- Use HTML, CSS, and JavaScript for app-local active-frame-style views, notifications, settings, themes, diagnostics, and module state.
- Handle keyboard and pointer/touch events while ChimeraOS is in the foreground.
- Use only WebWorks APIs/plugins that are present on the target SDK and granted by the package descriptor.
- Keep configuration and module state in app-local storage.
- Build, sideload, uninstall, and restore user-space functionality safely.

## Explicitly Unverified / Out of Scope

- Setting a third-party app as the actual BB10 system home.
- Starting arbitrary apps automatically at boot without a verified supported mechanism.
- Remapping BB10 system keyboard behavior globally.
- Controlling hardware LED drivers through undocumented APIs.
- Writing BB10 system partitions, patching images, or modifying boot components.
- Root, QNX privilege escalation, process injection, boot exploits, or autoloader modification.

## Staged Delivery

### Stage A: Installable launcher

1. Create/maintain `q20-launcher/` as a valid Cordova/WebWorks project.
2. Configure descriptor, permissions, icon, and splash assets using installed BB10 tooling.
3. Build a debug `.bar` and deploy to a development-mode Q20.
4. Validate launch, navigation, storage, suspend/resume, and uninstall.
5. Build a signed release `.bar` only after device validation.

### Stage B: Q20 UX

- Tune layout for 720x720.
- Implement keyboard navigation inside the application.
- Add touch/trackpad-compatible pointer and gesture behavior inside the application.
- Implement local themes, tile layout, and diagnostics through the safe module scaffold.

### Stage C: Optional supported integration

For every desired BB10 function, first record:

- Exact API/plugin name and SDK version.
- Required descriptor permission.
- Hardware/OS versions tested.
- Failure behavior and fallback.

Only then add the capability behind `bb10-capabilities.js` and a UI feature flag.

### Stage D: Overlay research gate

Do not begin any firmware or image-overlay research until all are true:

- Exact Q20 model/variant is recorded.
- A stock, matching autoloader is archived and hash-verified.
- A complete restore is practiced successfully on the same device.
- A user backup is current.
- A documented rollback procedure is reviewed before each test.

## Acceptance Criteria

A usable first release must:

- Install as a signed `.bar` on the Q20.
- Remain usable entirely on stock BB10.
- Render correctly at 720x720.
- Support launcher navigation with touch/trackpad and in-app keyboard events.
- Persist local theme/layout settings.
- Export an app-level diagnostic report.
- Degrade safely when optional BB10 APIs are absent.
- Be removable without affecting stock BB10 behavior.
