#!/bin/sh
# Compiles the real iOS bridge against the real GA-SDK-IOS headers and the real
# cordova-ios headers (clang -fsyntax-only), so a selector or type that the
# published SDK does not have fails here even though the unit tests use stubs.
#
# usage: syntax-check.sh <GA-SDK-IOS Library dir> <cordova-ios include dir>
#   GA-SDK-IOS Library dir:  Library/ of https://github.com/GameAnalytics/GA-SDK-IOS at tag 5.0.2
#   cordova-ios include dir: CordovaLib/include of the cordova-ios npm package
set -eu
ga_lib="$1"
cordova_include="$2"
here="$(cd "$(dirname "$0")" && pwd)"
repo="$here/../.."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
# The bridge imports <GameAnalytics/GameAnalyticsWrapper.h>, a framework-style path.
mkdir -p "$work/GameAnalytics"
cp "$ga_lib"/GameAnalytics.h "$ga_lib"/GameAnalyticsWrapper.h "$work/GameAnalytics/"
sdk="$(xcrun --sdk iphonesimulator --show-sdk-path)"
clang -fsyntax-only -fobjc-arc -Wall -Werror=objc-method-access -Werror=incompatible-pointer-types \
  -target arm64-apple-ios12.0-simulator -isysroot "$sdk" \
  -I "$cordova_include" -I "$work" -I "$repo/gameanalytics/src/ios" \
  "$repo/gameanalytics/src/ios/GameAnalyticsCordova.m"
echo "iOS bridge compiles against the real GA-SDK-IOS and cordova-ios headers"
