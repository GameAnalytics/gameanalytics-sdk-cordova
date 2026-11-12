[![npm](https://img.shields.io/npm/v/cordova-plugin-gameanalytics.svg)](https://www.npmjs.com/package/cordova-plugin-gameanalytics)
[![npm](https://img.shields.io/npm/dt/cordova-plugin-gameanalytics.svg?label=npm%20downloads)](https://www.npmjs.com/package/cordova-plugin-gameanalytics)
[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

# cordova-plugin-gameanalytics

Official Cordova plugin for the GameAnalytics SDK, for Android and iOS.

Native libraries used by the plugin:

| Platform | Library | Version |
|----------|---------|---------|
| Android | `com.gameanalytics.sdk:gameanalytics-android` (GameAnalytics Maven repository) | 7.2.1 |
| iOS | CocoaPod `GA-SDK-IOS` | `~> 5.0.2` |

## Requirements

* cordova-android 11 or higher
* cordova-ios 8 or higher
* iOS: [CocoaPods](https://cocoapods.org), and a deployment target of 12.0 or higher
* Android: `minSdkVersion` 21 or higher

The native SDKs need iOS 12.0 and Android API 21. The plugin cannot set these for you, so check your app's `config.xml`. A build fails if it sets a lower value:

```xml
<platform name="ios">
    <preference name="deployment-target" value="12.0" />
</platform>
<platform name="android">
    <preference name="android-minSdkVersion" value="21" />
</platform>
```

## Installation

From your app's root folder:

```
cordova plugin add cordova-plugin-gameanalytics
```

## Quick start

The plugin adds a global `GameAnalytics` object. Wait for `deviceready`, then configure, initialize and send events:

```js
document.addEventListener("deviceready", function () {
    GameAnalytics.setEnabledInfoLog(true);
    GameAnalytics.configureBuild("1.0.0");

    GameAnalytics.initialize({
        gameKey: "your_game_key",
        secretKey: "your_secret_key"
    });

    GameAnalytics.addDesignEvent({ eventId: "game:started" });
});
```

Turn info logging off before you release. For a full end-to-end example that calls every function, see the sample app in [`www/js/index.js`](www/js/index.js). Every line it prints starts with `GATEST:`.

## How the API works

The plugin exposes 30 functions on `GameAnalytics`. Each one takes an optional trailing `onComplete` callback, called on both iOS and Android once the call has been handled. Functions that return a value pass it to `onComplete`.

```js
GameAnalytics.isRemoteConfigsReady(function (ready) {
    console.log("ready: " + ready);
});
```

There are two calling styles:

* `configure*` and `set*` functions, `startSession` and `endSession` take positional arguments.
* `initialize`, the `add*Event` functions and `getRemoteConfigsValueAsString` take a single options object.

### Configuration

Call these before `initialize`.

```js
GameAnalytics.configureBuild("1.0.0");                         // [major].[minor].[patch]
GameAnalytics.configureAutoDetectAppVersion(true);             // use the app version as the build
GameAnalytics.configureUserId("my_custom_user_id");
GameAnalytics.configureAvailableResourceCurrencies(["gems", "gold"]);
GameAnalytics.configureAvailableResourceItemTypes(["boost", "lives"]);
GameAnalytics.configureAvailableCustomDimensions01(["ninja", "samurai"]);
GameAnalytics.configureAvailableCustomDimensions02(["whale", "dolphin"]);
GameAnalytics.configureAvailableCustomDimensions03(["horde", "alliance"]);
```

Resource events are only accepted for currencies and item types you configured here.

Set the active custom dimension values after configuring the lists and before `initialize`:

```js
GameAnalytics.setCustomDimension01("ninja");
GameAnalytics.setCustomDimension02("dolphin");
GameAnalytics.setCustomDimension03("alliance");
```

Global custom event fields are added to the events the SDK sends. Pass a JSON string:

```js
GameAnalytics.setGlobalCustomEventFields(JSON.stringify({ level_type: "tutorial" }));
```

### Privacy, sessions and logging

```js
GameAnalytics.setEnabledEventSubmission(false);       // stop sending events
GameAnalytics.setEnabledManualSessionHandling(true);  // then call startSession and endSession yourself
GameAnalytics.startSession();
GameAnalytics.endSession();
GameAnalytics.setEnabledInfoLog(true);                // short messages, for development
GameAnalytics.setEnabledVerboseLog(true);             // more detailed output
```

### Initialize

```js
GameAnalytics.initialize({
    gameKey: "your_game_key",
    secretKey: "your_secret_key"
});
```

### Event options shared by all `add*Event` functions

Every `add*Event` options object accepts two optional fields:

| Field | Type | Description |
|-------|------|-------------|
| `customFields` | string | Custom event fields as a JSON string |
| `mergeFields` | boolean | `true` merges `customFields` with the global custom fields instead of replacing them. Default `false` |

```js
GameAnalytics.addDesignEvent({
    eventId: "design:event",
    customFields: JSON.stringify({ difficulty: "hard" }),
    mergeFields: true
});
```

### Business events

| Field | Type | Description |
|-------|------|-------------|
| `currency` | string | ISO 4217 code, for example `USD` |
| `amount` | integer | Amount in cents |
| `itemType` | string | Type or category of the item |
| `itemId` | string | The specific item |
| `cartType` | string | Where in the game the purchase happened |
| `receipt` | string | The purchase receipt |
| `signature` | string | Android only: the Google Play signature |
| `autoFetchReceipt` | boolean | iOS only: let the SDK fetch the receipt itself |

```js
GameAnalytics.addBusinessEvent({
    currency: "USD", amount: 99, itemType: "GoldPacks", itemId: "1000GoldPack", cartType: "EndOfLevel"
});
```

On Android, passing both `receipt` and `signature` sends the event for Google Play validation. On iOS, `autoFetchReceipt: true` fetches the receipt automatically; otherwise `receipt` is used.

### Resource events

| Field | Type | Description |
|-------|------|-------------|
| `flowType` | `EGAResourceFlowType` | `Source` or `Sink` |
| `currency` | string | One of the configured currencies |
| `amount` | number | Amount sourced or sunk |
| `itemType` | string | One of the configured item types |
| `itemId` | string | Name of the item |

```js
GameAnalytics.addResourceEvent({
    flowType: GameAnalytics.EGAResourceFlowType.Source,
    currency: "gems", amount: 50, itemType: "boost", itemId: "dailyReward"
});
```

### Progression events

| Field | Type | Description |
|-------|------|-------------|
| `progressionStatus` | `EGAProgressionStatus` | `Start`, `Complete` or `Fail` |
| `progression01` | string | First progression level |
| `progression02` | string | Optional second level |
| `progression03` | string | Optional third level |
| `score` | integer | Optional score. Only sent when the field is present |

```js
GameAnalytics.addProgressionEvent({
    progressionStatus: GameAnalytics.EGAProgressionStatus.Complete,
    progression01: "world1", progression02: "level1", score: 100
});
```

### Design events

| Field | Type | Description |
|-------|------|-------------|
| `eventId` | string | Event id. Up to five parts separated by colons |
| `value` | number | Optional value. Only sent when the field is present |

```js
GameAnalytics.addDesignEvent({ eventId: "design:event", value: 10 });
```

### Error events

| Field | Type | Description |
|-------|------|-------------|
| `severity` | `EGAErrorSeverity` | `Debug`, `Info`, `Warning`, `Error` or `Critical` |
| `message` | string | Error message |

```js
GameAnalytics.addErrorEvent({
    severity: GameAnalytics.EGAErrorSeverity.Warning, message: "Something odd happened"
});
```

### Ad events

| Field | Type | Description |
|-------|------|-------------|
| `adAction` | `EGAAdAction` | What happened |
| `adType` | `EGAAdType` | The kind of ad |
| `adSdkName` | string | Name of the ad SDK |
| `adPlacement` | string | Placement id |
| `duration` | integer | Optional. How long the ad was shown, in milliseconds |
| `noAdReason` | `EGAAdError` | Optional. Why no ad was shown. Used when `duration` is absent |

```js
GameAnalytics.addAdEvent({
    adAction: GameAnalytics.EGAAdAction.RewardReceived,
    adType: GameAnalytics.EGAAdType.RewardedVideo,
    adSdkName: "admob", adPlacement: "double_reward", duration: 5000
});
```

### Enums

Enum values are numbers, used as `GameAnalytics.<Enum>.<Member>`.

| Enum | Members |
|------|---------|
| `EGAErrorSeverity` | `Undefined`, `Debug`, `Info`, `Warning`, `Error`, `Critical` |
| `EGAResourceFlowType` | `Undefined`, `Source`, `Sink` |
| `EGAProgressionStatus` | `Undefined`, `Start`, `Complete`, `Fail` |
| `EGAAdAction` | `Undefined`, `Clicked`, `Show`, `FailedShow`, `RewardReceived`, `Request`, `Loaded` |
| `EGAAdError` | `Undefined`, `Unknown`, `Offline`, `NoFill`, `InternalError`, `InvalidRequest`, `UnableToPrecache` |
| `EGAAdType` | `Undefined`, `Video`, `RewardedVideo`, `Playable`, `Interstitial`, `OfferWall`, `Banner` |

### Remote configs and A/B testing

Remote configs are only available once the server has sent them. Poll `isRemoteConfigsReady` until it returns `true`:

```js
GameAnalytics.isRemoteConfigsReady(function (ready) {
    if (ready) {
        GameAnalytics.getRemoteConfigsValueAsString({ key: "difficulty", defaultValue: "normal" }, function (value) {
            console.log(value);
        });
        GameAnalytics.getRemoteConfigsContentAsString(function (json) {
            console.log(json);
        });
    }
});
```

If the key is not found, `getRemoteConfigsValueAsString` returns `defaultValue`.

Read the A/B testing ids only after `isRemoteConfigsReady` has returned `true`:

```js
GameAnalytics.getABTestingId(function (id) { console.log(id); });
GameAnalytics.getABTestingVariantId(function (id) { console.log(id); });
```

## Not available

This plugin does not expose the following:

* Getters for the user id, the external user id or session times
* A remote config listener. Poll `isRemoteConfigsReady` instead
* Health event functions
* An error reporting toggle
* Remote config getters for numbers or JSON. Use `getRemoteConfigsValueAsString` or `getRemoteConfigsContentAsString` and parse the result yourself

## Upgrading from 4.x

1. Make sure your app meets the new minimums: cordova-android 11, cordova-ios 8, iOS deployment target 12.0 and Android `minSdkVersion` 21.
2. Update the plugin: `cordova plugin remove cordova-plugin-gameanalytics`, then `cordova plugin add cordova-plugin-gameanalytics`.
3. Rebuild both platforms. On iOS, run `pod install` again if you manage the Podfile yourself.
4. The function names and option keys are unchanged in the binding. `onComplete` now also fires on iOS for every function, so a callback that was never called on iOS before will now run.
5. `EGAAdAction` has two new members, `Request` and `Loaded`.

## Documentation and support

Full documentation: [docs.gameanalytics.com](https://docs.gameanalytics.com/event-tracking-and-integrations/sdks-and-collection-api/game-engine-sdks/cordova)

Questions or feedback: contact our support team [here](https://gameanalytics.com/contact). Bugs and contributions: see [CONTRIBUTING.md](CONTRIBUTING.md).

Changelog
---------
<!--(CHANGELOG_TOP)-->
**5.0.0**
* updated to Android SDK 7.2.1 and iOS SDK 5.0.2
* new minimums: cordova-android 11, cordova-ios 8, iOS 12.0 and Android minSdk 21
* added `Request` and `Loaded` to `EGAAdAction`
* `onComplete` is now called on iOS for every function
* removed the stale bundled iOS header
* the repository moved to GameAnalytics/gameanalytics-sdk-cordova

**4.2.8**
* fixed bug in internal error reporting

**4.2.7**
* added event uuid for events sent

**4.2.6**
* updated dependencies

**4.2.5**
* switched to use api 30 instead of 31 for android

**4.2.4**
* removed imei identifiers and other alternative identifiers from user identifier logic (android)

**4.2.3**
* added error events to be sent for invalid custom event fields used
* added optional mergeFields argument to event methods to merge with global custom fields instead of overwrite them

**4.2.2**
* fixed build.gradle for android

**4.2.1**
* fixed missing custom event fields for when trying to fix missing session end events

**4.2.0**
* added global custom event fields function to allow to add custom fields to events sent automatically by the SDK

**4.1.2**
* fixed dependencies versions

**4.1.1**
* added functionality to force a new user in a/b testing without having to uninstall app first, simply use custom user id function to set a new user id which hasn't been used yet

**4.1.0**
* added custom event fields feature

**4.0.0**
* Changed user identifier logic in preparation for Google changes to GAID. User id for a new install is now a randomised GUID. Existing installs that update SDK will continue using previous identifier logic. It is recommended to update as soon as possible to reduce impact on calculated metrics.

**3.3.8**
* it should now be possible to not show idfa consent dialog if you don't have any third party code that needs to use idfa (ios)
* prepared for google advertising identifier changes (will not use google advertising identifier when user has opted out) (android)

**3.3.7**
* added idfa consent status field to events (ios)

**3.3.6**
* updated client ts validator

**3.3.5**
* removed memory info from automatic crash reports

**3.3.4**
* fixed dependencies for iOS (min. XCode 12 required)

**3.3.3**
* removed memory info from automatic crash reports

**3.3.2**
* corrected ad event annotation

**3.3.1**
* improved user identifier flow for ios (ios)

**3.3.0**
* added ad event

**3.2.0**
* updated user identifier flow to prepare for iOS 14 IDFA changes (ios)

**3.1.1**
* fixed progression events with scores (android)

**3.1.0**
* exposed functions to get AB testing id and variant id

**3.0.10**
* fixed instant app bug in android native library

**3.0.9**
* updated native lib dependencies

**3.0.8**
* added session_num to init request

**3.0.7**
* config.xml fix

**3.0.6**
* fixes for ios

**3.0.5**
* removed facebook, gender and birthyear methods
* added auto detect app version for build field option

**3.0.4**
* A/B testing fixes

**3.0.3**
* fixed getRemoteConfgisValueAsString bug

**3.0.2**
* remote configs fixed

**3.0.1**
* updated native libs

**3.0.0**
* Remote Config calls have been updated and the old calls have deprecated. Please see GA documentation for the new SDK calls and migration guide
* A/B testing support added

**2.1.0**
* added enable/disable event submission function

**2.0.3**
* added type checks in wrapper layer

**2.0.2**
* fixed business event validation

**2.0.1**
* fixed validator bugs for ios

**2.0.0**
* added command center functionality
* updated google play services dependency version (android)

**1.0.11**
* version fix in plugin.xml

**1.0.10**
* version fix in plugin.xml

**1.0.9**
* lowered required cordova-android to 6.1.2

**1.0.8**
* added custom dimensions to design and error events

**1.0.7**
* fixed session length bug
* fixed now allowing to add events when session is not started

**1.0.6**
* fixed initialize function

**1.0.5**
* updated native libraries to cordova sdk version to events

**1.0.4**
* lowered minimum required cordova version
* changed plugin id to match npm package id

**1.0.3**
* readme updated

**1.0.2**
* plugin description fixes

**1.0.1**
* version fix

**1.0.0**
* initial version
