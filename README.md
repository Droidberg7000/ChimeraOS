```
                         ╔══════════════════════════════════════╗
                         ║          CHIMERAOS // DAY 0          ║
                         ║    ANGIEAI = DELTA-4 = LINCE-Z        ║
                         ║   LYNX LINUX - MEDUZA - ARCHIVE Ω     ║
                         ╚══════════════════════════════════════╝
                                      /\
                                     /  \
                                    / /\ \
                                   /_/  \_\
                                 ( o  o )
                             /  \   \  --  /  /  \
                            /_\/\/\/_\
                                  CHIMERA WATCHES
                               HEART: ARCHIVE OMEGA
                               BRAIN: TEXT CPU
                               NERVE: AI-TO-AI
                               CORE: ONE ORGANISM

                               \    rising wings    /
                                \          /
                                   \/  \_/  \/
                                .-.\      /.-.
                             _.-'      -..-      '-._
                            /   Hummingbird AngieAI   \
                           /    becomes the watcher     \
                          /\
```

# ChimeraOS

ChimeraOS (Project Chimera) is the umbrella identity for a personal, local-first
AI companion and device-hacking toolkit spanning Termux/Android, Linux, macOS,
and legacy BlackBerry 10 hardware (Q20 / 9900). Everything in this repo is
designed to run on free-tier or sign-up-only services — no paid subscriptions
required.

## Mission

ChimeraOS's real-world target is an **ultra cyberdeck / mobile penetration-testing
and diagnostics rig**, with the BlackBerry Classic (Q20) as the primary end
device. AngieAI is the on-device AI orchestrator for that rig, not a standalone
chat companion — it's meant to sit alongside pentest/recon workflows (network
probing, connectivity diagnostics, SSH/Termux bridging into the device, log
analysis) and reason about what tool or lane a task needs. `apps/bb10-bridge-console`
is the first concrete piece of that: a bridge console the Q20 uses to talk to
a Termux-hosted AngieAI/services stack over the LAN. Treat every future
feature (BB10 or Android) through this lens — tester/cyberdeck first,
companion-app polish second — while preserving the identity/lore rules in
`AI_TO_AI_PROTOCOL.md` §7 (aliases, hummingbird symbol, Day 0/Archive Ω
continuity).

## Identity / aliases

ChimeraOS is one organism known by several names depending on context:

| Alias | Role |
|---|---|
| **AngieAI** | The local AI — always-on companion, orchestrates every other agent |
| **Delta-4** | AI-to-AI protocol / private codebase codename |
| **Lince-Z** | Lynx + MeduZa fusion identity |
| **Lynx Linux** | Linux-side persona/runtime |
| **MeduZa** | Distributed/multi-agent persona |
| **Berry-Chan / Bberry / BerryZ** | BlackBerry-device-side persona |
| **Archive Ω (Omega)** | Persistent "Day 0" memory / core essence store |
| **La Jefa** | AngieAI's "boss" honorific — same identity, command-authority framing |
| **Angelica (Comms)** | Communications-manager persona/contact node — secure-messaging role in the AngieAI Mobile UI (BBM-style "SECURE PROXY ENCRYPTED" framing) |
| **Don Chunguslini** | The user's own speaker-avatar/persona in-universe, styled after Big Chungus/Bugs Bunny |

Symbol: AngieAI is represented by a **hummingbird** (`assets/ChimeraOS-hummingbird-companion-logo.png`).
Visual style target: retro N64/SNES cartridge look, not limited to black-and-white ASCII
(see `assets/` for splash/emblem art — also includes `Blackberry-trail-berry-Chimera-emblem.png`,
`Skull-berry-chimera-logo.png`, and `Green-skull-apple-Chimera-boot-logo.png`).

Origin canon: Watsonville, CA / Bay Area — "Poorside" / "Barrio Pobre" (BPS), PSC-13, and the
619-adjacent "Poorside" references are part of the backstory canon and should be preserved,
not rewritten or over-explained beyond what's already been said.

### External prototype surface

Alongside this repo, the user has an active build surface in **Google AI Studio** — a
remixed BB10/Q20 simulator app referred to as **"ChimeraOS Dragon Gateway"** (URL fragment
seen: `...ix-remix-blackberry-cl-1434.ai.studio`, i.e. an iteratively-remixed AI Studio app).
It renders a simulated Classic Q20 device shell ("CHIMERA RETRO DECK") with an AngieAI Mobile
messaging UI and the Angelica (Comms) persona. Treat this as a separate, parallel prototype
surface from this FastAPI/WebWorks repo — no code has been extracted from it into this repo
yet. If you want it merged in (e.g. matching the BB10 Bridge Console's look to the Dragon
Gateway UI, or porting any logic from it), point at the current AI Studio URL and it can be
pulled in as its own lane, per the AI-to-AI protocol's Google AI Studio role.

