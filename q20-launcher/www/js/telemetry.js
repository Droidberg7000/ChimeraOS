(function (global) {
  'use strict';
  function snapshot() {
    return {
      scope: 'Application/browser only; not privileged device telemetry',
      userAgent: navigator.userAgent,
      language: navigator.language || 'unknown',
      viewport: String(global.innerWidth) + ' x ' + String(global.innerHeight),
      networkHint: typeof navigator.onLine === 'boolean' ? (navigator.onLine ? 'Online hint; connectivity unverified' : 'Offline hint') : 'Unavailable',
      nativeBridge: global.blackberry ? 'Object present; APIs and permissions unverified' : 'Not detected'
    };
  }
  function render(container) {
    var data = snapshot(), key, item;
    container.innerHTML = '';
    for (key in data) {
      if (Object.prototype.hasOwnProperty.call(data, key)) {
        item = document.createElement('div');
        item.className = 'telemetry-item';
        item.textContent = key + ': ' + data[key];
        container.appendChild(item);
      }
    }
  }
  global.ChimeraTelemetry = { snapshot: snapshot, render: render };
}(window));
