# ChimeraOS Q20 Launcher

Application-shell prototype for stock BB10, not replacement firmware or a privileged Home launcher.

## Preview and static checks

Requires Python 3. From the repository root:

```sh
python3 q20-launcher/tools/check_source.py
python3 -m http.server 8080 --bind 127.0.0.1 --directory q20-launcher/www
```

Open http://127.0.0.1:8080 in a desktop browser. Stop the server with Ctrl-C.
Alternatively, from q20-launcher, run `npm run check` or `npm run preview`.
No npm dependencies are needed for this static preview. These checks do not test JavaScript execution or a phone.

## Existing scope

Home tiles, a package guidance catalogue, and application/browser diagnostics.
Some tiles are explicitly placeholders, not working external integrations.
Diagnostics export displays selectable JSON for manual copy; it does not claim a file was saved.
No notes, cloud VM, AI conversation, flashing, system task manager, or automatic installation is implemented by this repair.

## Device build: separately provisioned legacy toolchain

You must supply a compatible Cordova CLI, BB10 platform and SDK, plus any required valid signing/debug credentials.
No verified version combination is pinned here yet. Do not install arbitrary latest Cordova and assume BB10 support.
The presence of source code or a ZIP does not establish present-day signing/deployment availability.

The build wrapper expects a configured `q20-launcher/platforms/blackberry10` project.
After verifying and provisioning that environment:

```sh
bash scripts/build-q20-launcher.sh
# Optional release build with signing configured locally:
bash scripts/build-q20-launcher.sh --release
```

The wrapper requires exactly one newly written BAR and checks archive integrity plus manifest presence.
It copies to `build/q20-launcher/` and records SHA-256/build mode. It does NOT verify signatures or installability.
Zero or multiple newly written BARs fail closed for manual inspection.

## Explicit installation

```sh
bash scripts/deploy-q20-launcher.sh --device-ip YOUR_DEVICE_IP --bar /path/to/exact-app.bar
```

The wrapper confirms target/artifact and prompts for the password without echo.
Do not pass credentials in the command, commit keys, or paste passwords into chat.
The legacy deploy tool still receives the password as a process argument: other sufficiently privileged local processes may inspect it.
Use a trusted host. No firmware, reset, recovery, or raw partition operations are performed.

## Manual acceptance checklist

- Preview loads with no missing asset requests or uncaught JavaScript errors.
- Home, Vault, Diagnostics, and About navigation work.
- Focus remains visible with Tab/Shift-Tab and activation works with Enter.
- Diagnostics Refresh works; Export presents selectable JSON.
- Narrow and square layouts remain readable.
- Native build, signing, installation, physical keyboard/trackpad, and resume behavior must be checked separately on Q20.

Never treat the browser preview or static check as proof of a working device package.
