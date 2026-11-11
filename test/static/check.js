#!/usr/bin/env node
'use strict';
// Static, cross-layer checks that need no device and no native SDK:
//   1. action parity across the JS binding, the Android bridge and the iOS bridge
//   2. one callback result on every path of both bridges
//   3. enum parity with the specification (test/data/enums.expected.json)
//   4. one plugin version in every file that hardcodes it
//   5. pinned native SDK coordinates and engines
//   6. the published plugin directory holds only plugin files
//   7. the sample calls only functions the binding exposes
// Exits non-zero and lists every problem when anything is off.

const fs = require('node:fs');
const path = require('node:path');
const { loadBinding } = require('../js/helpers');
const surface = require('../data/surface.json');
const expectedEnums = require('../data/enums.expected.json');

const root = path.resolve(__dirname, '..', '..');
const plugin = path.join(root, 'gameanalytics');
const read = (...p) => fs.readFileSync(path.join(root, ...p), 'utf8');

const problems = [];
const fail = (msg) => problems.push(msg);
let checks = 0;
const ok = (cond, msg) => { checks++; if (!cond) fail(msg); };

const sorted = (s) => [...s].sort();
function diff(label, a, b, nameA, nameB) {
  const A = new Set(a), B = new Set(b);
  const onlyA = sorted([...A].filter((x) => !B.has(x)));
  const onlyB = sorted([...B].filter((x) => !A.has(x)));
  ok(onlyA.length === 0 && onlyB.length === 0,
    `${label}: only in ${nameA}: [${onlyA}]; only in ${nameB}: [${onlyB}]`);
}

/** Returns the text between the brace that opens at `open` and its match, ignoring braces in strings and comments. */
function braceBody(src, open) {
  let depth = 0;
  for (let i = open; i < src.length; i++) {
    const c = src[i];
    if (c === '"' || c === "'") { // skip a string or char literal
      const q = c; i++;
      while (i < src.length && src[i] !== q) { if (src[i] === '\\') i++; i++; }
      continue;
    }
    if (c === '/' && src[i + 1] === '/') { while (i < src.length && src[i] !== '\n') i++; continue; }
    if (c === '/' && src[i + 1] === '*') { i = src.indexOf('*/', i + 2); if (i < 0) break; i++; continue; }
    if (c === '{') depth++;
    if (c === '}') { depth--; if (depth === 0) return src.slice(open + 1, i); }
  }
  throw new Error('unbalanced braces');
}

// ---- sources -----------------------------------------------------------------
const jsSrc = read('gameanalytics', 'www', 'GameAnalytics.js');
const javaSrc = read('gameanalytics', 'src', 'android', 'GameAnalyticsCordova.java');
const hSrc = read('gameanalytics', 'src', 'ios', 'GameAnalyticsCordova.h');
const mSrc = read('gameanalytics', 'src', 'ios', 'GameAnalyticsCordova.m');

const specActions = [...surface.positional, ...surface.noArguments, ...surface.options];

