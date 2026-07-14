#!/usr/bin/env bash
# Stops services started by scripts/termux_stack_up.sh.
set -eu

STATE_DIR="$HOME/.angieai"
PID_DIR="$STATE_DIR/pids"

log() { printf '[ChimeraOS] %s\n' "$1"; }

if [ ! -d "$PID_DIR" ]; then
  log "No pid dir at $PID_DIR — nothing to stop."
  exit 0
fi

for pidfile in "$PID_DIR"/*.pid; do
  [ -e "$pidfile" ] || continue
  name="$(basename "$pidfile" .pid)"
  pid="$(cat "$pidfile")"
  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid"
    log "Stopped $name (pid $pid)."
  else
    log "$name (pid $pid) not running."
  fi
  rm -f "$pidfile"
done

log "Done."
