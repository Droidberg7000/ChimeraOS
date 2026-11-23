(function (global) {
  'use strict';
  function report() {
    return { generatedAt: new Date().toISOString(), telemetry: global.ChimeraTelemetry.snapshot(),
      limitations: ['No system Home replacement', 'No package installation or flashing', 'No native API success inferred from object presence'] };
  }
  function render(container) {
    var pre = document.createElement('pre');
    pre.textContent = JSON.stringify(report(), null, 2);
    container.innerHTML = '';
    container.appendChild(pre);
  }
  function exportReport() {
    var old = document.getElementById('diagnostics-export'), area;
    if (old) { old.parentNode.removeChild(old); }
    area = document.createElement('textarea');
    area.id = 'diagnostics-export';
    area.readOnly = true;
    area.setAttribute('aria-label', 'Diagnostics JSON; select and copy to export');
    area.value = JSON.stringify(report(), null, 2);
    document.getElementById('diagnostics-output').appendChild(area);
    area.focus();
    area.select();
  }
  global.ChimeraDiagnostics = { report: report, render: render, exportReport: exportReport };
}(window));