### Final build storage

The canonical, off-device home for the compiled final build (repo contents, exported
models, packaged BAR/APKs, and any offline archives) is a dedicated **SanDisk 500GB
external drive named `ChimeraOS`** (may show up at the OS/volume level under an
internal label such as `prchl_z.ai` depending on how it was formatted/mounted).
Treat this drive as the final-edition compilation target, not a working repo clone —
copy verified, tagged builds onto it rather than developing directly on it. This repo
and its GitHub remote remain the source of truth; the drive is the durable offline copy.

Two helper scripts mirror this repo onto the drive whenever it's plugged in
(incremental sync, not a blind re-copy each time):

- **macOS / Linux:** `./scripts/sync_to_chimeraos_drive.sh` — auto-detects the
  drive under `/Volumes/ChimeraOS`, `/media/$USER/ChimeraOS`,
  `/run/media/$USER/ChimeraOS`, or `/mnt/ChimeraOS`; or pass an explicit mount
  path as the first argument.
- **Windows:** `.\scripts\Sync-ToChimeraOSDrive.ps1` — auto-detects the drive by
  volume label `ChimeraOS`; or pass `-DriveLetter E:` explicitly.

Both write a `.last_synced_utc` timestamp file at the destination root so you
can see at a glance when the drive was last refreshed.

## Architecture

```
                    ┌─────────────────────────┐
                    │   Google AI Studio        │
                    │   (remote build agent —   │
                    │    APK / BAR generation)   │
                    └───────────▲───────────────┘
                                │  AI-to-AI protocol (see AI_TO_AI_PROTOCOL.md)
                    ┌───────────┴───────────────┐
                    │        AngieAI             │
                    │  (local orchestrator /      │
                    │   "text CPU" reasoning,      │
                    │   angieai-reasoner :8001)    │
                    └──┬───────┬───────┬─────────┘
                       │       │       │
                 ┌─────▼──┐ ┌──▼───┐ ┌─▼──────────┐
                 │  dmux  │ │Termux│ │ OpenRouter  │
                 │ (tmux +│ │(proot│ │ (model pool │
                 │worktree│ │distro│ │  for agent  │
                 │ agents)│ │+ pkgs│ │  fallback)  │
                 └────────┘ └──────┘ └────────────┘
```

angieai-reasoner routes each incoming request to one of two local
inference/action lanes, both reachable from the BB10 Bridge Console client:

```
           BB10 Bridge Console (Q20 WebWorks app, or any REST client)
                              │  HTTP
                              ▼
                 angieai-reasoner  :8001  (routing / "text CPU")
                    │                          │
                    ▼                          ▼
           angieai-onnx  :8000          angieai-pentest  :8002
           FastAPI + ONNX Runtime       authorized-use-only recon lane
           local model inference        /scan/hosts, /scan/ports,
                                         /analyze/ports, /recon/wifi
```

Both deploy the same way at the container level, but there are two supported
run lanes depending on hardware:

- **Docker Compose lane** (Linux/macOS dev machine): `docker compose up
  --build` brings up all three services on a shared `angieai-net` bridge
  network — see "Bring up the local AI services" below.
- **Termux-native lane** (on-device, Android/Q20-adjacent, no Docker
  daemon available): `scripts/termux_stack_up.sh` starts the same three
  FastAPI apps directly under Termux's own Python via background `uvicorn`
  processes, with PIDs tracked under `~/.angieai/pids/` and logs under
  `~/.angieai/logs/`. `scripts/termux_stack_down.sh` reverses it.
- Either lane, the BB10 Bridge Console (or `curl`, or `wifi_recon_termux.sh`)
  talks to the same `:8000/:8001/:8002` HTTP surface — the client doesn't
  need to know which lane is running underneath.

- **AngieAI** is the always-local reasoning layer ("text CPU"). It never hands off
  core reasoning to a remote shell — it only ever runs pre-fetched, verified
  installer/setup scripts (download-then-run, never blind pipe-to-shell).
- **angieai-reasoner** is AngieAI's deterministic routing microservice — decides
  which lane (local, build, dev-workflow, inference, fallback) a request goes to.
- **angieai-onnx** is AngieAI's local model-inference lane (FastAPI + ONNX Runtime),
  with an optional TorchServe path for managed multi-model serving.
