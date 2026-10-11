# AniWorthy

**100% offline anime trivia & quiz for Android.**

AniWorthy is a small, friendly trivia game about anime studios, series,
characters, creators and fan vocabulary. It runs entirely on your device — no
backend, **no permissions, no INTERNET permission**, no ads and no analytics.

- Package: `com.anivala.watchanimetv`
- Privacy policy: https://codex-zubair.github.io/all_privacy_policy/aniworthy/
- Category: Trivia
- Platform: Android (min SDK 24)

## Features

- **5 categories** — Studios, Series, Characters, Creators, General.
- **100+ original, factual questions** — no verbatim quotes, lyrics or media.
- **Instant feedback** with a short fact after every answer.
- **Score, grade and full round review**; personal bests saved locally.
- **Fact of the day** card on the home screen.
- **Zero permissions**, no network, no ads, no tracking.

## Privacy

- No `INTERNET` permission (removed at build time).
- No Android permissions requested at all.
- Best scores are stored only in the app's private on-device storage and can
  be cleared in Settings.

## Architecture

```
lib/
  core/       Pure Dart: models, quiz engine, question bank
  services/   ScoreStore (SharedPreferences)
  state/      QuizState (ChangeNotifier + provider)
  screens/    root_shell, home, quiz, results, settings, about
  widgets/    brand
  theme/      app_theme
```

`lib/core` has no Flutter imports, so the quiz logic and the question bank are
fully unit-testable.

## Development

```bash
flutter pub get
flutter analyze          # 0 issues
flutter test             # 17 tests
flutter run

flutter build appbundle --release   # AAB for Play
flutter build apk --release         # APK for sideload
```

Generate branding and store graphics:

```bash
python3 tool/gen_icons.py
dart run flutter_launcher_icons
dart run flutter_native_splash:create
python3 tool/make_graphics.py
```

## License

MIT — see [LICENSE](LICENSE).
