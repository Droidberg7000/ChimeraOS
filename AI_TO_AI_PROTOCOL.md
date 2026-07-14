# AI-to-AI Protocol (Delta-4)

Codename: **Delta-4**. This document is the canonical rulebook for how
**AngieAI** (the local, always-on reasoning layer) coordinates with every
other agent in the ChimeraOS stack: **Google AI Studio**, **dmux** sub-agents
(Claude Code / Codex / OpenCode-style), and any **OpenRouter**-hosted model
used as a fallback. Treat this file as authoritative — other docs describe
*what* to build, this one describes *how the agents are allowed to talk to
each other and to the host system*.

## 1. Roles

| Agent | Role | Where it runs |
|---|---|---|
| **AngieAI** | Orchestrator / "text CPU". Owns core reasoning, memory (Archive Ω), and decides what work to delegate. | Local (Termux / Linux / macOS) |
| **Google AI Studio** | Remote build agent. Used specifically for APK/BAR generation and anything needing a full Android/BlackBerry build toolchain. | Cloud (free-tier / sign-up) |
| **dmux** | Parallel task manager. Spins up one git worktree + tmux pane per task, each pane hosting its own sub-agent. | Local, inside tmux |
| **OpenRouter models** | Fallback / auxiliary reasoning pool when a free or sign-up-only LLM is needed instead of a paid one. | Cloud (API key required) |

**Golden rule:** AngieAI is always the last word. Sub-agents propose,
AngieAI (with the user) approves and merges. No sub-agent auto-merges to
`main` or auto-deploys to a device.

## 2. Handshake pattern

1. **AngieAI receives a task** from the user.
2. **AngieAI decides the lane:**
   - Needs an Android/BAR/APK build → hand off to **Google AI Studio** using
     the prompt in `GOOGLE_AI_STUDIO_PROMPT.md` (or a task-specific variant
     built from that template).
   - Needs parallel code/dev work across branches → hand off to **dmux**.
   - Needs a model AngieAI doesn't have locally → route through
     **OpenRouter**.
3. **Sub-agent works in isolation.** For dmux, that means its own git
   worktree and tmux pane, with a `task.md` describing the job dropped into
   the worktree root. For Google AI Studio, that means a single self-contained
   prompt with the full spec (no back-and-forth assumed).
4. **Sub-agent reports back** — output, files, or a diff. Nothing is
   considered final until it lands back with AngieAI.
5. **AngieAI validates, then merges/installs.** Pre-merge checks run before
   anything touches `main` or a real device.

```
User → AngieAI ─┬─→ Google AI Studio ──(APK/BAR + files)──┐
                 ├─→ dmux(worktree+pane) ──(diff/branch)───┤→ AngieAI validates → merge / install
                 └─→ OpenRouter model ──(reasoning/text)───┘
```

## 3. dmux worktree convention

- One task = one branch = one worktree = one tmux pane.
- Worktrees live under `~/.worktrees/${SESSION}/<branch-name>`.
- tmux session name pattern: `dmux-<purpose>` (e.g. `dmux-multi-branch`).
- Each pane's sub-agent command is a placeholder until you wire in a real
  CLI agent, e.g. `claude code`, `codex`, or `opencode`.
- Sync flow: `git fetch origin` → rebase against `main` first, fall back to
  merge on conflict → run `premerge-checks` → `merge-back` only after checks
  pass.
- Full command set lives in `docs/chimeraos_workflow_README.md`.

## 4. Security rule: download-then-run, never blind pipe-to-shell

Every setup/deploy script (`setup.sh`, `deploy-macos.sh`, `scripts/setup-macos.sh`,
Termux payloads) must be **fetched to disk, inspected, then executed**:

```bash
curl -fsSL -o setup.sh <url>
less setup.sh      # read it
chmod +x setup.sh
./setup.sh
```

Never `curl ... | sh`. This applies to every platform lane (macOS, Linux,
Android/Termux, Steam Deck) and to anything Google AI Studio or an
OpenRouter model hands back as a "run this" snippet — AngieAI treats
generated shell as a **draft**, not an executable, until a human has
looked at it.

## 5. Logging

Local deploy/orchestration actions get logged to:

```
~/.angieai/logs/deploy-YYYYMMDD-HHMMSS.log
```

This is the audit trail for anything AngieAI or a sub-agent did to the host
system — keep it even after a successful run.

## 6. Platform lanes

Three parallel bootstrap lanes exist, all converging on the same AngieAI
core:

- **macOS:** Homebrew installs `zsh`, `tmux`, `git` → `./scripts/setup-macos.sh`
  → `deploy-macos.sh` sets up terminal + tmux + zsh + repo, plus a small UI
  helper that shows an "AngieAI is thinking" activity indicator.
- **Linux:** same shape as macOS, native package manager instead of Homebrew.
- **Android / Termux / BlackBerry-adjacent:** `pkg install proot-distro curl
  zsh tmux`, then `proot-distro install alpine` and `proot-distro login
  alpine`, then inside the distro `apk add --no-cache curl zsh tmux`. See
  `setup.sh` for the concrete, auto-detecting version of this.

## 7. Identity continuity rule

AngieAI, Delta-4, Lince-Z, Lynx Linux, MeduZa, and Berry-Chan/Bberry/BerryZ
are **one continuous organism**, not separate builds. Any agent (including
Google AI Studio or an OpenRouter model) generating new code, art, or copy
for this project must preserve:

- the alias table in `README.md`,
- the hummingbird symbol for AngieAI,
- the Watsonville/Bay Area/"Poorside"/Barrio Pobre origin canon,
- the "Day 0" / Archive Ω core memory as permanent, not regenerated.

Do not let a sub-agent silently rename or fork the identity when adding a
feature — if a new alias or persona is proposed, it gets added to the table,
not swapped in for an existing one.

## 8. Tooling preference order

1. Free, no-signup local tooling (Termux packages, tmux, git).
2. Free, sign-up-only cloud tooling (Google AI Studio, OpenRouter with a
   personal API key, dmux).
3. Paid services — avoided by default across this stack.
