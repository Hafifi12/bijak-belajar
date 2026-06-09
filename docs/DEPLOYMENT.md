# Deployment — Bijak Belajar

This is a Flutter mobile app. "Deployment" means producing signed release
binaries and submitting them to the app stores. There is **no backend** to
deploy — all state is on-device.

## Prerequisites

- Flutter SDK (Dart SDK `^3.8.1`)
- Android: Android SDK + a configured signing keystore for release builds
- iOS: Xcode, an Apple Developer account, and signing certificates/profiles

## Verify before building

```sh
flutter pub get
flutter analyze        # expect: no errors
flutter test           # expect: all tests pass
```

## Build artifacts

```sh
# Android (debug — for local install / QA)
flutter build apk --debug
#   → build/app/outputs/flutter-apk/app-debug.apk

# Android (release — Play Store)
flutter build appbundle --release
#   → build/app/outputs/bundle/release/app-release.aab

# iOS (release — App Store, run on macOS)
flutter build ipa --release
#   → build/ios/ipa/*.ipa
```

## Store submission

- **Android:** upload the `.aab` to the Google Play Console.
- **iOS:** upload the `.ipa` via Xcode / Transporter to App Store Connect.
- **Content rating:** target **Everyone / 4+** (no ads, no IAP, no external
  links beyond the parent-gated settings).

> Store submission requires developer-account credentials and signing keys that
> are not part of this repository and cannot be automated here.

## Known build note — Android NDK

`speech_to_text` requests Android NDK `28.2.13676358`, while the project is
currently configured for `27.0.12077973`. The **debug build succeeds** with a
warning. To silence it (and ensure release native compatibility), set the NDK
version in `android/app/build.gradle.kts`:

```kotlin
android {
    ndkVersion = "28.2.13676358"
    // …
}
```

This change lives under `android/`, which was outside the scope of the current
work, so it has not been applied — apply it before cutting a release build.
