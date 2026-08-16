(function (global) {
  'use strict';
  var apps = [
    { id: 'chimeraos-home', name: 'ChimeraOS Home', detail: 'Entry point to ChimeraOS services and apps', action: 'Main ChimeraOS services live in the parent repo (services/, apps/, repos/).' },
    { id: 'vault', name: 'Package Vault', detail: 'Local catalogue and update guidance', route: 'vault' },
    { id: 'diagnostics', name: 'Diagnostics', detail: 'Device-safe application health report', route: 'diagnostics' },
    { id: 'about', name: 'About ChimeraOS', detail: 'ChimeraOS shell for the BlackBerry Classic Q20', route: 'about' },
    { id: 'bb10', name: 'BB10 Home', detail: 'Return to stock system home manually', action: 'Stock BB10 system home remains outside application control' },
    { id: 'settings', name: 'Chimera Settings', detail: 'Local launcher preferences', action: 'Settings placeholder' }
  ];

  function render(container, navigate, notify) {
    container.innerHTML = '';
    apps.forEach(function (app) {
      var button = document.createElement('button');
      button.className = 'launch-tile';
      button.setAttribute('data-app', app.id);
      button.innerHTML = '<strong>' + app.name + '</strong><span>' + app.detail + '</span>';
      button.addEventListener('click', function () {
        if (app.route) return navigate(app.route);
        notify(app.name + ': ' + app.action);
      });
      container.appendChild(button);
    });
  }

  global.ChimeraLauncher = { render: render, apps: apps };
}(window));
