# Q20 AI Studio Prompt Pack

Use these prompts with an AI assistant to generate Q20 launcher code, module configs, and test plans. All prompts assume app-level, safe WebWorks/Cordova scope.

## Prompt 1: Generate Q20 launcher shell

"Generate a BB10 WebWorks/Cordova launcher shell for the BlackBerry Classic Q20 (720x720). Requirements:
- Single-page app with Home, Vault, Diagnostics, and About panes.
- Keyboard navigation (arrow keys, Enter, Escape) and click/tap navigation.
- Local storage for theme and layout settings.
- Capability detection for optional BB10 APIs with safe degradation.
- No system partition writes, no root, no boot modification.
Provide: index.html, launcher.js, input-controller.js, bb10-capabilities.js, and a brief README with build/deploy steps."

## Prompt 2: Create app-level theme module

"Create an app-level ChimeraOS theme module for the Q20 launcher. Requirements:
- module.json with id, name, version, scope='app-ui-only', author, homepage.
- theme.json with colors (background, surface, text, muted, accent), spacing, typography, and icon references.
- Module manager that installs, activates, and uninstalls themes using browser storage only.
- No OS writes, no system theme changes, no lock screen or status bar modification.
Provide: module.json, theme.json, module-manager.js, and usage notes."

## Prompt 3: Q20 test and recovery plan

"Write a test and recovery plan for Q20 BB10 launcher experiments. Requirements:
- Prerequisites: exact Q20 variant, stock autoloader hash-verified, user backup, rollback procedure.
- Test matrix: T1 stock restore, T2 app lifecycle, T3 capability degradation, T4 module safety.
- Exit criteria: all tests pass, rollback practiced, independent reviewer confirms.
- Safety notes: no untested images, serial/JTAG recovery if available, partition backups.
Provide: a checklist suitable for GitHub docs."

## Prompt 4: BB10 capability facade

"Generate a capability-detection facade for BB10 WebWorks. Requirements:
- Detect blackberry.app, blackberry.system, Notifications, Filesystem APIs.
- Expose has(feature), report(), and degradeIfMissing(feature, fallback).
- Safe defaults when APIs are absent.
Provide: bb10-capabilities.js and brief usage examples."

## Prompt 5: Q20 input controller

"Generate an input controller for Q20 launcher navigation. Requirements:
- Map ArrowUp/Down/Left/Right, Enter, Space, Escape to navigation actions.
- Emit tap action on click/touch.
- Provide addNavHandler(fn) and start/stop functions.
- No system key remapping; in-app only.
Provide: input-controller.js and a short integration guide."

## Prompt 6: Module system scaffold

"Create a safe module system scaffold for the Q20 launcher. Requirements:
- Install, uninstall, activate, getActive, getInstalled using localStorage.
- Validate module metadata (id, name, version, scope='app-ui-only').
- No OS writes, no root, no boot or system partition access.
Provide: module-manager.js, example module.json/theme.json, and README."

## Prompt 7: Q20 deployment checklist

"Write a deployment checklist for a signed BB10 `.bar` launcher on Q20. Requirements:
- Cordova/WebWorks project setup, descriptor configuration, icon/splash assets.
- Debug build, sideload to development-mode device, validation steps.
- Release build, signing, deployment, and uninstall verification.
- Recovery gate: stock autoloader backup and restore test before any overlay work.
Provide: a step-by-step checklist suitable for CI or manual use."
