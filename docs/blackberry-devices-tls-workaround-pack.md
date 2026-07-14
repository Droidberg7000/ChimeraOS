# BlackBerry Devices TLS Workaround Pack

## Device split

### BB10 devices
Use BB10 with BerryCore/Term49 for shell-based network tasks rather than depending on the old browser for every HTTPS site.

Recommended path:
- Use BerryCore command-line tools for network access where possible.
- Use the Android Termux companion for modern HTTPS-heavy tasks.
- Use SSH bridging, tmux, and wakelock helpers for persistent sessions.
- Treat old browser rendering and certificate support as secondary.

### BlackBerry 9900 / Pearl 8130 and similar legacy BBOS devices
Do not expect a full modern TLS browser fix on these devices.

Recommended path:
- Configure direct internet / APN for third-party apps.
- Use BBSSH for SSH/Telnet tasks where supported.
- Use Opera Mini where workable for web access.
- Use USB AppLoader / JavaLoader / Desktop Software workflows for software loading.
- Use Wi-Fi when available, but expect many modern HTTPS sites to fail due to old TLS/cipher support.

## Practical TLS strategy

### BB10
1. Try the BB10/BerryCore shell path first.
2. If HTTPS/browser access fails, use the Android Termux companion as the modern network endpoint.
3. Keep BB10 focused on SSH, scripting, file movement, and remote control.

### Legacy BBOS
1. Try APN direct internet if the app requires mobile data.
2. Prefer Opera Mini over the built-in browser for practical browsing.
3. Prefer BBSSH over browser-based admin access.
4. Treat archive apps and offline utilities as first-class tools.

## Notes by use case

### For SSH/admin work
- BB10: use BerryCore + bridge scripts.
- 9900/Pearl: use BBSSH if compatible.

### For web browsing
- BB10: limited native browsing; better to bridge modern tasks elsewhere.
- 9900/Pearl: Opera Mini is usually more realistic than the stock browser.

### For downloads and installs
- BB10: use bridge scripts, SSH transfer, and BerryCore tooling.
- 9900/Pearl: use PC-side USB deployment and archived install packages.

## Simple decision chart

- Need modern HTTPS or API access -> use Android Termux companion.
- Need shell/admin access from BBOS legacy device -> use BBSSH.
- Need software loading on 9900/Pearl -> use Desktop Software, AppLoader, or JavaLoader.
- Need persistent command-line work on BB10 -> use tmux + wakelock bridge path.
