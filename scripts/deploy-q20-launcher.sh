#!/usr/bin/env bash
# deploy-q20-launcher.sh
# Deploys an existing Q20 Chimera Launcher .bar to a device.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build/q20-launcher"

usage() {
  echo "Usage: $0 --device-ip IP --device-password PASS [--bar BAR_FILE]"
  echo "  --device-ip IP         Q20 device IP"
  echo "  --device-password PASS Q20 device password"
  echo "  --bar BAR_FILE         Specific .bar to deploy (default: latest in build/q20-launcher)"
  exit 1
}

DEVICE_IP=""
DEVICE_PASSWORD=""
BAR_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device-ip) DEVICE_IP="$2"; shift 2 ;;
    --device-password) DEVICE_PASSWORD="$2"; shift 2 ;;
    --bar) BAR_FILE="$2"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ -z "${DEVICE_IP}" || -z "${DEVICE_PASSWORD}" ]]; then
  echo "Error: --device-ip and --device-password are required"
  usage
fi

if [[ -z "${BAR_FILE}" ]]; then
  BAR_FILE=$(find "${BUILD_DIR}" -maxdepth 1 -name '*.bar' -type f | sort | tail -n1)
  if [[ -z "${BAR_FILE}" ]]; then
    echo "Error: No .bar found in ${BUILD_DIR} and none specified via --bar"
    exit 1
  fi
fi

if [[ ! -f "${BAR_FILE}" ]]; then
  echo "Error: .bar not found: ${BAR_FILE}"
  exit 1
fi

BAR_NAME=$(basename "${BAR_FILE}")
echo "Deploying ${BAR_NAME} to ${DEVICE_IP}"

blackberry-deploy -installApp -device "${DEVICE_IP}" -password "${DEVICE_PASSWORD}" "${BAR_FILE}"

echo "Deploy complete: ${BAR_NAME}"
