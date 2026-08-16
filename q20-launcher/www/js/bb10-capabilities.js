(function (global) {
  'use strict';

  var caps = {
    webworks: false,
    blackberryApp: false,
    blackberrySystem: false,
    notifications: false,
    filesystem: false,
    network: !!(global.navigator && global.navigator.onLine)
  };

  function detect() {
    // WebWorks presence
    if (global.blackberry && global.blackberry.app) {
      caps.webworks = true;
      caps.blackberryApp = true;
    }
    if (global.blackberry && global.blackberry.system) {
      caps.blackberrySystem = true;
    }
    // Notifications (best-effort)
    if (global.Notification) {
      caps.notifications = true;
    }
    // Filesystem (best-effort)
    if (global.requestFileSystem || global.webkitRequestFileSystem) {
      caps.filesystem = true;
    }
    return caps;
  }

  function has(feature) {
    return !!caps[feature];
  }

  function report() {
    return JSON.parse(JSON.stringify(caps));
  }

  function degradeIfMissing(feature, fallback) {
    if (!caps[feature] && typeof fallback === 'function') {
      return fallback();
    }
    return null;
  }

  global.ChimeraCaps = {
    detect: detect,
    has: has,
    report: report,
    degradeIfMissing: degradeIfMissing
  };
}(window));