// ---- 1. action parity ----------------------------------------------------------
const jsActions = [...jsSrc.matchAll(/exec\([^;]*?PLUGIN_NAME,\s*'(\w+)'/g)].map((m) => m[1]);
const jsFunctions = [...jsSrc.matchAll(/^GameAnalytics\.(\w+)\s*=\s*function/gm)].map((m) => m[1]).filter((n) => !n.startsWith('_'));
const javaActions = [...javaSrc.matchAll(/action\.equals\("(\w+)"\)/g)].map((m) => m[1]);
const hActions = [...hSrc.matchAll(/^-\s*\(void\)\s*(\w+)\s*:\s*\(CDVInvokedUrlCommand\s*\*\s*\)\s*\w+\s*;/gm)].map((m) => m[1]);
const mActions = [...mSrc.matchAll(/^-\s*\(void\)\s*(\w+)\s*:\s*\(CDVInvokedUrlCommand\s*\*\s*\)\s*\w+\s*\{?/gm)].map((m) => m[1]);

ok(new Set(jsActions).size === jsActions.length, 'JS binding sends the same action from two functions');
ok(new Set(javaActions).size === javaActions.length, 'Android bridge has two handlers for one action');
ok(new Set(mActions).size === mActions.length, 'iOS bridge implements one action twice');
diff('JS function names vs the action each one sends', jsFunctions, jsActions, 'function names', 'action strings');
diff('JS binding vs supported surface', jsActions, specActions, 'JS binding', 'surface');
diff('Android bridge vs JS binding', javaActions, jsActions, 'Android', 'JS');
diff('iOS .h vs JS binding', hActions, jsActions, 'iOS .h', 'JS');
diff('iOS .m vs JS binding', mActions, jsActions, 'iOS .m', 'JS');
ok(specActions.length === 30, 'surface.json must list 30 functions');

// ---- 2. one callback result on every path -----------------------------------------
{
  const execAt = javaSrc.indexOf('public boolean execute(');
  const execBody = braceBody(javaSrc, javaSrc.indexOf('{', execAt));
  const branches = [...execBody.matchAll(/action\.equals\("(\w+)"\)\s*\)\s*\{/g)];
  ok(branches.length === javaActions.length, `Android: found ${branches.length} branches for ${javaActions.length} actions`);
  for (const m of branches) {
    const body = braceBody(execBody, m.index + m[0].length - 1);
    const completions = (body.match(/callbackContext\.(success|error)\s*\(|callbackContext\.sendPluginResult\s*\(/g) || []).length;
    ok(completions === 1, `Android ${m[1]}: ${completions} callback completions (expected exactly 1)`);
    ok((body.match(/return true;/g) || []).length === 1, `Android ${m[1]}: must end with one 'return true;'`);
    ok(!/return false;/.test(body), `Android ${m[1]}: must not return false after handling`);
    ok((body.match(/\breturn\b/g) || []).length === 1, `Android ${m[1]}: only the final 'return true;' is allowed in a branch`);
  }
  ok(/return false;\s*$/.test(execBody.trimEnd()), "Android execute() must end with 'return false;' for unknown actions");
}
{
  for (const name of mActions) {
    const start = mSrc.search(new RegExp(`^-\\s*\\(void\\)\\s*${name}\\s*:`, 'm'));
    const body = braceBody(mSrc, mSrc.indexOf('{', start));
    const completions = (body.match(/sendPluginResult:/g) || []).length;
    ok(completions === 1, `iOS ${name}: ${completions} sendPluginResult calls (expected exactly 1)`);
    ok(!/\breturn\s*;/.test(body), `iOS ${name}: early 'return;' could skip the callback`);
    ok(/sendPluginResult:[^;]*callbackId:command\.callbackId\]/.test(body), `iOS ${name}: result must be sent to command.callbackId`);
    ok(/CDVCommandStatus_OK/.test(body), `iOS ${name}: expected an OK result`);
  }
}

// ---- 3. enum parity ----------------------------------------------------------------
{
  const { GameAnalytics } = loadBinding();
  const tables = Object.keys(GameAnalytics).filter((k) => /^EGA/.test(k));
  const expectedTables = Object.keys(expectedEnums).filter((k) => !k.startsWith('_'));
  diff('enum tables', tables, expectedTables, 'binding', 'specification');
  for (const t of expectedTables) {
    const want = {};
    for (const m of expectedEnums[t]) want[m.name] = m.value;
    const got = GameAnalytics[t] || {};
    diff(`${t} members`, Object.keys(got), Object.keys(want), 'binding', 'specification');
    for (const [k, v] of Object.entries(want)) ok(got[k] === v, `${t}.${k}: expected ${v}, binding has ${got[k]}`);
  }
}

// ---- 4. one plugin version everywhere -------------------------------------------------
{
  const versions = {};
  versions['gameanalytics/package.json'] = JSON.parse(read('gameanalytics', 'package.json')).version;
  versions['gameanalytics/plugin.xml'] = (read('gameanalytics', 'plugin.xml').match(/<plugin\b[^>]*\sversion="([^"]+)"/) || [])[1];
  versions['GameAnalyticsCordova.java VERSION'] = (javaSrc.match(/String\s+VERSION\s*=\s*"([^"]+)"/) || [])[1];
  versions['GameAnalyticsCordova.m VERSION'] = (mSrc.match(/#define\s+VERSION\s+@"([^"]+)"/) || [])[1];
  const readme = read('README.md');
  const top = readme.split('<!--(CHANGELOG_TOP)-->')[1];
  versions['README.md newest changelog entry'] = top && (top.match(/\*\*(\d+\.\d+\.\d+[^*]*)\*\*/) || [])[1];
  const unique = new Set(Object.values(versions));
  ok(!Object.values(versions).includes(undefined) && unique.size === 1,
    'plugin version differs between files: ' + JSON.stringify(versions));
}

// ---- 5. pinned native SDKs and engines -----------------------------------------------------
{
  const gradle = read('gameanalytics', 'src', 'android', 'build.gradle');
  const xml = read('gameanalytics', 'plugin.xml');
  ok(gradle.includes(`"${surface.pinned.androidSdk}"`), `build.gradle must depend on ${surface.pinned.androidSdk}`);
  ok(gradle.includes(surface.pinned.androidRepository), `build.gradle must add the ${surface.pinned.androidRepository} repository`);
  ok(new RegExp(`<pod\\s+name="${surface.pinned.iosPod}"\\s+spec="${surface.pinned.iosPodSpec.replace(/[~>.]/g, '\\$&')}"`).test(xml),
    `plugin.xml must pin pod ${surface.pinned.iosPod} ${surface.pinned.iosPodSpec}`);
  for (const [engine, range] of Object.entries(surface.pinned.engines)) {
    ok(new RegExp(`<engine\\s+name="${engine}"\\s+version="${range}"`).test(xml), `plugin.xml engine ${engine} must be ${range}`);
  }
  ok(/<js-module[^>]*src="www\/GameAnalytics\.js"/.test(xml) && /<clobbers\s+target="GameAnalytics"/.test(xml),
    'plugin.xml must expose www/GameAnalytics.js as the global GameAnalytics');
  ok(/android-package"\s+value="com\.gameanalytics\.sdk\.cordova\.GameAnalyticsCordova"/.test(xml) &&
    /^package com\.gameanalytics\.sdk\.cordova;/m.test(javaSrc), 'Android package in plugin.xml must match the Java source');
  ok(/ios-package"\s+value="GameAnalyticsCordova"/.test(xml), 'iOS class in plugin.xml must be GameAnalyticsCordova');
  for (const f of ['src/android/GameAnalyticsCordova.java', 'src/android/build.gradle', 'src/ios/GameAnalyticsCordova.h', 'src/ios/GameAnalyticsCordova.m', 'www/GameAnalytics.js']) {
    ok(xml.includes(`src="${f}"`), `plugin.xml does not reference ${f}`);
  }
}

// ---- 6. nothing but the plugin ships --------------------------------------------------------
{
  const allowed = [
    'package.json', 'plugin.xml', 'www/GameAnalytics.js',
    'src/android/GameAnalyticsCordova.java', 'src/android/build.gradle',
    'src/ios/GameAnalyticsCordova.h', 'src/ios/GameAnalyticsCordova.m'
  ];
  const found = [];
  (function walk(dir) {
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      const p = path.join(dir, e.name);
      if (e.isDirectory()) walk(p); else found.push(path.relative(plugin, p).split(path.sep).join('/'));
    }
  })(plugin);
  diff('files under gameanalytics/ (these are what npm publishes)', found, allowed, 'directory', 'expected plugin files');
  const pkg = JSON.parse(read('gameanalytics', 'package.json'));
  ok(!pkg.devDependencies && !pkg.scripts && !pkg.files, 'gameanalytics/package.json must not carry test dependencies or scripts');
}

// ---- 7. the sample only uses what exists --------------------------------------------------------
{
  const { GameAnalytics } = loadBinding();
  const sample = read('www', 'js', 'index.js');
  const used = new Set([...sample.matchAll(/\bGameAnalytics\.(\w+)/g)].map((m) => m[1]));
  for (const name of used) ok(name in GameAnalytics, `sample uses GameAnalytics.${name}, which the binding does not expose`);
}

if (problems.length) {
  console.error(`static checks: ${problems.length} problem(s) in ${checks} checks`);
  for (const p of problems) console.error('  - ' + p);
  process.exit(1);
}
console.log(`static checks: ${checks} checks passed`);
