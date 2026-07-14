#!/usr/bin/env bash
# ChimeraOS / AngieAI — native Termux stack-up (no Docker required).
#
# Docker doesn't run on stock Android/Termux, so this brings up the same
# three services docker-compose.yml defines, natively, as background
# uvicorn processes under Termux's own Python. Read before running per
# AI_TO_AI_PROTOCOL.md's download-then-run rule.
#
# Usage (from the repo root):
#   chmod +x scripts/termux_stack_up.sh
#   ./scripts/termux_stack_up.sh
#
# Stop everything with scripts/termux_stack_down.sh.
set -eu

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$HOME/.angieai"
PID_DIR="$STATE_DIR/pids"
LOG_DIR="$STATE_DIR/logs"
mkdir -p "$PID_DIR" "$LOG_DIR"

log() { printf '[ChimeraOS] %s\n' "$1"; }

require_termux() {
  if [ -z "${TERMUX_VERSION:-}" ] && [ ! -d "/data/data/com.termux" ]; then
    log "This script targets Termux. On Linux/macOS, use 'docker compose up --build' instead."
    log "Continuing anyway (assuming a Termux-like userland)..."
  fi
}

ensure_python() {
  if ! command -v python >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
    log "Installing python via pkg..."
    pkg install -y python
  fi
}

PY="$(command -v python3 || command -v python)"

ensure_deps() {
  local dir="$1"
  shift
  log "Installing deps for $dir: $*"
  "$PY" -m pip install --quiet --disable-pip-version-check "$@" || \
    log "WARNING: some deps for $dir failed to install (see above) — that service may not start."
}

start_service() {
  local name="$1" dir="$2" port="$3"
  local pidfile="$PID_DIR/$name.pid"
  local logfile="$LOG_DIR/$name.log"

  if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    log "$name already running (pid $(cat "$pidfile")), skipping."
    return
  fi

  log "Starting $name on port $port -> $logfile"
  (
    cd "$ROOT_DIR/$dir"
    PENTEST_LOG_DIR="$LOG_DIR" nohup "$PY" -m uvicorn app.main:app \
      --host 0.0.0.0 --port "$port" >>"$logfile" 2>&1 &
    echo $! > "$pidfile"
  )
  sleep 1
  if kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    log "$name started (pid $(cat "$pidfile"))."
  else
    log "$name failed to start — check $logfile"
  fi
}

main() {
  require_termux
  ensure_python

  ensure_deps "services/angieai-reasoner" fastapi uvicorn pydantic
  ensure_deps "services/angieai-pentest" fastapi uvicorn pydantic
  ensure_deps "services/angieai-onnx" fastapi uvicorn pydantic onnxruntime || true

  start_service "angieai-reasoner" "services/angieai-reasoner" 8001
  start_service "angieai-pentest" "services/angieai-pentest" 8002
  start_service "angieai-onnx" "services/angieai-onnx" 8000

  log "Stack up. Health checks:"
  log "  curl -s http://localhost:8001/health"
  log "  curl -s http://localhost:8002/health"
  log "  curl -s http://localhost:8000/health"
  log "PIDs in $PID_DIR, logs in $LOG_DIR. Stop with scripts/termux_stack_down.sh."
}

main "$@"
