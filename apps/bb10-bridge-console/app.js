// BB10 Bridge Console — talks to a Termux-hosted AngieAI instance
// (angieai-reasoner + angieai-onnx from services/) over the LAN.
//
// Connection profile (host/ports/user) persists in localStorage so the
// Q20 doesn't need to be reconfigured on every launch.

(function () {
    "use strict";

    var STORAGE_KEY = "bb10BridgeConsole.profile";

    var els = {
        host: document.getElementById("host"),
        reasonerPort: document.getElementById("reasonerPort"),
        onnxPort: document.getElementById("onnxPort"),
        pentestPort: document.getElementById("pentestPort"),
        userField: document.getElementById("userField"),
        queryText: document.getElementById("queryText"),
        connectBtn: document.getElementById("connectBtn"),
        sendBtn: document.getElementById("sendBtn"),
        log: document.getElementById("log"),
        statusPill: document.getElementById("statusPill"),
        authorizedCheck: document.getElementById("authorizedCheck"),
        subnetField: document.getElementById("subnetField"),
        sweepBtn: document.getElementById("sweepBtn"),
        targetHost: document.getElementById("targetHost"),
        targetPorts: document.getElementById("targetPorts"),
        portScanBtn: document.getElementById("portScanBtn"),
        fullRangeBtn: document.getElementById("fullRangeBtn"),
        analyzeBtn: document.getElementById("analyzeBtn")
    };

    var lastPortScan = null; // { host, open_ports } from the most recent /scan/ports call

    function log(msg) {
        var ts = new Date().toISOString().split("T")[1].split(".")[0];
        els.log.textContent = "[" + ts + "] " + msg + "\n" + els.log.textContent;
    }

    function setOnline(isOnline) {
        els.statusPill.textContent = isOnline ? "ONLINE" : "OFFLINE";
        els.statusPill.className = "status-pill" + (isOnline ? "" : " offline");
    }

    function saveProfile() {
        var profile = {
            host: els.host.value.trim(),
            reasonerPort: els.reasonerPort.value.trim() || "8001",
            onnxPort: els.onnxPort.value.trim() || "8000",
            pentestPort: els.pentestPort.value.trim() || "8002",
            user: els.userField.value.trim(),
            authorized: !!els.authorizedCheck.checked
        };
        try {
            localStorage.setItem(STORAGE_KEY, JSON.stringify(profile));
        } catch (e) { /* localStorage unavailable — ignore, non-fatal */ }
        return profile;
    }

    function loadProfile() {
        try {
            var raw = localStorage.getItem(STORAGE_KEY);
            if (!raw) return null;
            return JSON.parse(raw);
        } catch (e) {
            return null;
        }
    }

    function reasonerUrl(profile, path) {
        return "http://" + profile.host + ":" + profile.reasonerPort + path;
    }

    function onnxUrl(profile, path) {
        return "http://" + profile.host + ":" + profile.onnxPort + path;
    }

    function pentestUrl(profile, path) {
        return "http://" + profile.host + ":" + profile.pentestPort + path;
    }

    function testConnection() {
        var profile = saveProfile();
        if (!profile.host) {
            log("Enter a host/IP first (Termux device running AngieAI).");
            return;
        }
        log("Testing reasoner + onnx health at " + profile.host + " ...");

        var reasonerCheck = fetch(reasonerUrl(profile, "/health"), { method: "GET" })
            .then(function (r) { return r.ok; })
            .catch(function () { return false; });

        var onnxCheck = fetch(onnxUrl(profile, "/health"), { method: "GET" })
            .then(function (r) { return r.ok; })
            .catch(function () { return false; });

        Promise.all([reasonerCheck, onnxCheck]).then(function (results) {
            var reasonerOk = results[0];
            var onnxOk = results[1];
            log("angieai-reasoner: " + (reasonerOk ? "OK" : "unreachable"));
            log("angieai-onnx: " + (onnxOk ? "OK" : "unreachable (falls back to OpenRouter — this is expected/fine)"));
            setOnline(reasonerOk);
        });
    }

    function sendToReasoner() {
        var profile = saveProfile();
        var text = els.queryText.value.trim();
        if (!profile.host) {
            log("Enter a host/IP first.");
            return;
        }
        if (!text) {
            log("Enter a query for AngieAI first.");
            return;
        }

        log("-> " + text);

        fetch(reasonerUrl(profile, "/reason"), {
            method: "POST",
            headers: { "content-type": "application/json" },
            body: JSON.stringify({ text: text })
        })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                log("<- decision: " + data.decision + " | lane: " + data.lane);
                setOnline(true);
            })
            .catch(function (err) {
                log("<- request failed: " + err.message + " (is angieai-reasoner running on that host/port?)");
                setOnline(false);
            });
    }

    function restoreProfile() {
        var profile = loadProfile();
        if (!profile) return;
        els.host.value = profile.host || "";
        els.reasonerPort.value = profile.reasonerPort || "8001";
        els.onnxPort.value = profile.onnxPort || "8000";
        els.pentestPort.value = profile.pentestPort || "8002";
        els.userField.value = profile.user || "";
        els.authorizedCheck.checked = !!profile.authorized;
    }

    // --- Recon panel (angieai-pentest) ---------------------------------
    // Authorized-use-only: the service itself refuses unauthorized/public
    // targets too. The checkbox state now persists in the saved profile so
    // you don't have to re-check it every launch — uncheck it any time you
    // stop being sure the target is yours to test.

    function requireAuthorized() {
        if (!els.authorizedCheck.checked) {
            log("Check \"I own or have permission to test this network/device\" first.");
            return false;
        }
        return true;
    }

    function sweepSubnet() {
        var profile = saveProfile();
        var subnet = els.subnetField.value.trim();
        if (!profile.host) { log("Enter a host/IP first."); return; }
        if (!subnet) { log("Enter a subnet, e.g. 192.168.1.0/24."); return; }
        if (!requireAuthorized()) return;

        log("-> recon: sweeping " + subnet + " ...");
        fetch(pentestUrl(profile, "/scan/hosts"), {
            method: "POST",
            headers: { "content-type": "application/json" },
            body: JSON.stringify({ subnet: subnet, authorized: true, timeout_ms: 300 })
        })
            .then(function (r) { return r.json().then(function (data) { return { ok: r.ok, data: data }; }); })
            .then(function (res) {
                if (!res.ok) {
                    log("<- recon rejected: " + (res.data.detail || JSON.stringify(res.data)));
                    return;
                }
                var alive = res.data.alive_hosts || [];
                log("<- " + alive.length + "/" + res.data.hosts_checked + " hosts alive in " + res.data.elapsed_ms + "ms");
                alive.forEach(function (h) { log("   alive: " + h); });
                setOnline(true);
            })
            .catch(function (err) {
                log("<- recon request failed: " + err.message + " (is angieai-pentest running on that host/port?)");
                setOnline(false);
            });
    }

    function scanPorts() {
        var profile = saveProfile();
        var host = els.targetHost.value.trim();
        var portsRaw = els.targetPorts.value.trim();
        if (!host) { log("Enter a target host/IP first."); return; }
        if (!requireAuthorized()) return;

        var body = { host: host, authorized: true, grab_banners: true };
        if (portsRaw) {
            body.ports = portsRaw.split(",").map(function (p) { return parseInt(p.trim(), 10); }).filter(function (p) { return !isNaN(p); });
        }

        log("-> recon: scanning ports on " + host + " ...");
        fetch(pentestUrl(profile, "/scan/ports"), {
            method: "POST",
            headers: { "content-type": "application/json" },
            body: JSON.stringify(body)
        })
            .then(function (r) { return r.json().then(function (data) { return { ok: r.ok, data: data }; }); })
            .then(function (res) {
                if (!res.ok) {
                    log("<- recon rejected: " + (res.data.detail || JSON.stringify(res.data)));
                    return;
                }
                var open = res.data.open_ports || [];
                log("<- " + open.length + "/" + res.data.ports_checked + " ports open on " + host + " in " + res.data.elapsed_ms + "ms");
                open.forEach(function (p) {
                    log("   open: " + p.port + (p.service_guess ? " (" + p.service_guess + ")" : "") + (p.banner ? " — " + p.banner : ""));
                });
                lastPortScan = { host: host, open_ports: open };
                setOnline(true);
            })
            .catch(function (err) {
                log("<- recon request failed: " + err.message + " (is angieai-pentest running on that host/port?)");
                setOnline(false);
            });
    }

    function useFullRange() {
        var ports = [];
        for (var p = 1; p <= 65535; p++) ports.push(p);
        els.targetPorts.value = ports.join(",");
        log("Loaded full 1-65535 port range into the Ports field (this scan will take a while).");
    }

    function analyzeLastScan() {
        var profile = saveProfile();
        if (!lastPortScan || !lastPortScan.open_ports.length) {
            log("Run a port scan with at least one open port first.");
            return;
        }
        log("-> analyzing " + lastPortScan.open_ports.length + " open port(s) on " + lastPortScan.host + " ...");
        fetch(pentestUrl(profile, "/analyze/ports"), {
            method: "POST",
            headers: { "content-type": "application/json" },
            body: JSON.stringify({ host: lastPortScan.host, open_ports: lastPortScan.open_ports })
        })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                var findings = data.findings || [];
                if (!findings.length) {
                    log("<- no heuristic findings (this is not a guarantee of safety — just nothing matched).");
                    return;
                }
                findings.forEach(function (f) {
                    log("   [" + f.severity.toUpperCase() + "] port " + f.port + ": " + f.title);
                });
                log("<- " + data.note);
            })
            .catch(function (err) {
                log("<- analyze request failed: " + err.message);
            });
    }

    els.connectBtn.addEventListener("click", testConnection);
    els.sendBtn.addEventListener("click", sendToReasoner);
    els.sweepBtn.addEventListener("click", sweepSubnet);
    els.portScanBtn.addEventListener("click", scanPorts);
    els.fullRangeBtn.addEventListener("click", useFullRange);
    els.analyzeBtn.addEventListener("click", analyzeLastScan);

    restoreProfile();
    log("BB10 Bridge Console ready.");
})();
