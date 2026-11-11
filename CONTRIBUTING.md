# Contributing

The plugin lives in `gameanalytics/`. The repository root is a Cordova sample app that installs the plugin from that folder.

## Prerequisites

* Node.js and Cordova: `npm i -g cordova`
* Android: Android Studio or the Android SDK, with cordova-android 11 or higher
* iOS: Xcode and [CocoaPods](https://cocoapods.org), with cordova-ios 8 or higher

## Setup

```
cordova platform add android
cordova platform add ios
cordova plugin add gameanalytics
```

After changing files in `gameanalytics/`, reinstall the plugin before testing in the app:

```
cordova plugin remove cordova-plugin-gameanalytics
cordova plugin add gameanalytics
```

`cordova-plugin-gameanalytics` is the plugin id from `gameanalytics/plugin.xml`. The folder name `gameanalytics` is only the install source.

## Running the sample

The sample in `www/js/index.js` calls every function the plugin exposes. Put your own `your_game_key` and `your_secret_key` in the `initialize` call, then run:

```
cordova run android
cordova run ios
```

Every line the sample prints starts with `GATEST:`. It goes to the console and to an on-screen log, so you can filter on it:

* Android: `adb logcat | grep GATEST:`, or use `chrome://inspect`
* iOS: Safari, Develop menu, then your device or simulator

Look for `GATEST: complete <step>` lines, which show that `onComplete` fired for each call, and `GATEST: state ...` lines, which show the values read back from the SDK. The run ends with `GATEST: finished`. The sample enables the SDK info and verbose logs, so the native log shows whether events were accepted.

## Build check

`cordova build`

## Files to update when the SDK interface changes

* `gameanalytics/src/android/GameAnalyticsCordova.java`
* `gameanalytics/src/ios/GameAnalyticsCordova.h`
* `gameanalytics/src/ios/GameAnalyticsCordova.m`
* `gameanalytics/www/GameAnalytics.js`
* `www/js/index.js`, so the sample keeps covering every function
* `README.md`

## Versions

The plugin version is set in four places. Keep them identical:

* `gameanalytics/plugin.xml` (`version` on the `<plugin>` element)
* `gameanalytics/package.json` (`version`)
* `gameanalytics/src/android/GameAnalyticsCordova.java` (`VERSION`)
* `gameanalytics/src/ios/GameAnalyticsCordova.m` (`#define VERSION`)

Native SDK versions:

* Android: `gameanalytics/src/android/build.gradle`, the `gameanalytics-android` dependency (currently 7.2.1).
* iOS: `gameanalytics/plugin.xml`, the `GA-SDK-IOS` pod (currently `~> 5.0.2`).

GA-SDK-IOS 5.0.2 is the last release published to CocoaPods trunk. Later releases are Swift Package Manager only, which is why the pod is pinned to `~> 5.0.2`.

The minimum platform versions (cordova-android 11, cordova-ios 8) are in the `<engines>` block of `gameanalytics/plugin.xml`. Add a changelog entry to `README.md` below the `<!--(CHANGELOG_TOP)-->` marker for every release.
