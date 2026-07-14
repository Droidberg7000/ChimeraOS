# Vendored reference repositories

These are pre-cloned, pinned copies of the upstream BlackBerry 10 / WebWorks
tooling and reference code that the Q20 build path (`docs/BUILD-Q20.md`,
`docs/BB10-Mac-Linux-Bootstrap.md`) depends on. They're vendored here so the
final build package is self-contained and doesn't depend on BlackBerry's
long-dead official SDK download links. Nested `.git` history was stripped —
these are plain source snapshots, not submodules. Each folder's exact
upstream commit is recorded below for provenance/updating later.

| Folder | Upstream | Pinned commit | License | Why it's here |
|---|---|---|---|---|
| `BB10-Webworks-Packager/` | [blackberry/BB10-Webworks-Packager](https://github.com/blackberry/BB10-Webworks-Packager) (archived) | `2e7678a7a714e9d853bbadb46725bc29216f2465` | mixed (see repo) | The actual `bbwp` packager that turns the Q20 WebWorks source (`config.xml` + `index.html` + `assets/`) into a `.bar`. This is the tool `docs/BB10-Mac-Linux-Bootstrap.md` step 2 tells you to clone — it's now already here. |
| `WebWorks-Community-APIs/` | [blackberry/WebWorks-Community-APIs](https://github.com/blackberry/WebWorks-Community-APIs) (archived) | `3117f4ed9f0e28be639fe201b8988bacd8e8fb50` | Apache-2.0 | Community Cordova/WebWorks plugin examples (Bluetooth SPP, invoke/invoker, NFC, etc.) — reference code if AngieAI's BB10 Bridge Console needs a native plugin beyond stock WebWorks APIs. Build-artifact junk (`.obj/`, `.gch`, `.so`, sample `.bar`/media files) was pruned to keep this lean; source/docs/assets kept intact. |
| `BB10-WebWorks-Samples/` | [blackberry/BB10-WebWorks-Samples](https://github.com/blackberry/BB10-WebWorks-Samples) (archived) | `02cf87de5adbe7852fb14797ba24c41ba0641421` | Apache-2.0 | Official BlackBerry sample WebWorks apps (Maps, invoke, etc.) — useful patterns for `config.xml` permissions and API usage on the Q20 target. |
| `bbUI.js/` | [blackberry/bbUI.js](https://github.com/blackberry/bbUI.js) (archived) | `5da817014b2773f48b825ac7f32f9df944a0f1fd` | Apache-2.0 | BlackBerry-native-look UI toolkit for WebWorks HTML5 apps. Directly useful for making the BB10 Bridge Console app match the Classic/Q20 square-display, large-touch-target look called out in `docs/BUILD-Q20.md`. |

## What's still NOT vendored (can't be — proprietary/binary, no public repo)

- **BBNDK (BlackBerry 10 Native SDK)** — proprietary installer binary from
  BlackBerry, not on GitHub. Official download links are dead; an old
  Internet Archive mirror exists at
  [archive.org/download/native-SDK-for-blackberry10](https://archive.org/download/native-SDK-for-blackberry10/).
  You need `bbndk-env.sh` from this before `bbwp`/`blackberry-deploy` work.
- **BlackBerry 10 WebWorks SDK `dependencies/` directory** — same story,
  proprietary installer. `docs/BB10-Mac-Linux-Bootstrap.md` step 3 says to
  copy this into `BB10-Webworks-Packager/` once you have it. A community
  Linux port (`badtoyz/BB10-WebWorks-SDK-Linux-Gold`) that other guides
  reference has since been deleted from GitHub — confirmed unreachable as of
  this build (2026-07-14).
- **Signing keys / debug token** — per-developer, requested from BlackBerry's
  code-signing portal, can't be pre-fetched.

## Quick integration path

```bash
# 1. Get BBNDK + WebWorks SDK on disk (see docs/BB10-Mac-Linux-Bootstrap.md)
source /path/to/bbndk/bbndk-env.sh
cp -R /path/to/BB10-WebWorks-SDK/dependencies repos/BB10-Webworks-Packager/

# 2. Build the packager itself (one-time)
cd repos/BB10-Webworks-Packager
./configure && jake build

# 3. Package the Q20 app (see docs/BUILD-Q20.md for the app source layout)
./bbwp /path/to/bb10-bridge-console-q20-source.zip -o build-output

# 4. Install to device in Development Mode
blackberry-deploy -installApp -package build-output/*.bar -device <Q20-IP> -password <DEV-PASSWORD>
```
