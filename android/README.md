# Clean Chess for Android

Minimal black-and-white Android version of Clean Chess built with Kotlin + Jetpack Compose.

## Structure

- `app/src/main/java/com/liseman/cleanchess/MainActivity.kt` — UI + chess logic
- `app/src/main/AndroidManifest.xml` — Android manifest
- `app/build.gradle.kts` — app build config
- `build.gradle.kts`, `settings.gradle.kts` — project config

## Run

1. Open the `android/` folder in Android Studio
2. Let Gradle sync
3. Run on an emulator or Android device

## Features

- Minimal monochrome UI
- Two-player local chess
- Castling supported
- Pawn promotion to queen
- Undo supported
