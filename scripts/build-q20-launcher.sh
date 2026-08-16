#!/usr/bin/env bash
# build-q20-launcher.sh
# Builds the Q20 Chimera Launcher (WebWorks/Cordova) as a signed .bar.
# Requires: Node.js, Cordova CLI compatible with BB10, BB10 WebWorks/Native SDK tools.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
LAUNCHER_DIR="${ROOT_DIR}/q20-launcher"
BUILD_DIR="${ROOT_DIR}/build/q20-launcher"

usage() {
  echo "Usage: $0 [--release] [--deploy] [--device-ip IP] [--device-password PASS]"
  echo "  --release          Build a release (signed) .bar"
  echo "  --deploy           Deploy the built .bar to a Q20 device"
  echo "  --device-ip IP     Q20 device IP (required if --deploy)"
  echo "  --device-password PASS  Q20 device password (required if --deploy)"
  exit 1
}

RELEASE=0
DEPLOY=0
DEVICE_IP=""
DEVICE_PASSWORD=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --release) RELEASE=1; shift ;;
    --deploy) DEPLOY=1; shift ;;
    --device-ip) DEVICE_IP="$2"; shift 2 ;;
    --device-password) DEVICE_PASSWORD="$2"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ ${DEPLOY} -eq 1 && ( -z "${DEVICE_IP}" || -z "${DEVICE_PASSWORD}" ) ]]; then
  echo "Error: --deploy requires --device-ip and --device-password"
  usage
fi

if [[ ! -d "${LAUNCHER_DIR}" ]]; then
  echo "Error: Launcher directory not found at ${LAUNCHER_DIR}"
  echo "Create the q20-launcher Cordova project according to Q20-FULL-LAUNCHER-SPEC.md"
  exit 1
fi

mkdir -p "${BUILD_DIR}"

cd "${LAUNCHER_DIR}"

if [[ ${RELEASE} -eq 1 ]]; then
  echo "Building release .bar (signing configured via BB10 SDK)"
  cordova build --release blackberry10
else
  echo "Building debug .bar"
  cordova build blackberry10
fi

# Locate the .bar
BAR_DIR="${LAUNCHER_DIR}/platforms/blackberry10/build/device"
BAR_FILE=$(find "${BAR_DIR}" -maxdepth 1 -name '*.bar' -type f | head -n1)

if [[ -z "${BAR_FILE}" ]]; then
  echo "Error: No .bar found in ${BAR_DIR}"
  exit 1
fi

BAR_NAME=$(basename "${BAR_FILE}")
echo "Built .bar: ${BAR_NAME}"

cp "${BAR_FILE}" "${BUILD_DIR}/"
echo "Copied .bar to ${BUILD_DIR}/${BAR_NAME}"

# Generate simple manifest
MANIFEST="${BUILD_DIR}/manifest.json"
cat > "${MANIFEST}" <<EOF
{
  "artifact": "${BAR_NAME}",
  "build_type": "${RELEASE:+release}${RELEASE:-debug}",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "spec": "Q20-FULL-LAUNCHER-SPEC.md"
}
EOF

echo "Generated manifest: ${MANIFEST}"

if [[ ${DEPLOY} -eq 1 ]]; then
  echo "Deploying to Q20 at ${DEVICE_IP}"
  blackberry-deploy -installApp -device "${DEVICE_IP}" -password "${DEVICE_PASSWORD}" "${BUILD_DIR}/${BAR_NAME}"
  echo "Deploy complete"
fi

echo "Build complete: ${BUILD_DIR}/${BAR_NAME}"
