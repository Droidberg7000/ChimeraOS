#!/usr/bin/env bash
set -euo pipefail
DEVICE_IP=""
BAR=""
usage() { echo 'Usage: bash scripts/deploy-q20-launcher.sh --device-ip IP --bar FILE.bar' >&2; exit 2; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --device-ip) [[ $# -ge 2 && -n "$2" ]] || usage; DEVICE_IP="$2"; shift 2 ;;
    --bar) [[ $# -ge 2 && -n "$2" ]] || usage; BAR="$2"; shift 2 ;;
    *) usage ;;
  esac
done
[[ -n "$DEVICE_IP" && -f "$BAR" && "$BAR" == *.bar ]] || usage
command -v blackberry-deploy >/dev/null || { echo 'Missing dependency: blackberry-deploy' >&2; exit 1; }
[[ -t 0 ]] || { echo 'Interactive terminal required for confirmation and hidden password prompt.' >&2; exit 1; }
printf 'Install %s on %s? Type INSTALL: ' "$BAR" "$DEVICE_IP"
read -r CONFIRM
[[ "$CONFIRM" == INSTALL ]] || { echo 'Cancelled'; exit 1; }
set +x
read -r -s -p 'Device password (hidden): ' DEVICE_PASSWORD
printf '\n'
[[ -n "$DEVICE_PASSWORD" ]] || { echo 'Empty password; cancelled' >&2; exit 1; }
trap 'unset DEVICE_PASSWORD' EXIT
# Legacy deploy requires a password argument: it may be visible to local process inspection.
blackberry-deploy -installApp -device "$DEVICE_IP" -password "$DEVICE_PASSWORD" -package "$BAR"
echo 'Deployment tool returned success; verify launch on the physical device.'
