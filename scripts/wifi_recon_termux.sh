#!/usr/bin/env bash
# ChimeraOS / AngieAI — passive Wi-Fi recon via Termux:API.
#
# PASSIVE ONLY. This reads the Wi-Fi beacon frames your device already
# received over the air (same data your phone's Wi-Fi picker shows) via
# `termux-wifi-scaninfo`. It does not associate to any network, does not
# deauth, does not capture handshakes, and does not attempt WPS PINs — this
# service intentionally does not implement active Wi-Fi attacks. See
# ETHICS.md.
#
# Requires:
#   - Termux:API app installed (from F-Droid/Play) + `pkg install termux-api`
#   - Location permission granted to Termux:API (Android requires this for
#     Wi-Fi scan results)
#
# Usage:
#   chmod +x scripts/wifi_recon_termux.sh
#   ./scripts/wifi_recon_termux.sh [angieai-pentest-host] [angieai-pentest-port]
#
# Defaults to posting results to http://localhost:8002 (angieai-pentest).
set -eu

HOST="${1:-localhost}"
PORT="${2:-8002}"
URL="http://$HOST:$PORT/recon/wifi"
PY="$(command -v python3 || command -v python)"

log() { printf '[ChimeraOS] %s\n' "$1" >&2; }

if ! command -v termux-wifi-scaninfo >/dev/null 2>&1; then
  log "termux-wifi-scaninfo not found. Install Termux:API app + 'pkg install termux-api'."
  exit 1
fi

log "Reading passively-received Wi-Fi beacon info..."
RAW="$(termux-wifi-scaninfo)"

# termux-wifi-scaninfo already returns JSON like:
#   [{"bssid": "...", "ssid": "...", "rssi": -50, "frequency": 2412,
#     "capabilities": "[WPA2-PSK-CCMP][ESS]", ...}, ...]
# Reshape into {"networks": [...]} for the /recon/wifi endpoint.
PAYLOAD="$(echo "$RAW" | "$PY" -c "
import json, sys
raw = json.loads(sys.stdin.read())
nets = []
for n in raw:
    nets.append({
        'bssid': n.get('bssid'),
        'ssid': n.get('ssid'),
        'rssi': n.get('rssi'),
        'frequency': n.get('frequency'),
        'capabilities': n.get('capabilities'),
    })
print(json.dumps({'networks': nets}))
")"

log "Posting to $URL ..."
curl -s -X POST "$URL" -H 'content-type: application/json' -d "$PAYLOAD" | "$PY" -m json.tool
