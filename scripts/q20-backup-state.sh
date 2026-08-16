#!/usr/bin/env bash
# q20-backup-state.sh
# Creates a timestamped backup directory for Q20 experiments and records OS/device state.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BACKUP_ROOT="${ROOT_DIR}/backups/q20"

usage() {
  echo "Usage: $0 --device-ip IP --device-password PASS [--label LABEL]"
  echo "  --device-ip IP         Q20 device IP"
  echo "  --device-password PASS Q20 device password"
  echo "  --label LABEL          Optional label for this backup (e.g., pre-overlay, pre-standalone)"
  exit 1
}

DEVICE_IP=""
DEVICE_PASSWORD=""
LABEL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device-ip) DEVICE_IP="$2"; shift 2 ;;
    --device-password) DEVICE_PASSWORD="$2"; shift 2 ;;
    --label) LABEL="$2"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ -z "${DEVICE_IP}" || -z "${DEVICE_PASSWORD}" ]]; then
  echo "Error: --device-ip and --device-password are required"
  usage
fi

mkdir -p "${BACKUP_ROOT}"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
if [[ -n "${LABEL}" ]]; then
  BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}-${LABEL}"
else
  BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
fi

mkdir -p "${BACKUP_DIR}"

echo "Creating backup in: ${BACKUP_DIR}"

# Record device state via blackberry-deploy info (if available)
if command -v blackberry-deploy &>/dev/null; then
  blackberry-deploy -deviceInfo -device "${DEVICE_IP}" -password "${DEVICE_PASSWORD}" > "${BACKUP_DIR}/device-info.txt" 2>&1 || true
else
  echo "blackberry-deploy not found; skipping device info capture" > "${BACKUP_DIR}/device-info.txt"
fi

# Placeholder for BB10 backup tool integration
# Integrate your preferred BB10 backup CLI/GUI tool here to create a full user-data backup.
# For example, invoke the official BB10 backup utility and store the output in ${BACKUP_DIR}/bb10-backup/

cat > "${BACKUP_DIR}/backup-notes.md" <<EOF
# Q20 Backup: ${BACKUP_DIR}

- Timestamp: ${TIMESTAMP}
- Label: ${LABEL:-none}
- Device IP: ${DEVICE_IP}
- Notes: Add details about OS version, variant, and reason for backup.

## Pre-backup checks

- [ ] Confirmed exact Q20 variant (e.g., SQC100-1/2/3)
- [ ] Recorded current BB10 version and build ID
- [ ] Verified development mode and connectivity

## Post-backup checks

- [ ] Verified backup completeness
- [ ] Noted any issues or warnings
EOF

echo "Backup directory created: ${BACKUP_DIR}"
echo "Edit ${BACKUP_DIR}/backup-notes.md to record additional details."
