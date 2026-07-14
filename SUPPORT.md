# Support / Troubleshooting

## Setup issues (`setup.sh`)

| Symptom | Likely cause | Fix |
|---|---|---|
| `pkg: command not found` | Not actually running inside Termux | Run on-device in Termux, not a regular Linux shell |
| `proot-distro: command not found` | Package not installed yet | `pkg install proot-distro` then re-run `setup.sh` |
| Homebrew missing on macOS | Homebrew never installed | Install from https://brew.sh, then re-run `setup.sh` |
| `sudo: command not found` on Linux install step | Minimal/rootless container | Run the `apt-get`/`dnf`/`pacman` line as root, drop `sudo` |

## Service issues (`docker-compose`)

| Symptom | Likely cause | Fix |
|---|---|---|
| `angieai-onnx` container exits immediately | Missing `model.onnx` | Copy a real exported model into `services/angieai-onnx/` before `docker build`, or treat the lane as "unavailable, fall back to OpenRouter" per `AI_TO_AI_PROTOCOL.md` |
| `/predict` returns 400 | Input shape mismatch | Confirm the input array shape matches what your `model.onnx` was exported with |
| `angieai-reasoner` always returns `default` | Text didn't match any keyword rule | Extend the `if/elif` chain in `services/angieai-reasoner/app/main.py`, or upgrade to an Experta ruleset (see that service's README) |

## CI / GitHub Actions issues

| Symptom | Likely cause | Fix |
|---|---|---|
| `test -n "$OPENROUTER_API_KEY"` fails in CI | Secret not created, or workflow not on `main`/PR from the same repo | Settings → Secrets and variables → Actions → New repository secret → `OPENROUTER_API_KEY` |
| Different key needed for prod vs dev | Single repo secret used everywhere | Create a GitHub **Environment** (e.g. `production`), add the secret there, set `environment: production` on the job |
| `dmux-ci.yml` can't find `package.json` | dmux lives in a different repo/folder than expected | Point the workflow at the correct working directory, or move dmux config to repo root |

## angieai-pentest / recon issues

| Symptom | Likely cause | Fix |
|---|---|---|
| `403 Set authorized=true...` | Request omitted the `authorized` flag | Add `"authorized": true` to `/scan/hosts` or `/scan/ports` — there is no way around this, by design |
| `400 ... is not a private/loopback/link-local address` | Target is a public IP | This service refuses public targets unconditionally, even with `authorized: true`. Point it at your own LAN/loopback instead |
| `POST /analyze/ports` or `POST /recon/wifi` returns `422` | Payload shape doesn't match the model | `/analyze/ports` wants `{"host": ..., "open_ports": [{"port": N, ...}]}`; `/recon/wifi` wants `{"networks": [{"ssid": ..., "bssid": ..., "capabilities": ...}]}` |
| Full 1-65535 port scan takes minutes | Default timeout is too generous for a huge range across a 64-worker pool | Pass a lower `timeout_ms` (e.g. `10`–`50`) in the request body — a full range scan with `timeout_ms: 10` finishes in well under a minute against a live host |
| `/analyze/ports` or `/recon/wifi` returns no findings | Nothing matched the heuristic rules | Expected — both are pattern-matchers over a small known-bad list (`services/angieai-pentest/app/signatures.py`), not real vulnerability scanners. No findings is not proof of safety |

## Termux native stack-up issues (`scripts/termux_stack_up.sh`)

| Symptom | Likely cause | Fix |
|---|---|---|
| `uvicorn: command not found` / import errors in the log | `pip install` step failed silently (e.g. `onnxruntime` has no prebuilt wheel for your Android ABI) | Check `~/.angieai/logs/<service>.log`; `angieai-reasoner`/`angieai-pentest` have no heavy deps and should always come up, `angieai-onnx` is the one most likely to fail on-device |
| Script says a service is already running but it isn't answering | Stale PID file from a crashed process reusing a PID | `scripts/termux_stack_down.sh` then re-run `termux_stack_up.sh`; if it still misbehaves, `rm ~/.angieai/pids/*.pid` and retry |
| Port already in use | A previous run wasn't stopped cleanly, or something else is bound to 8000/8001/8002 | `scripts/termux_stack_down.sh` first, or `pkill -f uvicorn` as a last resort |

## Wi-Fi recon issues (`scripts/wifi_recon_termux.sh`)