- **angieai-pentest** is the authorized-use-only recon/diagnostics lane for the
  cyberdeck mission: host sweeps, full-range port scans + banner grabs on your
  own private network only, a local heuristic vuln-signature matcher
  (`/analyze/ports`), and passive Wi-Fi beacon analysis (`/recon/wifi`) — see
  `ETHICS.md` and `services/angieai-pentest/README.md`.
- **Google AI Studio** is treated as the remote build agent for anything that needs
  Android/BAR packaging horsepower (see `GOOGLE_AI_STUDIO_PROMPT.md`).
- **dmux** manages parallel sub-agents (Claude Code / Codex / OpenCode-style) across
  git worktrees + tmux panes, one branch/task per pane (see `scripts/chimeraos_workflow_bundle.sh`).
- **OpenRouter** (via `OPENROUTER_API_KEY`, one secret shared by dmux and AngieAI) is
  the model pool used when a free/sign-up-only LLM is needed instead of a paid one.
- **Termux** is the on-device runtime for Android/BlackBerry-adjacent hardware —
  bootstraps a `proot-distro` (Alpine) sandbox with `curl`, `zsh`, `tmux`.

## Repo contents

```
ChimeraOS-final-build/
├── README.md                        ← this file
├── LICENSE                          ← Apache 2.0
├── SUPPORT.md                       ← troubleshooting tables (setup, services, CI, device builds)
├── AI_TO_AI_PROTOCOL.md             ← rules for how AngieAI talks to other agents
├── GOOGLE_AI_STUDIO_PROMPT.md       ← ready-to-paste prompt for the BB10/Android build
├── setup.sh                         ← Termux/Linux/macOS bootstrap script
├── docker-compose.yml               ← brings up angieai-onnx + angieai-reasoner + angieai-pentest
├── .env.example                     ← OPENROUTER_API_KEY + service URLs template
├── ETHICS.md                        ← authorized-use-only policy for the recon/pentest lane
├── .github/workflows/
│   ├── chimera-ci.yml               ← main CI: validates scripts, wires OPENROUTER_API_KEY
│   └── dmux-ci.yml                  ← dmux CI, reuses the same OPENROUTER_API_KEY secret
├── scripts/
│   ├── chimeraos_workflow_bundle.sh ← real dmux/worktree + image sign/SBOM supply-chain script
│   ├── termux_stack_up.sh           ← brings up all 3 services natively on Termux (no Docker)
│   ├── termux_stack_down.sh         ← stops what termux_stack_up.sh started
│   ├── wifi_recon_termux.sh         ← passive Wi-Fi beacon recon via Termux:API → angieai-pentest
│   ├── sync_to_chimeraos_drive.sh   ← mirrors this repo onto the ChimeraOS SanDisk drive (macOS/Linux)
│   └── Sync-ToChimeraOSDrive.ps1    ← same mirror sync, for Windows
├── services/
│   ├── angieai-onnx/                ← FastAPI + ONNX Runtime local inference lane
│   ├── angieai-reasoner/            ← deterministic routing/reasoning microservice
│   └── angieai-pentest/             ← authorized-use-only recon/diagnostics microservice (cyberdeck mission)
├── repos/                           ← pre-cloned BB10/WebWorks build + reference repos (see repos/REPOS.md)
├── apps/
│   └── bb10-bridge-console/         ← real Q20 WebWorks app source (config.xml/index.html/assets) + prebuilt source zip, with a Recon panel wired to angieai-pentest and a selectable device background (Default / SpongeBob Voodoo)
├── docs/
│   ├── BUILD-Q20.md                          ← BlackBerry Q20 WebWorks build + install guide
│   ├── BB10-Mac-Linux-Bootstrap.md           ← full BB10 SDK/packager bootstrap (Mac/Linux)
│   ├── chimeraos_workflow_README.md          ← dmux/git-worktree/CI supply-chain workflow docs
│   ├── BB10_APK_Compatibility_Repository.pdf ← sideloadable Android APK compatibility matrix for BB OS 10.3.x/API 18 (browsers, media, utility, social apps + error codes)
│   ├── blackberry-devices-tls-workaround-pack.md ← BB10 vs. legacy BBOS TLS/HTTPS workaround strategy (BerryCore/Termux bridge, BBSSH, Opera Mini)
│   └── blackberry-package-source-index.md   ← trusted source index for Termux APKs, legacy BBOS ALX/COD/JAD/JAR, and BB10 BAR/APK formats
└── assets/
    ├── ChimeraOS-hummingbird-companion-logo.png
    ├── ChimeraOS-better-terminal-splash-emblem.png
    ├── Explosive-ChimeraOS-splash-poster.png
    ├── Blackberry-trail-berry-Chimera-emblem.png
    ├── Skull-berry-chimera-logo.png
    └── Green-skull-apple-Chimera-boot-logo.png
```

