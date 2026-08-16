(function (global) {
  'use strict';

  var navHandlers = [];
  var keyMap = {
    'ArrowUp': 'up',
    'ArrowDown': 'down',
    'ArrowLeft': 'left',
    'ArrowRight': 'right',
    'Enter': 'enter',
    ' ': 'space',
    'Escape': 'back'
  };

  function addNavHandler(fn) {
    navHandlers.push(fn);
  }

  function notifyNav(action, detail) {
    navHandlers.forEach(function (fn) { try { fn(action, detail); } catch (e) {} });
  }

  function onKey(e) {
    var action = keyMap[e.key];
    if (!action) return;
    e.preventDefault();
    notifyNav(action, { key: e.key, shift: e.shiftKey, ctrl: e.ctrlKey, alt: e.altKey });
  }

  function onPointer(e) {
    // Simple pointer/touch navigation helper
    if (e.type === 'click') {
      notifyNav('tap', { target: e.target });
    }
  }

  function start() {
    global.addEventListener('keydown', onKey, true);
    global.addEventListener('click', onPointer, true);
  }

  function stop() {
    global.removeEventListener('keydown', onKey, true);
    global.removeEventListener('click', onPointer, true);
  }

  global.ChimeraInput = {
    start: start,
    stop: stop,
    onNav: addNavHandler
  };
}(window));
