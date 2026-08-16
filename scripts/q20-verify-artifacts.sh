#!/usr/bin/env bash
# q20-verify-artifacts.sh
# Verifies Q20 build artifacts (launcher .bar, overlay packages, research bundles) via hashes.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build"

usage() {
  echo "Usage: $0 [--create | --verify]"
  echo "  --create  Create/update hash manifests for all Q20 artifacts"
  echo "  --verify  Verify existing artifacts against stored hashes"
  exit 1
}

MODE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --create) MODE="create"; shift ;;
    --verify) MODE="verify"; shift ;;
    *) usage ;;
  esac
done

if [[ -z "${MODE}" ]]; then
  usage
fi

HASH_FILE="${BUILD_DIR}/q20-artifacts.sha256"

if [[ "${MODE}" == "create" ]]; then
  echo "Creating hash manifest at ${HASH_FILE}"
  : > "${HASH_FILE}"
  for dir in q20-launcher q20-bb10-overlay q20-standalone; do
    if [[ -d "${BUILD_DIR}/${dir}" ]]; then
      (cd "${BUILD_DIR}/${dir}" && find . -type f -not -name '*.sha256' -print0 | \
        xargs -0 sha256sum) >> "${HASH_FILE}"
    fi
  done
  echo "Hash manifest created/updated"
elif [[ "${MODE}" == "verify" ]]; then
  if [[ ! -f "${HASH_FILE}" ]]; then
    echo "Error: Hash manifest not found at ${HASH_FILE}"
    echo "Run with --create first"
    exit 1
  fi
  echo "Verifying artifacts against ${HASH_FILE}"
  (cd "${BUILD_DIR}" && sha256sum -c "q20-artifacts.sha256")
  echo "Verification complete"
fi
