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

## Where things are logged

Local orchestration/deploy actions are logged to:

```
~/.angieai/logs/deploy-YYYYMMDD-HHMMSS.log
```

Check the latest log first when something silently failed during `setup.sh`.
