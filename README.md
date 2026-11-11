# GA-SDK-CORDOVA-DEV
Development repository for Cordova SDK

### Prerequirement
Cordova

`sudo npm i -g cordova`

### Setup

`cordova platform add ios`
`cordova platform add android`
`cordova plugin add gameanalytics`

If the plugin files in the 'gameanalytics' folder has to be changed call these commands before testing in app:

`cordova plugin remove com.gameanalytics.cordova`
`cordova plugin add gameanalytics`

### Testing

`cordova build`

#### Android

`cordova run android`

#### iOS

`cordova run ios`

### Files to update when the SDK interface changes
* gameanalytics/src/android/GameAnalyticsCordova.java
* gameanalytics/src/ios/GameAnalytics.h
* gameanalytics/src/ios/GameAnalyticsCordova.h
* gameanalytics/src/ios/GameAnalyticsCordova.m
* gameanalytics/www/GameAnalytics.js

## How to publish a new version of the SDK

**Requirements**
* Git
* Python 3
* npm

**Steps**
* Make sure you have cloned the [GA-SDK-DEFOLD](https://github.com/GameAnalytics/GA-SDK-DEFOLD) repo under the same parent folder as this repo
* Make sure you have cloned the [GA-SDK-BINARIES](https://github.com/GameAnalytics/GA-SDK-BINARIES) repo under the same parent folder as this repo
* Update GA Android SDK version to the latest version here: gameanalytics/src/android/build.gradle
* Update GA iOS SDK version to the latest version here: gameanalytics/plugin.xml
* Run `python publish_defold_release.py -v <VERSION> -c <changelog::second line>`
