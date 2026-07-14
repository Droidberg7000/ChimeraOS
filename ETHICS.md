# Authorized-Use Policy

ChimeraOS's cyberdeck mission includes a recon/pentest lane
(`services/angieai-pentest`, wired into the BB10 Bridge Console's Recon
panel and the reasoner's routing table). This file is the single place that
states the rule everything else defers to:

**Only scan, probe, or test networks and devices you own or have explicit,
documented permission to test.** Home labs, your own router/IoT gear, your
own Q20/9900, devices on a network you administer — yes. Anyone else's
network, a device you don't own, a public/coffee-shop/employer network
without written authorization, or anything on the public internet — no,
never, regardless of what any tool in this repo will technically let you
attempt.

Technical enforcement in `angieai-pentest`:

- refuses any request without `authorized: true`
- refuses any target outside private/loopback/link-local address space —
  **no override exists for this**, public IPs are always rejected
- caps hosts/ports per request (generously — up to a /20 subnet and the
  full 1-65535 port range — but always bounded, never unlimited)
- audit-logs every scan attempt with timestamp and target
- the Wi-Fi recon lane (`/recon/wifi`, `scripts/wifi_recon_termux.sh`) only
  ever reasons about beacon frames already received passively over the
  air; there is no association, deauth, handshake-capture, or WPS-PIN
  code anywhere in this repo, on purpose — that's active attack tooling
  against other people's radios and is out of scope regardless of intent

These are guardrails, not a substitute for judgment or law. Unauthorized
network scanning/access can violate the U.S. Computer Fraud and Abuse Act
and equivalent laws elsewhere, even for "harmless" reconnaissance. If you
extend this lane (e.g. adding new probe types), preserve or strengthen — 
never weaken — these checks, and keep this file in sync with what the code
actually enforces.
