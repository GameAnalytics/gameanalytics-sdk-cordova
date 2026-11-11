#!/bin/sh
# Builds the real iOS bridge against recording stubs of Cordova and the
# GameAnalytics SDK and runs the unit tests. macOS with the Xcode command line
# tools is enough: no simulator, signing or CocoaPods.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
repo="$here/../.."
out="${1:-${TMPDIR:-/tmp}/ga-cordova-ios-tests}"
mkdir -p "$out"
clang -fobjc-arc -Wall -Wno-unused-function \
  -I "$here/stubs" -I "$repo/gameanalytics/src/ios" \
  "$here/BridgeTests.m" "$here/stubs/CordovaStub.m" "$here/stubs/GAStub.m" \
  "$repo/gameanalytics/src/ios/GameAnalyticsCordova.m" \
  -framework Foundation -o "$out/bridge-tests"
# The tests read ../../gameanalytics/package.json relative to this directory.
cd "$here"
"$out/bridge-tests"
