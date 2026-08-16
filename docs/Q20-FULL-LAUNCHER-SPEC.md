# Q20 Full Launcher Specification (WebWorks / Cordova .bar)

This document defines the **Full Launcher** path for the BlackBerry Classic (Q20): a signed WebWorks/Cordova application that behaves as a full-screen, always-on custom home screen on top of stock BB10.

## Goals

- Deliver your UI (telemetry widgets, package vault, diagnostics, AI waifu launcher) as the primary user experience on Q20.
- Use official BB10 WebWorks/Cordova tooling and signing; no bootloader exploits required.
- Integrate with the existing ChimeraOS build pipeline and Q20 docs (`BUILD-Q20.md`, `BB10-Mac-Linux-Bootstrap.md`).

## Target Device

- **Device:** BlackBerry Classic (Q20)
- **OS:** BlackBerry 10 (latest official 10.3.x)
- **Form factor:** 720×�20 square display, physical keyboard, trackpad.

## Architecture Overview

- **Runtime:** WebWorks / Cordova for BB10 (HTML5 + JS in a native WebView).
- **Packaging:** `.bar` application signed with BlackBerry code signing keys.
- **Behavior:** Full-screen launcher-style app that auto-launches after boot and is the primary foreground experience.

## Repository Structure (ChimeraOS)

Extend your existing ChimeraOS repo with a launcher subproject, e.g.:

```
ChimeraOS/
  docs/
    BUILD-Q20.md
    BB10-Mac-Linux-Bootstrap.md
    Q20-FULL-LAUNCHER-SPEC.md
  q20-launcher/
    config.xml
    bar-descriptor.xml
    www/
      index.html
      css/
      js/
        app.js
        launcher.js
        telemetry.js
        package-vault.js
        diagnostics.js
    hooks/
      before_build/
      after_build/
      before_run/
      after_run/
    res/
      icon.png
      splash.png
```

## Step 1: Environment Setup

Follow your existing `BB10-Mac-Linux-Bootstrap.md` for:

- Installing Node.js, a Cordova CLI compatible with the legacy BB10 platform, the BB10 WebWorks SDK, and BB10 command-line tools.
- Configuring BB10 signing keys and a Q20 device target.

Example:

```bash
npm install -g cordova@4.2.0
cordova create q20-launcher com.chimeraos.q20launcher ChimeraLauncher
cd q20-launcher
cordova platform add blackberry10
```

## Step 2: Core Configuration

### `config.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<widget xmlns="http://www.w3.org/ns/widgets"
        xmlns:rim="http://www.blackberry.com/ns/widgets"
        id="com.chimeraos.q20launcher"
        version="1.0.0">
  <name>Chimera Launcher</name>
  <description>ChimeraOS Full Launcher for BlackBerry Classic (Q20)</description>
  <author>ChimeraOS</author>
  <content src="index.html" />
  <preference name="Orientation" value="portrait" />
  <preference name="Fullscreen" value="true" />
  <preference name="BackgroundColor" value="0x000000" />
  <feature id="blackberry.app" required="true" version="1.0.0.0" />
  <feature id="blackberry.system" required="true" version="1.0.0.0" />
  <access uri="*" subdomains="true" />
</widget>
```

### `bar-descriptor.xml`

Let the Cordova/BB10 packager generate the descriptor initially, then maintain only validated settings. Never assume an unverified descriptor property grants system-home privileges.

## Step 3: UI / Launcher Logic

Implement the UI in `www/`:

- `app.js`: bootstrap, routing, state.
- `launcher.js`: app grid, search, gesture model, active-frame-like UI.
- `telemetry.js`: battery, network, storage, and app-level health widgets using permitted APIs.
- `package-vault.js`: local catalogue and user-mediated install/update instructions.
- `diagnostics.js`: safe device info, local logs, and health checks.

Avoid representing system-wide telemetry or package installation as available unless a confirmed BB10 API/plugin and permission is present.

## Step 4: Cordova Hooks

Use `hooks/` to inject version metadata, create checksums/SBOM inputs, collect output `.bar` artifacts, and optionally deploy to a development-mode Q20.

Example `hooks/after_build/010-package-bar.js`:

```js
#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const buildDir = path.join(__dirname, '..', '..', 'platforms', 'blackberry10', 'build', 'device');
const outDir = path.join(__dirname, '..', '..', '..', 'build', 'q20-launcher');
if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
const bars = fs.readdirSync(buildDir).filter(name => name.endsWith('.bar'));
if (!bars.length) throw new Error(`No .bar found in ${buildDir}`);
for (const name of bars) fs.copyFileSync(path.join(buildDir, name), path.join(outDir, name));
```

## Step 5: Signing and Release Build

Use the signing tooling and key-registration procedure documented by the installed BB10 SDK. Do not place passwords, tokens, CSK, PBDT, or TSK material in this repository.

```bash
cordova build --release blackberry10
blackberry-deploy -installApp -device <Q20_IP> -password <DEVICE_PASSWORD> <SIGNED_BAR_PATH>
```

## Step 6: Full-Launcher Behavior

Stock BB10 does not expose an Android-style third-party default-home replacement mechanism. Treat Chimera Launcher as a full-screen primary application that can be manually launched, launched under supported enterprise/kiosk controls when available, and resumed by the user. It must degrade gracefully when the stock home, lock screen, or system UI takes focus.

## Pipeline Integration

Add a `build-q20-launcher` target that builds the `.bar`, creates hashes/SBOM metadata, and stages artifacts for the existing ChimeraOS CI workflow. The launcher should be versioned independently from JavaBoyChimera while exposing it as a first-class item in the launcher vault.

## Future Work

- Integrate JavaBoyChimera as a launcher entry point and package metadata source.
- Add AngieAI local/remote companion panels compatible with BB10 constraints.
- Add a user-mediated update channel with integrity verification.
- Add device-specific input tuning for the keyboard and trackpad.

**Status:** Achievable on stock Q20 as an application-shell experience; not a true replacement for BB10 system home without separate privileged platform support.
