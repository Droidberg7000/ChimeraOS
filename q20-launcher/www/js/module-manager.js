(function (global) {
  'use strict';

  var STORAGE_KEY = 'chimera.modules.state.v1';

  function loadState() {
    try {
      var raw = global.localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : { installed: [], active: null };
    } catch (e) {
      return { installed: [], active: null };
    }
  }

  function saveState(state) {
    global.localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  }

  function validateModule(moduleMeta) {
    if (!moduleMeta || typeof moduleMeta.id !== 'string') return false;
    if (typeof moduleMeta.name !== 'string') return false;
    if (moduleMeta.scope !== 'app-ui-only') return false;
    return true;
  }

  function installModule(moduleMeta, moduleData) {
    if (!validateModule(moduleMeta)) throw new Error('Invalid module metadata');
    var state = loadState();
    var exists = state.installed.find(function (m) { return m.id === moduleMeta.id; });
    if (exists) {
      exists.version = moduleMeta.version;
      exists.data = moduleData;
    } else {
      state.installed.push({ id: moduleMeta.id, name: moduleMeta.name, version: moduleMeta.version, data: moduleData });
    }
    saveState(state);
    return state;
  }

  function uninstallModule(moduleId) {
    var state = loadState();
    state.installed = state.installed.filter(function (m) { return m.id !== moduleId; });
    if (state.active && state.active.id === moduleId) state.active = null;
    saveState(state);
    return state;
  }

  function activateModule(moduleId) {
    var state = loadState();
    var mod = state.installed.find(function (m) { return m.id === moduleId; });
    if (!mod) throw new Error('Module not found');
    state.active = { id: mod.id, name: mod.name, version: mod.version, data: mod.data };
    saveState(state);
    return state;
  }

  function getActiveModule() {
    return loadState().active || null;
  }

  function getInstalledModules() {
    return loadState().installed.slice();
  }

  global.ChimeraModules = {
    install: installModule,
    uninstall: uninstallModule,
    activate: activateModule,
    getActive: getActiveModule,
    getInstalled: getInstalledModules,
    loadState: loadState,
    saveState: saveState
  };
}(window));
