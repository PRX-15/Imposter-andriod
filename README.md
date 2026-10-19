# IMPOSTER ANDROID

A Flutter + Dart migration of PRX-15's offline, local pass-and-play IMPOSTER game.

## Features

- 3–10 players with editable names
- Random Imposter and random bilingual English/Hindi word/category
- Private pass-the-phone role reveal with animated curtain
- Discuss phase, private sequential voting, vote summary and tie handling
- Round scoring and cumulative scoreboard
- Play Again, Main Menu and locally saved match history
- Offline gameplay; no account, server, or network connection required
- GitHub Actions debug APK build

## Build an APK

The repository's GitHub Actions workflow creates the Android platform scaffold, resolves Flutter dependencies, runs static analysis and tests, and builds a debug APK.

1. Open **Actions** in this repository.
2. Select **Build Android APK**.
3. Tap **Run workflow** (or push a commit to `main`).
4. Download `imposter-debug-apk` from the completed workflow's artifacts.

The APK is a debug build intended for testing. A release APK can be added once signing requirements are configured.

## Local development

Install Flutter stable and Android SDK, then run:

```bash
flutter create --platforms=android --project-name imposter_android --org com.prx15 .
flutter pub get
flutter analyze
flutter test
flutter run
```

## Game scoring

- Each non-Imposter voter gets **+1** for correctly voting for the Imposter and **−1** otherwise.
- If the group fails to uniquely identify the Imposter (including a tie), the Imposter gets **+2**.
- Cumulative totals are shown on the results screen.

## Migration note

This is the initial Flutter migration baseline. The screen flow and core rules are implemented here, with UI styling inspired by the existing IMPOSTER-WEB project. The original Kivy-specific morph and curtain animations are being recreated as native Flutter animations; exact visual parity should be checked on-device against the existing app.
