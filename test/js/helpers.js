'use strict';
// Loads the plugin's JavaScript binding with Cordova's `exec` replaced by a recorder.

const fs = require('node:fs');
const path = require('node:path');

const BINDING = path.resolve(__dirname, '..', '..', 'gameanalytics', 'www', 'GameAnalytics.js');

function loadBinding() {
  const calls = [];
  const windowEvents = [];
  const exec = (success, error, service, action, args) => {
    calls.push({ success, error, service, action, args });
  };
  const cordova = { fireWindowEvent: (name, data) => windowEvents.push({ name, data }) };
  const quiet = { log() {}, warn() {}, error() {} };
  const requireStub = (id) => {
    if (id === 'cordova/exec') return exec;
    throw new Error('binding required an unexpected module: ' + id);
  };
  const module = { exports: {} };
  const source = fs.readFileSync(BINDING, 'utf8');
  new Function('require', 'module', 'exports', 'cordova', 'console', source)(
    requireStub, module, module.exports, cordova, quiet);
  return { GameAnalytics: module.exports, calls, windowEvents };
}

module.exports = { loadBinding, BINDING };