| Symptom | Likely cause | Fix |
|---|---|---|
| `termux-wifi-scaninfo not found` | Termux:API app/package missing | Install the Termux:API app (F-Droid/Play) **and** run `pkg install termux-api` inside Termux |
| `termux-wifi-scaninfo` returns an empty list | Location permission not granted | Android requires location permission for Wi-Fi scan results — grant it to Termux:API in system settings |
| Script can't reach `angieai-pentest` | Stack not up yet, or wrong host/port | Run `scripts/termux_stack_up.sh` first; pass a custom host/port as args if not using the defaults (`localhost 8002`) |
| Looking for BLE scanning | Not supported | Termux:API has no direct BLE scan capability, and this project doesn't implement active Wi-Fi/BLE attack tooling regardless — see `ETHICS.md`. Wi-Fi recon here is Wi-Fi (802.11) beacon analysis only |

## Device build issues (BB10 / Android)

See `docs/BUILD-Q20.md` and `docs/BB10-Mac-Linux-Bootstrap.md` for the full
troubleshooting tables on `bbwp` failures, BAR-won't-launch issues, and
`blackberry-deploy` install failures.

## AI-to-AI protocol issues

If a sub-agent (Google AI Studio, a dmux pane, an OpenRouter model) returns
something that violates `AI_TO_AI_PROTOCOL.md` — e.g. a pipe-to-shell
one-liner, an identity/alias drift, or an auto-merge — treat that output as
a draft only. AngieAI (and you) validate and rewrite before it touches a
real device or `main`.

## Device / APK compatibility issues (sideloading on BB10 or legacy BBOS)

| Symptom | Likely cause | Fix |
|---|---|---|
| APK install fails with error `-4`, `-12`, `-25`, `-102`, `-103`, or `-104` on BB10 | Signature/format/permission mismatch | Look up the exact code in `docs/BB10_APK_Compatibility_Repository.pdf` (troubleshooting checklist + error code reference) before retrying a different build |
| Not sure which sideloading method to use | 4 methods exist (Direct APK, DBBT via PC, Chrome Extension/PlayBook App Manager, BAR File Conversion) | See the sideloading-methods section of `docs/BB10_APK_Compatibility_Repository.pdf` |
| Not sure if an app is even compatible with BB OS 10.3.x / API 18 | Only a subset of ported Android APKs work (Dalvik, 2-core cap, no GMS, `armeabi-v7a` preferred) | Check the per-category compatibility tables (Browsers, Offline Media, Utility, Social) in `docs/BB10_APK_Compatibility_Repository.pdf` — note WhatsApp/LinkedIn/Messenger are flagged NOT COMPATIBLE |
| HTTPS/TLS requests fail on-device (BB10 or legacy BBOS 9900/Pearl 8130) | Old root CA store / deprecated TLS stack | Follow the decision chart in `docs/blackberry-devices-tls-workaround-pack.md` (BerryCore/Term49+Termux for BB10; BBSSH/Opera Mini/AppLoader for legacy BBOS) by use case (SSH, browsing, downloads) |
| Unsure where to get a legitimate Termux APK, legacy BBOS ALX/COD/JAD/JAR, or a BB10 BAR/APK build | Forum mirrors are low-trust | Use the source list + 4-point download policy in `docs/blackberry-package-source-index.md` (official sources first, record SHA-256, keep signing-source consistency) |

## ChimeraOS drive sync issues

| Symptom | Likely cause | Fix |
|---|---|---|
| `sync_to_chimeraos_drive.sh` says it can't find the drive | Drive mounted somewhere non-standard, or volume name isn't exactly `ChimeraOS` | Pass the mount path explicitly: `./scripts/sync_to_chimeraos_drive.sh /path/to/mount` |
| `Sync-ToChimeraOSDrive.ps1` errors that it can't find the volume | Windows assigned a drive letter but the label doesn't match, or `Get-Volume` needs admin rights on some systems | Re-run with the drive letter directly: `.\scripts\Sync-ToChimeraOSDrive.ps1 -DriveLetter E:` |
| robocopy exits non-zero | robocopy's own exit codes 0-7 all mean "success with some changes"; 8+ is a real error | Only treat exit codes ≥ 8 as failures (the script already does this) — re-run if you see a real error code |
| `bg-spongebob-voodoo` option doesn't change anything in the BB10 Bridge Console | Old cached `index.html`/`style.css`/`app.js` on-device | Reinstall/redeploy the app source in `apps/bb10-bridge-console/`, or hard-refresh if testing in a desktop browser |

## Where things are logged

Local orchestration/deploy actions are logged to:

```
~/.angieai/logs/deploy-YYYYMMDD-HHMMSS.log
```

Check the latest log first when something silently failed during `setup.sh`.
