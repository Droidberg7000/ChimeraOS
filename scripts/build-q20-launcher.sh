#!/usr/bin/env bash
# Builds only; deployment is a separate, explicit step.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/q20-launcher"
MODE=debug
if [[ $# -gt 1 ]]; then echo 'Usage: bash scripts/build-q20-launcher.sh [--release]' >&2; exit 2; fi
if [[ $# -eq 1 ]]; then
  [[ "$1" == --release ]] || { echo 'Only --release is supported; use deploy-q20-launcher.sh separately.' >&2; exit 2; }
  MODE=release
fi
for tool in python3 cordova; do
  command -v "$tool" >/dev/null || { echo "Missing dependency: $tool" >&2; exit 1; }
done
python3 "$APP/tools/check_source.py"
[[ -d "$APP/platforms/blackberry10" ]] || {
  echo 'BB10 Cordova platform is not configured. Provision a verified legacy SDK/platform first; no automatic downloads performed.' >&2
  exit 1
}
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
MARKER="$STAGE/build-start"
touch "$MARKER"
cd "$APP"
if [[ "$MODE" == release ]]; then cordova build --release blackberry10; else cordova build blackberry10; fi
ARTIFACTS=()
while IFS= read -r -d '' file; do ARTIFACTS+=("$file"); done < <(find platforms/blackberry10 -type f -name '*.bar' -newer "$MARKER" -print0)
[[ ${#ARTIFACTS[@]} -eq 1 ]] || {
  printf 'Expected exactly one newly written BAR, found %s. No artifact published.\n' "${#ARTIFACTS[@]}" >&2
  exit 1
}
python3 - "${ARTIFACTS[0]}" "$ROOT/build/q20-launcher" "$MODE" <<'PY'
import datetime, hashlib, json, pathlib, shutil, sys, zipfile
src, out, mode = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3]
with zipfile.ZipFile(src) as z:
    if z.testzip() is not None:
        raise SystemExit('Archive integrity check failed')
    if 'META-INF/MANIFEST.MF' not in z.namelist():
        raise SystemExit('BAR manifest is missing')
out.mkdir(parents=True, exist_ok=True)
dst = out / src.name
shutil.copy2(src, dst)
data = {'artifact': dst.name, 'build_type': mode, 'sha256': hashlib.sha256(dst.read_bytes()).hexdigest(), 'timestamp': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'verification': 'Archive structure only; signing, installability and device execution unverified'}
(out / 'manifest.json').write_text(json.dumps(data, indent=2) + '\n', encoding='utf-8')
print('Packaged:', dst)
print(data['verification'])
PY
