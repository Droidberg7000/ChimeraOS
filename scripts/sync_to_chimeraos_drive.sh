#!/usr/bin/env bash
# sync_to_chimeraos_drive.sh
#
# Mirrors this repo (working tree, minus .git/build junk) onto the
# "ChimeraOS" SanDisk 500GB external drive whenever it's plugged in.
# Run this from the repo root AFTER the drive is mounted.
#
# macOS mounts external volumes under /Volumes/<name> by default.
# Linux (most desktop distros / udisks2) mounts under /media/$USER/<name>
# or /run/media/$USER/<name>. This script checks the common spots and lets
# you override with an explicit path.
#
# Usage:
#   ./scripts/sync_to_chimeraos_drive.sh                 # auto-detect
#   ./scripts/sync_to_chimeraos_drive.sh /Volumes/ChimeraOS   # explicit path
#
# Safe to re-run any time you want to refresh the drive with the latest
# build — it's an incremental mirror (rsync -a --delete), not a blind copy.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRIVE_NAME="ChimeraOS"
DEST_SUBDIR="ChimeraOS-final-build"

find_drive() {
    local candidates=(
        "/Volumes/${DRIVE_NAME}"
        "/media/${USER:-$(id -un)}/${DRIVE_NAME}"
        "/run/media/${USER:-$(id -un)}/${DRIVE_NAME}"
        "/mnt/${DRIVE_NAME}"
    )
    for c in "${candidates[@]}"; do
        if [ -d "$c" ]; then
            echo "$c"
            return 0
        fi
    done
    return 1
}

if [ "${1:-}" != "" ]; then
    DRIVE_PATH="$1"
else
    if ! DRIVE_PATH="$(find_drive)"; then
        echo "Could not auto-find a mounted '${DRIVE_NAME}' volume." >&2
        echo "Plug in the drive, confirm its mount point, then re-run with:" >&2
        echo "  ./scripts/sync_to_chimeraos_drive.sh /path/to/mounted/drive" >&2
        exit 1
    fi
fi

if [ ! -d "$DRIVE_PATH" ]; then
    echo "Path '$DRIVE_PATH' does not exist or isn't mounted." >&2
    exit 1
fi

DEST="${DRIVE_PATH%/}/${DEST_SUBDIR}"
mkdir -p "$DEST"

echo "Syncing ${REPO_ROOT} -> ${DEST}"
rsync -av --delete \
    --exclude ".git/" \
    --exclude "__pycache__/" \
    --exclude "node_modules/" \
    --exclude "*.pyc" \
    "${REPO_ROOT}/" "${DEST}/"

# Drop a timestamped marker so you can see at a glance when the drive was
# last refreshed, without needing to compare file contents.
date -u +"%Y-%m-%dT%H:%M:%SZ" > "${DEST}/.last_synced_utc"

echo "Done. Last synced (UTC): $(cat "${DEST}/.last_synced_utc")"
