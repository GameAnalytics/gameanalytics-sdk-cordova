'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { loadBinding } = require('./helpers');
const surface = require('../data/surface.json');
const expectedEnums = require('../data/enums.expected.json');

const ALL = [...surface.positional, ...surface.noArguments, ...surface.options];
const ENUM_TABLES = Object.keys(expectedEnums).filter((k) => !k.startsWith('_'));

function lastCall(calls) {
  assert.equal(calls.length, 1, 'exactly one exec call per binding call');
  return calls[0];
}

// ---------------------------------------------------------------------------
// Surface
// ---------------------------------------------------------------------------

test('surface: the binding exposes exactly the 30 supported functions, no more and no fewer', () => {
  const { GameAnalytics } = loadBinding();
  const exposed = Object.keys(GameAnalytics)
    .filter((k) => typeof GameAnalytics[k] === 'function' && !k.startsWith('_'))
    .sort();
  assert.equal(ALL.length, 30);
  assert.deepEqual(exposed, [...ALL].sort());
});

test('surface: the binding exposes exactly the six enum tables (EGAValueType is absent)', () => {
  const { GameAnalytics } = loadBinding();
  const tables = Object.keys(GameAnalytics).filter((k) => /^EGA/.test(k)).sort();
  assert.deepEqual(tables, [...ENUM_TABLES].sort());
  assert.equal(GameAnalytics.EGAValueType, undefined);
});

test('surface: the binding module exports the GameAnalytics object (clobbered to the global by plugin.xml)', () => {
  const { GameAnalytics } = loadBinding();
  assert.equal(typeof GameAnalytics, 'object');
});

// ---------------------------------------------------------------------------
// Enums, member for member against the specification
// ---------------------------------------------------------------------------

for (const table of ENUM_TABLES) {
  test(`enums: ${table} matches the specification member for member`, () => {
    const { GameAnalytics } = loadBinding();
    const actual = GameAnalytics[table];
    assert.ok(actual, `${table} must exist`);
    const expected = {};
    for (const m of expectedEnums[table]) expected[m.name] = m.value;
    assert.deepEqual(actual, expected);
  });

  test(`enums: ${table} member names are the specification names, capitalised`, () => {
    const { GameAnalytics } = loadBinding();
    const names = Object.keys(GameAnalytics[table]);
    assert.deepEqual(names.map((n) => n.toLowerCase()).sort(),
      expectedEnums[table].map((m) => m.header).sort());
  });

  test(`enums: ${table} values are integers`, () => {
    const { GameAnalytics } = loadBinding();
    for (const v of Object.values(GameAnalytics[table])) assert.ok(Number.isInteger(v));
  });
}

// ---------------------------------------------------------------------------
// Every function: service, action, callbacks
// ---------------------------------------------------------------------------

const SAMPLE = {
  positional: {
    configureAvailableCustomDimensions01: [['ninja', 'samurai']],
    configureAvailableCustomDimensions02: [['gold', 'silver']],
    configureAvailableCustomDimensions03: [['a', 'b', 'c']],
    configureAvailableResourceCurrencies: [['gems', 'gold']],
    configureAvailableResourceItemTypes: [['boost', 'lives']],
    configureBuild: ['1.2.3'],
    configureAutoDetectAppVersion: [true],
    configureUserId: ['player-42'],
    setEnabledInfoLog: [true],
    setEnabledVerboseLog: [true],
    setEnabledManualSessionHandling: [true],
    setEnabledEventSubmission: [false],
    setCustomDimension01: ['ninja'],
    setCustomDimension02: ['gold'],
    setCustomDimension03: ['c'],
    setGlobalCustomEventFields: ['{"level":3,"mode":"hard"}']
  }
};

for (const name of surface.positional) {
  test(`${name}: reaches exec with the action name and the positional argument first`, () => {
    const { GameAnalytics, calls } = loadBinding();
    const args = SAMPLE.positional[name];
    const onComplete = () => {};
    GameAnalytics[name](...args, onComplete);
    const c = lastCall(calls);
    assert.equal(c.service, 'GameAnalytics');
    assert.equal(c.action, name);
    assert.deepEqual(c.args, args);
    assert.equal(c.success, onComplete, 'onComplete is the success callback');
    assert.equal(typeof c.error, 'function');
  });
}

for (const name of surface.noArguments) {
  test(`${name}: reaches exec with the action name and an empty argument list`, () => {
    const { GameAnalytics, calls } = loadBinding();
    const onComplete = () => {};
    GameAnalytics[name](onComplete);
    const c = lastCall(calls);
    assert.equal(c.service, 'GameAnalytics');
    assert.equal(c.action, name);
    assert.deepEqual(c.args, []);
    assert.equal(c.success, onComplete);
  });
}

