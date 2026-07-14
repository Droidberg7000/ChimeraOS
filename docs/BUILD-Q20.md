# BB10 Bridge Console — Q20 Build and Install Guide

This package is prepared for a BlackBerry Classic / Q20 as a WebWorks app source set.

## Package identity
- App name: BB10 Bridge Console
- Package ID: com.user.bb10bridgeconsole
- Version: 1.0.0.1
- Main entry: index.html
- Icon: assets/icon-86.png

## Included assets
- icons: 86, 114, 128 px
- splash: 1280x768
- config.xml with internet permission

## Prepare the source zip
From inside the folder that contains `config.xml` and `index.html`, create a zip of the app contents, not the parent directory.

**This source now exists and is pre-built**: see `../apps/bb10-bridge-console/`
for the real `config.xml`, `index.html`, `style.css`, `app.js`, and `assets/`
(icons + splash regenerated from the ChimeraOS skull-berry logo), plus a
ready-to-package `bb10-bridge-console-q20-source.zip` with contents flattened
at the zip root exactly as `bbwp` expects. If you change the app, re-zip with:

```bash
cd ../apps/bb10-bridge-console
zip -r bb10-bridge-console-q20-source.zip config.xml index.html style.css app.js assets/
```

## Build with BlackBerry WebWorks Packager
Use the BB10 WebWorks Packager to create the BAR file.

Typical command:
`./bbwp bb10-bridge-console-q20-source.zip -o build-output`

The packager creates a BAR package in `build-output` when the toolchain is set up correctly.

## Debug / dev install to your Q20
Requirements:
- Q20 in Development Mode
- device IP address known
- development mode password known
- debug token installed if your workflow requires it

Typical commands:
`blackberry-deploy -installDebugToken debugtoken.bar -device <Q20-IP> -password <DEV-PASSWORD>`

`blackberry-deploy -installApp -package build-output/<APPNAME>.bar -device <Q20-IP> -password <DEV-PASSWORD>`

## Signing for broader installability
For a release-style BAR installable beyond debug workflow, sign the package with BlackBerry signing credentials before deployment.

## Suggested values to replace
- `<Q20-IP>` -> your BlackBerry Classic IP in Development Mode
- `<DEV-PASSWORD>` -> your Development Mode password
- `<APPNAME>.bar` -> generated BAR filename

## Device-specific note
The UI is tuned for the Classic/Q20 square display and large touch targets, which matches BlackBerry’s Classic-focused development guidance.
