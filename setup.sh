#!/usr/bin/env bash
# ChimeraOS / AngieAI bootstrap script
# Codename: Delta-4 setup lane
#
# Auto-detects Termux (Android/BlackBerry-adjacent), Linux, or macOS and
# installs the matching toolchain: curl, zsh, tmux, git, proot-distro
# (Termux only). Never blind-pipes into a shell — read this script before
# running it, per the AI_TO_AI_PROTOCOL.md "download-then-run" rule.
#
# Usage:
#   chmod +x setup.sh
#   ./setup.sh
#
set -eu

LOG_DIR="$HOME/.angieai/logs"
TS="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$LOG_DIR/deploy-$TS.log"

log() {
  printf '%s\n' "$1" | tee -a "$LOG_FILE"
}

detect_platform() {
  if [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux" ]; then
    echo "termux"
  else
    case "$(uname -s)" in
      Darwin) echo "macos" ;;
      Linux) echo "linux" ;;
      *) echo "unknown" ;;
    esac
  fi
}

setup_termux() {
  log "[ChimeraOS] Termux lane detected."
  pkg update -y
  pkg install -y proot-distro curl zsh tmux git

  DISTRO="alpine"
  if ! proot-distro list 2>/dev/null | grep -q "$DISTRO"; then
    log "[ChimeraOS] Installing proot-distro: $DISTRO"
    proot-distro install "$DISTRO"
  fi

  log "[ChimeraOS] Provisioning $DISTRO sandbox with curl/zsh/tmux."
  proot-distro login "$DISTRO" -- sh -c "apk add --no-cache curl zsh tmux"

  log "[ChimeraOS] Termux + $DISTRO sandbox ready."
}

setup_linux() {
  log "[ChimeraOS] Linux lane detected."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y
    sudo apt-get install -y curl zsh tmux git
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y curl zsh tmux git
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm curl zsh tmux git
  else
    log "[ChimeraOS] No known package manager found. Install curl, zsh, tmux, git manually."
  fi
}

setup_macos() {
  log "[ChimeraOS] macOS lane detected."
  if ! command -v brew >/dev/null 2>&1; then
    log "[ChimeraOS] Homebrew not found. Install it from https://brew.sh first, then re-run."
    exit 1
  fi
  brew install zsh tmux git

  if [ -x "./scripts/setup-macos.sh" ]; then
    log "[ChimeraOS] Running ./scripts/setup-macos.sh"
    ./scripts/setup-macos.sh
  fi
}

main() {
  mkdir -p "$LOG_DIR"
  : > "$LOG_FILE"
  log "[ChimeraOS] === Delta-4 bootstrap started $TS ==="

  PLATFORM="$(detect_platform)"
  log "[ChimeraOS] Detected platform: $PLATFORM"

  case "$PLATFORM" in
    termux) setup_termux ;;
    linux) setup_linux ;;
    macos) setup_macos ;;
    *)
      log "[ChimeraOS] Unknown platform. Manual setup required: curl, zsh, tmux, git."
      exit 1
      ;;
  esac

  log "[ChimeraOS] === Bootstrap finished. Log saved to $LOG_FILE ==="
  log "[ChimeraOS] Next: review AI_TO_AI_PROTOCOL.md, then open a tmux session and start dmux."
}

main "$@"
