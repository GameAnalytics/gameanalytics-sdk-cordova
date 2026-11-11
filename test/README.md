# Tests

None of these tests need a device, an emulator, game keys or the GameAnalytics servers,
and nothing here is part of the published plugin (the plugin is the `gameanalytics/`
directory only).

| Layer | Where | Run |
| --- | --- | --- |
| JavaScript binding, with Cordova's `exec` stubbed | `test/js` | `npm run test:js` |
| Static cross-layer checks (actions, callbacks, enums, versions, pins, package contents) | `test/static/check.js` | `npm run test:static` |
| Android bridge on the JVM, against recording stubs of Cordova, Android and the GameAnalytics SDK | `test/android` | `gradle -p test/android test` (Gradle 8.14, Java 17) |
| iOS bridge, compiled against recording stubs of Cordova and the GameAnalytics SDK (macOS) | `test/ios` | `test/ios/run-unit-tests.sh` |
| iOS bridge compiled against the real GA-SDK-IOS and cordova-ios headers (macOS) | `test/ios` | `test/ios/syntax-check.sh <GA-SDK-IOS Library dir> <cordova-ios include dir>` |

The expected values come from the GameAnalytics specification, not from the plugin source:
`test/data/enums.expected.json` holds the enum values and `test/data/surface.json` the
supported functions. When the specification changes, change those files first.

The workflow in `.github/workflows/test.yml` runs everything on `ubuntu-latest` and
`macos-latest`, and builds the sample for Android.