for (const name of surface.options) {
  test(`${name}: reaches exec with the action name and the options object as the only argument`, () => {
    const { GameAnalytics, calls } = loadBinding();
    const options = { sentinel: 1 };
    const onComplete = () => {};
    GameAnalytics[name](options, onComplete);
    const c = lastCall(calls);
    assert.equal(c.service, 'GameAnalytics');
    assert.equal(c.action, name);
    assert.equal(c.args.length, 1);
    assert.deepEqual(c.args[0], { sentinel: 1 });
    assert.equal(c.success, onComplete);
  });
}

test('callbacks: the binding never invokes onComplete itself, the native side does, once', () => {
  const { GameAnalytics } = loadBinding();
  let n = 0;
  for (const name of ALL) {
    const args = surface.options.includes(name) ? [{}]
      : surface.positional.includes(name) ? SAMPLE.positional[name] : [];
    GameAnalytics[name](...args, () => { n++; });
  }
  assert.equal(n, 0);
});

test('callbacks: calling without onComplete does not throw', () => {
  const { GameAnalytics, calls } = loadBinding();
  assert.doesNotThrow(() => GameAnalytics.startSession());
  assert.doesNotThrow(() => GameAnalytics.setCustomDimension01('x'));
  assert.equal(calls.length, 2);
  assert.equal(calls[0].success, undefined);
});

test('callbacks: a native failure fires the gameanalyticserror window event with the message', () => {
  const { GameAnalytics, calls, windowEvents } = loadBinding();
  GameAnalytics.startSession(() => {});
  calls[0].error('boom');
  assert.deepEqual(windowEvents, [{ name: 'gameanalyticserror', data: { message: 'boom' } }]);
});

// ---------------------------------------------------------------------------
// Value fidelity for positional functions
// ---------------------------------------------------------------------------

test('configureAutoDetectAppVersion: false crosses the boundary as boolean false, not dropped', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.configureAutoDetectAppVersion(false, () => {});
  assert.deepEqual(lastCall(calls).args, [false]);
});

for (const name of ['setEnabledInfoLog', 'setEnabledVerboseLog', 'setEnabledManualSessionHandling', 'setEnabledEventSubmission']) {
  for (const flag of [true, false]) {
    test(`${name}: ${flag} crosses as a boolean`, () => {
      const { GameAnalytics, calls } = loadBinding();
      GameAnalytics[name](flag, () => {});
      assert.deepEqual(lastCall(calls).args, [flag]);
    });
  }
}

test('setCustomDimension01: empty string crosses as an empty string (clears the dimension)', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.setCustomDimension01('', () => {});
  assert.deepEqual(lastCall(calls).args, ['']);
});

test('setCustomDimension02: unicode and quotes cross unchanged', () => {
  const { GameAnalytics, calls } = loadBinding();
  const value = 'café 日本語 "quoted" \\back\\ 😀';
  GameAnalytics.setCustomDimension02(value, () => {});
  assert.deepEqual(lastCall(calls).args, [value]);
});

test('configureBuild: a very long string crosses unchanged', () => {
  const { GameAnalytics, calls } = loadBinding();
  const value = '1.'.repeat(5000);
  GameAnalytics.configureBuild(value, () => {});
  assert.equal(lastCall(calls).args[0], value);
});

test('configureAvailableCustomDimensions01: an empty array crosses as an empty array', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.configureAvailableCustomDimensions01([], () => {});
  assert.deepEqual(lastCall(calls).args, [[]]);
});

test('configureAvailableResourceCurrencies: the array is passed as one argument, not spread', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.configureAvailableResourceCurrencies(['gems', 'gold'], () => {});
  assert.equal(lastCall(calls).args.length, 1);
  assert.deepEqual(lastCall(calls).args[0], ['gems', 'gold']);
});

test('configureUserId: unicode user id crosses unchanged', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.configureUserId('üser-☃', () => {});
  assert.deepEqual(lastCall(calls).args, ['üser-☃']);
});

test('setGlobalCustomEventFields: the JSON string crosses as a string, byte for byte', () => {
  const { GameAnalytics, calls } = loadBinding();
  const json = '{"name":"caf\\u00e9","quote":"say \\"hi\\"","nested":{"a":[1,2,3]},"emoji":"😀"}';
  GameAnalytics.setGlobalCustomEventFields(json, () => {});
  const sent = lastCall(calls).args[0];
  assert.equal(typeof sent, 'string');
  assert.equal(sent, json);
});

// ---------------------------------------------------------------------------
// Option objects: keys and values cross unchanged
// ---------------------------------------------------------------------------

