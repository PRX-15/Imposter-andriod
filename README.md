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

## Match and round scoring

A match can contain multiple rounds. **PLAY AGAIN** continues the current match with the same players and cumulative scores; **MAIN MENU** completes and archives that match. Completed matches are stored separately from an unfinished match, which can be resumed after an app restart.

- Imposter escapes a unique top-vote result: **+2**.
- Imposter is the unique highest-vote player: **−1**.
- Each non-Imposter gets **+1** for voting for the Imposter, or **−1** for an incorrect vote.
- If every non-Imposter votes for the Imposter, each non-Imposter receives **+1 additional bonus point**.
- A tie for the highest vote count means the Imposter escapes.
- Match history contains completed matches and their round-by-round word, imposter, votes, catch result, points and cumulative scores.

All match recovery and history data is stored locally with SharedPreferences; gameplay remains offline.

## Migration note

This is the initial Flutter migration baseline. The screen flow and core rules are implemented here, with UI styling inspired by the existing IMPOSTER-WEB project. The original Kivy-specific morph and curtain animations are being recreated as native Flutter animations; exact visual parity should be checked on-device against the existing app.
