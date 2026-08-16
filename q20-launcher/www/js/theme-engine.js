(function (global) {
  'use strict';

  var defaults = {
    colors: {
      background: '#0b0f14',
      surface: '#14232c',
      text: '#e9f2f5',
      muted: '#9caeba',
      accent: '#1f7285',
      accentText: '#ffffff'
    },
    spacing: { panePadding: 18, gridGap: 10, cardPadding: 12 },
    typography: { fontFamily: 'Arial, Helvetica, sans-serif', fontSizeBase: 13, fontSizeLarge: 18, fontSizeXLarge: 32 }
  };

  function setVar(name, value) {
    document.documentElement.style.setProperty(name, value);
  }

  function apply(theme) {
    theme = theme || defaults;
    var colors = theme.colors || defaults.colors;
    var spacing = theme.spacing || defaults.spacing;
    var typography = theme.typography || defaults.typography;

    setVar('--chimera-bg', colors.background || defaults.colors.background);
    setVar('--chimera-surface', colors.surface || defaults.colors.surface);
    setVar('--chimera-text', colors.text || defaults.colors.text);
    setVar('--chimera-muted', colors.muted || defaults.colors.muted);
    setVar('--chimera-accent', colors.accent || defaults.colors.accent);
    setVar('--chimera-accent-text', colors.accentText || defaults.colors.accentText);
    setVar('--chimera-pane-padding', (spacing.panePadding || defaults.spacing.panePadding) + 'px');
    setVar('--chimera-grid-gap', (spacing.gridGap || defaults.spacing.gridGap) + 'px');
    setVar('--chimera-card-padding', (spacing.cardPadding || defaults.spacing.cardPadding) + 'px');
    setVar('--chimera-font', typography.fontFamily || defaults.typography.fontFamily);
    setVar('--chimera-font-base', (typography.fontSizeBase || defaults.typography.fontSizeBase) + 'px');
    setVar('--chimera-font-large', (typography.fontSizeLarge || defaults.typography.fontSizeLarge) + 'px');
    setVar('--chimera-font-xlarge', (typography.fontSizeXLarge || defaults.typography.fontSizeXLarge) + 'px');
  }

  function applyActiveModule() {
    var active = global.ChimeraModules && global.ChimeraModules.getActive ? global.ChimeraModules.getActive() : null;
    apply(active && active.data ? active.data : defaults);
    return active;
  }

  global.ChimeraTheme = { defaults: defaults, apply: apply, applyActiveModule: applyActiveModule };
}(window));