test('initialize: gameKey and secretKey cross under those exact keys', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.initialize({ gameKey: 'GAME_KEY_PLACEHOLDER', secretKey: 'SECRET_KEY_PLACEHOLDER' }, () => {});
  assert.deepEqual(lastCall(calls).args, [{ gameKey: 'GAME_KEY_PLACEHOLDER', secretKey: 'SECRET_KEY_PLACEHOLDER' }]);
});

test('getRemoteConfigsValueAsString: key and defaultValue cross under those exact keys', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.getRemoteConfigsValueAsString({ key: 'difficulty', defaultValue: 'normal' }, () => {});
  assert.deepEqual(lastCall(calls).args, [{ key: 'difficulty', defaultValue: 'normal' }]);
});

test('getRemoteConfigsValueAsString: without defaultValue the key is absent, not undefined-valued', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.getRemoteConfigsValueAsString({ key: 'difficulty' }, () => {});
  const sent = lastCall(calls).args[0];
  assert.deepEqual(Object.keys(sent), ['key']);
});

test('addBusinessEvent: every documented key crosses with its value', () => {
  const { GameAnalytics, calls } = loadBinding();
  const options = {
    currency: 'USD', amount: 99, itemType: 'IAP', itemId: 'gems_100', cartType: 'shop',
    receipt: 'RECEIPT', signature: 'SIGNATURE', autoFetchReceipt: false,
    customFields: '{"promo":"summer"}', mergeFields: true
  };
  GameAnalytics.addBusinessEvent(options, () => {});
  assert.deepEqual(lastCall(calls).args, [options]);
});

test('addBusinessEvent: autoFetchReceipt true (selects the iOS auto-fetch overload) crosses as a boolean', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.addBusinessEvent({ currency: 'EUR', amount: 5, itemType: 'IAP', itemId: 'x', cartType: 'c', autoFetchReceipt: true }, () => {});
  assert.strictEqual(lastCall(calls).args[0].autoFetchReceipt, true);
});

test('addBusinessEvent: omitting receipt and signature leaves both keys absent', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.addBusinessEvent({ currency: 'USD', amount: 1, itemType: 'a', itemId: 'b', cartType: 'c' }, () => {});
  const sent = lastCall(calls).args[0];
  assert.ok(!('receipt' in sent));
  assert.ok(!('signature' in sent));
});

test('addResourceEvent: flowType is the enum integer and every key crosses', () => {
  const { GameAnalytics, calls } = loadBinding();
  const options = {
    flowType: GameAnalytics.EGAResourceFlowType.Sink, currency: 'gems', amount: 2.5,
    itemType: 'boost', itemId: 'speed', customFields: '{"a":1}', mergeFields: false
  };
  GameAnalytics.addResourceEvent(options, () => {});
  const sent = lastCall(calls).args[0];
  assert.deepEqual(sent, options);
  assert.strictEqual(sent.flowType, 2);
});

test('addProgressionEvent: with score, the score key crosses (selects the with-score native call)', () => {
  const { GameAnalytics, calls } = loadBinding();
  const options = {
    progressionStatus: GameAnalytics.EGAProgressionStatus.Complete,
    progression01: 'world1', progression02: 'level2', progression03: 'boss', score: 1500,
    customFields: '{"k":"v"}', mergeFields: true
  };
  GameAnalytics.addProgressionEvent(options, () => {});
  const sent = lastCall(calls).args[0];
  assert.deepEqual(sent, options);
  assert.strictEqual(sent.progressionStatus, 2);
});

test('addProgressionEvent: without score, no score key crosses (selects the no-score native call)', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.addProgressionEvent({ progressionStatus: 1, progression01: 'w1' }, () => {});
  assert.ok(!('score' in lastCall(calls).args[0]));
});

test('addProgressionEvent: a score of zero is still sent as zero', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.addProgressionEvent({ progressionStatus: 3, progression01: 'w1', score: 0 }, () => {});
  assert.strictEqual(lastCall(calls).args[0].score, 0);
});

test('addProgressionEvent: a negative score crosses unchanged', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.addProgressionEvent({ progressionStatus: 3, progression01: 'w1', score: -50 }, () => {});
  assert.strictEqual(lastCall(calls).args[0].score, -50);
});

test('addDesignEvent: with value, the value key crosses (selects the with-value native call)', () => {
  const { GameAnalytics, calls } = loadBinding();
  const options = { eventId: 'ui:click:play', value: 3.5, customFields: '{"a":true}', mergeFields: true };
  GameAnalytics.addDesignEvent(options, () => {});
  assert.deepEqual(lastCall(calls).args, [options]);
});

test('addDesignEvent: without value, no value key crosses', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.addDesignEvent({ eventId: 'ui:click:play' }, () => {});
  assert.deepEqual(Object.keys(lastCall(calls).args[0]), ['eventId']);
});

