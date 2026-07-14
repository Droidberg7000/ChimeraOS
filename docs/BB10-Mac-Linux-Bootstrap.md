# BB10 Bridge Console — Mac / Linux Bootstrap Guide

This guide is for building a real BB10 `.bar` from the final source package on macOS or Linux.

## What you need

Based on the BlackBerry WebWorks Packager and Framework documentation, the real build path requires:
- BlackBerry 10 Native SDK / BBNDK
- BlackBerry 10 WebWorks SDK
- the WebWorks `dependencies` directory copied into the packager tree
- Node and npm available
- BBNDK environment loaded before building
- the final source archive: `final-bb10-bridge-source.zip`

The open-source packager README specifically says to source `bbndk-env.sh`, copy the `dependencies` directory from the WebWorks SDK into the packager folder, run `./configure`, then `jake build`, and build apps with `./bbwp app.zip -o outdir`.

## Folder layout to aim for

Example:

```text
~/bb10/
  BB10-Webworks-Packager/
  final-bb10-bridge-source.zip
  debugtoken.bar                (optional)
```

## 1. Install / place required SDKs

You need your real BlackBerry 10 SDK installs on disk first.

Typical pieces:
- BBNDK folder containing `bbndk-env.sh`
- WebWorks SDK folder containing a `dependencies` directory

## 2. Clone the packager

```sh
git clone https://github.com/blackberry/BB10-Webworks-Packager.git
cd BB10-Webworks-Packager
```

## 3. Copy WebWorks dependencies into the packager

The packager README says to copy the `dependencies` directory from the installed WebWorks SDK into the cloned packager folder.

Example pattern:

```sh
cp -R /path/to/BB10-WebWorks-SDK/dependencies ./
```

After this, the packager folder should contain its own `dependencies/` tree.

## 4. Load the BBNDK environment

```sh
source /path/to/bbndk/bbndk-env.sh
```

This must be done in the current shell before configure/build/package commands.

## 5. Configure and build the packager

```sh
./configure
jake build
```

If `jake` is unavailable, install it with npm in a compatible environment.

## 6. Package the app into a BAR

Put `final-bb10-bridge-source.zip` somewhere convenient, then run:

```sh
./bbwp /full/path/to/final-bb10-bridge-source.zip -o /full/path/to/build-output
```

Important: the packager README warns that you should build from the proper packager output path and not arbitrarily from the repo root, otherwise the resulting BAR may not launch.

## 7. Find the generated BAR

```sh
find /full/path/to/build-output -name '*.bar'
```

## 8. Install to the Q20

With the device in Development Mode and its password known:

```sh
blackberry-deploy -installApp -package /full/path/to/generated.bar -device <Q20-IP> -password <DEV-PASSWORD>
```

If a debug token is required:

```sh
blackberry-deploy -installDebugToken /full/path/to/debugtoken.bar -device <Q20-IP> -password <DEV-PASSWORD>
```

## 9. Deploy backend helper script

Copy `bb10-bridge-backend-fixed-chmod777.sh` to the BB10 device and run it from a writable BB10 shell context such as your Term49 / BerryCore workflow.

## Troubleshooting

### `bbwp` fails immediately
- BBNDK env not loaded.
- missing WebWorks SDK `dependencies` copy.
- missing old-toolchain pieces expected by the packager.

### build completes but BAR will not launch
- packaged from the wrong path.
- dependency tree incomplete.
- app metadata/signing/debug-token mismatch.

### `blackberry-deploy` install fails
- wrong device IP.
- wrong Development Mode password.
- missing debug token or author mismatch.

## Practical advice

Use the final install-oriented bundle you already have:
- `final-bb10-bridge-source.zip`
- `bb10-bridge-backend-fixed-chmod777.sh`
- `bb10-max-kit-v2.zip`
- `BUILD-Q20.md`

That gives you the real source, permissive backend installer, and automation helpers in one workflow.
