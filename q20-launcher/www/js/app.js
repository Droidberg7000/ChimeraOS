(function () {
  'use strict';
  var routes = {
    home: { title: 'Home', subtitle: 'ChimeraOS launcher shell for Q20.' },
    vault: { title: 'Package Vault', subtitle: 'Catalogue and integrity-minded package guidance.' },
    diagnostics: { title: 'Diagnostics', subtitle: 'Application-level health and capability report.' },
    about: { title: 'About', subtitle: 'ChimeraOS shell for the BlackBerry Classic Q20.' }
  };

  function byId(id) { return document.getElementById(id); }
  function notify(message) { window.alert(message); }
  function navigate(route) {
    Object.keys(routes).forEach(function (name) {
      byId(name).className = name === route ? 'pane active' : 'pane';
    });
    Array.prototype.forEach.call(document.querySelectorAll('.nav-button'), function (button) {
      button.className = button.getAttribute('data-route') === route ? 'nav-button active' : 'nav-button';
    });
    byId('page-title').textContent = routes[route].title;
    byId('page-subtitle').textContent = routes[route].subtitle;
    if (route === 'diagnostics') window.ChimeraDiagnostics.render(byId('diagnostics-output'));
  }
  function updateClock() { byId('clock').textContent = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }); }
  function start() {
    window.ChimeraTelemetry.render(byId('telemetry'));
    window.ChimeraLauncher.render(byId('launcher-grid'), navigate, notify);
    window.ChimeraVault.render(byId('vault-list'));
    window.ChimeraDiagnostics.render(byId('diagnostics-output'));
    Array.prototype.forEach.call(document.querySelectorAll('.nav-button'), function (button) {
      button.addEventListener('click', function () { navigate(button.getAttribute('data-route')); });
    });
    byId('refresh-diagnostics').addEventListener('click', function () { window.ChimeraDiagnostics.render(byId('diagnostics-output')); });
    byId('export-diagnostics').addEventListener('click', window.ChimeraDiagnostics.exportReport);
    updateClock();
    setInterval(updateClock, 30000);
  }
  document.addEventListener('DOMContentLoaded', start, false);
}());
