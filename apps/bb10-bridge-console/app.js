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
        userField: document.getElementById("userField"),
        queryText: document.getElementById("queryText"),
        connectBtn: document.getElementById("connectBtn"),
        sendBtn: document.getElementById("sendBtn"),
        log: document.getElementById("log"),
        statusPill: document.getElementById("statusPill")
    };

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
            user: els.userField.value.trim()
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
        els.userField.value = profile.user || "";
    }

    els.connectBtn.addEventListener("click", testConnection);
    els.sendBtn.addEventListener("click", sendToReasoner);

    restoreProfile();
    log("BB10 Bridge Console ready.");
})();
