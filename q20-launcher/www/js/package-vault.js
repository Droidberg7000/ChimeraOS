(function (global) {
  'use strict';
  var packages = [
    { name: 'ChimeraOS Launcher (Q20)', channel: 'Local build', note: 'This shell is installed as a signed BB10 .bar when release signing is configured.' },
    { name: 'AngieAI services', channel: 'Companion endpoint', note: 'Use only a user-configured local or remote endpoint; do not store service tokens in this app.' },
    { name: 'ChimeraOS workflow bundle', channel: 'Repository artifact', note: 'Generated via scripts/chimeraos_q20_workflow_bundle.sh; contains docs and scaffolding for all three Q20 tracks.' },
    { name: 'JavaBoyChimera', channel: 'Separate sub-project', note: 'Game Boy Color/Java emulator work; not part of this Q20 launcher build.' }
  ];
  function render(container) {
    container.innerHTML = '';
    packages.forEach(function (pkg) {
      var item = document.createElement('article');
      item.className = 'package-item';
      item.innerHTML = '<h3>' + pkg.name + '</h3><p><strong>' + pkg.channel + '</strong><br>' + pkg.note + '</p>';
      container.appendChild(item);
    });
  }
  global.ChimeraVault = { packages: packages, render: render };
}(window));