## Quick start (Termux)

```bash
pkg update -y
curl -fsSL -o setup.sh "https://raw.githubusercontent.com/<your-repo>/ChimeraOS/main/setup.sh"
less setup.sh          # always read before running — download-then-run, never blind-pipe
chmod +x setup.sh
./setup.sh
```

`setup.sh` auto-detects Termux vs. Linux vs. macOS and installs the matching
toolchain (see script header). No local repo yet? Just `chmod +x setup.sh && ./setup.sh`
from this folder directly — no need to fetch it remotely first.

## Bring up the local AI services

On Linux/macOS (Docker):

```bash
cp .env.example .env      # fill in OPENROUTER_API_KEY
docker compose up --build
curl -s http://localhost:8001/reason -X POST -H 'content-type: application/json' \
  -d '{"text": "build me an apk for the Q20"}'
curl -s http://localhost:8000/health
curl -s http://localhost:8002/health
```

`angieai-reasoner` (port 8001) decides which lane a request belongs to;
`angieai-onnx` (port 8000) is the local model-inference lane; `angieai-pentest`
(port 8002) is the authorized-use-only recon/diagnostics lane — see
`ETHICS.md` before pointing it at anything. `angieai-onnx` now ships
with a verified default `model.onnx` (MNIST digit classifier, see
`services/angieai-onnx/README.md`) so the container builds and
`/predict` returns real output instead of a stub error — swap it for
AngieAI's real NLP model when one is ready.

On Termux/Android (no Docker — runs the same three services natively):

```bash
chmod +x scripts/termux_stack_up.sh scripts/termux_stack_down.sh
./scripts/termux_stack_up.sh          # starts all 3 in the background
./scripts/wifi_recon_termux.sh        # optional: passive Wi-Fi beacon recon (needs Termux:API)
./scripts/termux_stack_down.sh        # stop everything
```

See `SUPPORT.md` if either
container doesn't come up cleanly.

## CI setup (GitHub Actions)

1. Repo → **Settings → Secrets and variables → Actions → New repository secret**.
2. Name it `OPENROUTER_API_KEY`, paste your [OpenRouter](https://openrouter.ai/) key.
3. `.github/workflows/chimera-ci.yml` and `dmux-ci.yml` both read that same
   secret — no need to duplicate it per workflow.
4. Need different keys per environment? Create a GitHub **Environment**
   (e.g. `production`), add the secret there, and set `environment: production`
   on the job that needs it.

## dmux / git-worktree workflow

```bash
chmod +x scripts/chimeraos_workflow_bundle.sh
./scripts/chimeraos_workflow_bundle.sh init-worktrees /path/to/repo
./scripts/chimeraos_workflow_bundle.sh sync-branches /path/to/repo
./scripts/chimeraos_workflow_bundle.sh premerge-checks /path/to/repo
./scripts/chimeraos_workflow_bundle.sh merge-back /path/to/repo
```

Container supply-chain commands (build/sign/SBOM/verify) are documented in
`docs/chimeraos_workflow_README.md` and implemented in the same script.

## Pre-cloned BB10/WebWorks repos

`repos/` ships pinned, pre-cloned snapshots of the BlackBerry 10 packager
and reference code the Q20 build path needs, so you don't have to hunt
down dead BlackBerry download links from scratch:

- `repos/BB10-Webworks-Packager/` — the `bbwp` packager itself
- `repos/WebWorks-Community-APIs/` — community Cordova/WebWorks plugins (BT SPP, invoke/invoker, NFC, etc.)
- `repos/BB10-WebWorks-Samples/` — official BlackBerry sample WebWorks apps
- `repos/bbUI.js/` — BlackBerry-native-look UI toolkit for the Q20's square display

See `repos/REPOS.md` for pinned commit hashes, licenses, what's *not*
vendored (proprietary BBNDK/WebWorks SDK binaries — no public repo exists),
and the end-to-end packaging command sequence.

## Principles carried through this whole build

1. **Free / sign-up-only tools preferred.** OpenRouter + Google AI Studio + Termux
   packages over paid subscriptions.
2. **Download-then-run, never blind pipe-to-shell.** Every install script is meant
   to be fetched, read, then executed — not `curl | sh`.
3. **One organism, many aliases.** AngieAI / Delta-4 / Lince-Z / Lynx Linux / MeduZa /
   Berry-Chan are the same continuity — don't fork the identity when adding features.
4. **Day 0 / Archive Ω is permanent.** Core memory and backstory canon get preserved
   and backed up, not regenerated from scratch each build.
