# Contributing

The plugin lives in `gameanalytics/`. The repository root is a Cordova sample app that installs the plugin from that folder.

## Prerequisites

Cordova:

`sudo npm i -g cordova`

## Setup

`cordova platform add ios`
`cordova platform add android`
`cordova plugin add gameanalytics`

After changing files in `gameanalytics/`, reinstall the plugin before testing in the app:

`cordova plugin remove com.gameanalytics.cordova`
`cordova plugin add gameanalytics`

## Testing

`cordova build`

### Android

`cordova run android`

### iOS

`cordova run ios`

## Files to update when the SDK interface changes

* gameanalytics/src/android/GameAnalyticsCordova.java
* gameanalytics/src/ios/GameAnalytics.h
* gameanalytics/src/ios/GameAnalyticsCordova.h
* gameanalytics/src/ios/GameAnalyticsCordova.m
* gameanalytics/www/GameAnalytics.js
