# BB10 Bridge Console (Q20 app source)

This is the actual, working WebWorks app source described in
`docs/BUILD-Q20.md` — the earlier zip scaffold referenced there had been
lost between sessions, so this is a regenerated, verified version:

- `config.xml` — validated well-formed, sets `com.user.bb10bridgeconsole`,
  version `1.0.0.1`, internet permission, portrait/swipe nav for the
  Classic/Q20 square display.
- `index.html` / `style.css` / `app.js` — a real (not placeholder) UI:
  a connection-profile form (host + `angieai-reasoner`/`angieai-onnx`
  ports + optional user), a "Test Connection" button that hits `/health`
  on both services, and "Send to Reasoner" which POSTs to `/reason` and
  logs the routing decision. Profile persists in `localStorage`.
- `assets/` — icons (86/114/128px) and a 1280x768 splash, generated from
  the ChimeraOS skull-berry logo art.
- `bb10-bridge-console-q20-source.zip` — pre-built source zip, contents
  flattened at the zip root (not nested in a subfolder) exactly as
  `bbwp` expects.

## Build the .bar

Once you have BBNDK + the WebWorks SDK `dependencies/` copied into
`../../repos/BB10-Webworks-Packager/` (see `../../repos/REPOS.md`):

```bash
source /path/to/bbndk/bbndk-env.sh
cd ../../repos/BB10-Webworks-Packager
./bbwp /path/to/apps/bb10-bridge-console/bb10-bridge-console-q20-source.zip -o build-output
find build-output -name '*.bar'
```

Then install to the Q20 in Development Mode:

```bash
blackberry-deploy -installApp -package build-output/<APPNAME>.bar -device <Q20-IP> -password <DEV-PASSWORD>
```

## Regenerating icons/splash

If you swap the branding art, regenerate the sized assets with:

```bash
python3 - <<'PY'
from PIL import Image
im = Image.open("/path/to/new-logo.png").convert("RGBA")
for size in (86, 114, 128):
    im.resize((size, size), Image.LANCZOS).save(f"assets/icon-{size}.png")
splash = Image.new("RGBA", (1280, 768), (0, 0, 0, 255))
logo = im.resize((640, 640), Image.LANCZOS)
splash.paste(logo, ((1280 - 640) // 2, (768 - 640) // 2), logo)
splash.convert("RGB").save("assets/splash-1280x768.png")
PY
```

Then re-zip with `zip -r bb10-bridge-console-q20-source.zip config.xml index.html style.css app.js assets/`.
