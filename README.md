# StraightUp App v3

This is the official companion app for the StraightUp posture monitoring system. It connects to the wearable device via Bluetooth Low Energy (BLE), provides a user interface for real-time data visualization, and supports both reading and writing sensor data. Collected data can be stored locally or synced to the cloud, enabling detailed analysis and aiding in system development and evaluation.

## Supported Operating Systems

- iOS, Android, MacOs, Windows \*
- Not supported: Web

\* core-features supported on all, dev-features vary

## Development

### Run in Debug Mode

- Select your target platform in Visual Studio Code.
- Run `main.dart` using VSC's integrated tools.

Alternative via command line:

```bash
flutter run
```

- You will be prompted to select a target device/platform.

### Bugfixing

- No custom logger is implemented yet → using `print()` statements for now.
- These commands can help reset the build and dependency state:

```bash
flutter clean
flutter pub get
```

- following can help with identifying general flutter setup problems

```bash
flutter doctor
```

**Common errors**

- trying to uses "local state" (not global cubit state) in a stateless widget instead of a stateful widget
- using `const` where the UI needs to be dynamic
- to build you need os dependant SDKs/tools installed, which you dont need if you only use debugmode -> check via `flutter doctor` if your setup is complete
- BLE functionality requires platform-specific setup – check the BLE package documentation.
  - ⚠️ Especially relevant if copying only the `lib/` directory into a new Flutter project. BLE and other native functionality require config files in `android/`, `ios/`, `macos/`, etc.

## Build

Following are the steps to build the app for the different operating systems (os).

### Android

Build a universal APK (includes all Application Binary Interfaces (ABI) – suitable for quick prototyping):

```bash
flutter build apk
```

Omitting `--split-per-abi` creates a "fat APK" compatible with most devices – ideal during development.

### Windows

- not yet tested (only used in debug mode for now), refer to the flutter guidelines for further information: https://docs.flutter.dev/deployment/windows

### iOS

iOS builds require macOS and Xcode.

1. Open `ios/Runner.xcodeproj` in Xcode.
2. Select build configuration via:
   `Product → Scheme → Edit Scheme... → Run → Info → Build Configuration`

### MacOs

macOS builds require macOS and Xcode.

1. Open `macos/Runner.xcodeproj` in Xcode.
2. Select build configuration via:
   `Product → Scheme → Edit Scheme... → Run → Info → Build Configuration`

### Developer Notes

#### General

- Flutter docs are great: https://docs.flutter.dev/
- pub.dev lists all flutter packages out there: https://pub.dev/
- Windows build uses a different BLE package in a separate ble-service
- the [Bloc package](https://bloclibrary.dev/) with its Cubit architecture is used as state management tool
- carefully stay informed regarding major flutter and package updates as they may shake up the application
- carefully stay informed regarding major os updates as they may shake up the application as well
- its my first app so expect many bugs \*\_\* (Greetings JB)

#### Directory setup

```
straightup_app_v3/                      // project root
├── android/                            // os folder
├── archive/                            // old, unused legacy code
├── assets/                             // images, videos, etc.
├── build/                              // auto-generated build output
├── data/                               // CSV exports (used in Windows app)
├── ios/                                // os folder
├── lib/                                // application source code
│   └── bloc/                           // Cubits for state management
│   └── buses/                          // planned: data busses for wearabledata, etc.
│   └── data/
│       └── models/                     // custom data classes
│   └── services/                       // service classes (BLE, CSV, etc.)
│   └── views/                          // UI data (pages, screens, widgets)
│       └── constants/                  // constant theme data (colors, themes)
│       └── pages/                      // highlevel UI (pages)
│       └── widgets/                    // lower level UI (screens, widgets)
│   └── global_bloc_observer.dart       // global bloc observer
│   └── layout.dart                     // second level after main function, layout of app
│   └── main.dart                       // entry point for application
├── linux/                              // os folder
├── macos/                              // os folder
├── test/                               // tests (unit tests, widgets tests, what so ever to come)
├── web/                                // os folder
├── windows/                            // os folder
├── .env                                // secrets & constants, sensible data like api keys etc.
├── analysis_options.yaml               // setup for static code analysis -> you can tweak what kind of problems are highlighted
├── pubspec.lock                        // auto-generated; do not edit
├── pubspec.yaml                        // declare used packages -> usually manual manipulation is not required in VSC (just import package in src-code and right click to automatically declare/ download/integrate)
├── README.md                           // this file
└── TodoAndNotes.md                     // additional developer notes and todos
```