test('addDesignEvent: a value of zero is still sent as zero', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.addDesignEvent({ eventId: 'e', value: 0 }, () => {});
  assert.strictEqual(lastCall(calls).args[0].value, 0);
});

test('addDesignEvent: an empty eventId crosses as an empty string', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.addDesignEvent({ eventId: '' }, () => {});
  assert.strictEqual(lastCall(calls).args[0].eventId, '');
});

test('addErrorEvent: severity is the enum integer, message with unicode and escapes crosses unchanged', () => {
  const { GameAnalytics, calls } = loadBinding();
  const message = 'fail: "x" \\ \n é 😀';
  GameAnalytics.addErrorEvent({ severity: GameAnalytics.EGAErrorSeverity.Critical, message, customFields: '{}', mergeFields: false }, () => {});
  const sent = lastCall(calls).args[0];
  assert.strictEqual(sent.severity, 5);
  assert.strictEqual(sent.message, message);
  assert.strictEqual(sent.mergeFields, false);
});

test('addAdEvent: with duration, the duration key crosses (selects the with-duration native call)', () => {
  const { GameAnalytics, calls } = loadBinding();
  const options = {
    adAction: GameAnalytics.EGAAdAction.Show, adType: GameAnalytics.EGAAdType.RewardedVideo,
    adSdkName: 'admob', adPlacement: 'level_end', duration: 30,
    customFields: '{"a":1}', mergeFields: true
  };
  GameAnalytics.addAdEvent(options, () => {});
  const sent = lastCall(calls).args[0];
  assert.deepEqual(sent, options);
  assert.strictEqual(sent.adAction, 2);
  assert.strictEqual(sent.adType, 2);
});

test('addAdEvent: with noAdReason and no duration, only noAdReason crosses (selects the with-reason call)', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.addAdEvent({
    adAction: GameAnalytics.EGAAdAction.FailedShow, adType: GameAnalytics.EGAAdType.Interstitial,
    adSdkName: 'admob', adPlacement: 'p', noAdReason: GameAnalytics.EGAAdError.NoFill
  }, () => {});
  const sent = lastCall(calls).args[0];
  assert.ok(!('duration' in sent));
  assert.strictEqual(sent.noAdReason, 3);
  assert.strictEqual(sent.adAction, 3);
  assert.strictEqual(sent.adType, 4);
});

test('addAdEvent: the newest EGAAdAction members Request and Loaded cross as 5 and 6', () => {
  const { GameAnalytics, calls } = loadBinding();
  GameAnalytics.addAdEvent({ adAction: GameAnalytics.EGAAdAction.Request, adType: 1, adSdkName: 's', adPlacement: 'p' }, () => {});
  GameAnalytics.addAdEvent({ adAction: GameAnalytics.EGAAdAction.Loaded, adType: 1, adSdkName: 's', adPlacement: 'p' }, () => {});
  assert.deepEqual(calls.map((c) => c.args[0].adAction), [5, 6]);
});

// ---------------------------------------------------------------------------
// Custom event fields
// ---------------------------------------------------------------------------

for (const name of ['addBusinessEvent', 'addResourceEvent', 'addProgressionEvent', 'addDesignEvent', 'addErrorEvent', 'addAdEvent']) {
  test(`${name}: customFields crosses as a JSON string, unmodified, and mergeFields as a boolean`, () => {
    const { GameAnalytics, calls } = loadBinding();
    const customFields = '{"s":"caf\\u00e9 \\"q\\"","n":1.5,"b":true,"o":{"x":[1,2]}}';
    for (const mergeFields of [true, false]) {
      GameAnalytics[name]({ customFields, mergeFields }, () => {});
    }
    assert.equal(calls.length, 2);
    for (const [i, mergeFields] of [true, false].entries()) {
      assert.strictEqual(calls[i].args[0].customFields, customFields);
      assert.strictEqual(calls[i].args[0].mergeFields, mergeFields);
    }
  });

  test(`${name}: omitting customFields and mergeFields adds neither key`, () => {
    const { GameAnalytics, calls } = loadBinding();
    GameAnalytics[name]({}, () => {});
    const sent = lastCall(calls).args[0];
    assert.ok(!('customFields' in sent));
    assert.ok(!('mergeFields' in sent));
  });
}

test('custom fields: the options object is passed through without being copied or mutated', () => {
  const { GameAnalytics, calls } = loadBinding();
  const options = { eventId: 'x', customFields: '{"a":1}' };
  const snapshot = JSON.stringify(options);
  GameAnalytics.addDesignEvent(options, () => {});
  assert.equal(JSON.stringify(options), snapshot);
  assert.equal(JSON.stringify(lastCall(calls).args[0]), snapshot);
});
