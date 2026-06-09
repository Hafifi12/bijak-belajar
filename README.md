# Bijak Belajar

Bijak Belajar is a free Flutter learning app for kids ages 3 to 7. It helps children explore real objects, match memory cards, and sort numbers or letters with playful train activities.

## MVP

- No login
- No backend
- No ads
- Local progress storage
- Find Explorer, Number Train, Letter Train, and Memory Game
- Learn modules: Numbers, Letters, Jawi, Body Parts, Math, Colouring
- Animal, shape, and color memory decks
- English, Bahasa Melayu, Mandarin, Tamil, and Bahasa Indonesia app language setting
- Native text-to-speech pronunciation for prompts and learning words
- Voice (speech-to-text) letter recognition activity

## Gamification

- A reactive **Sunny** mascot (Lottie) that celebrates and encourages
- **Stars / XP** earned per lesson, game, and daily-quest completion
- **10 levels** with a level-up celebration screen
- **25 badges** with an animated unlock overlay
- **Daily streak** + daily reward that persists across restarts
- Animated `+stars` popups and confetti reward bursts

State is held in a single `ProgressService` (a Riverpod-provided `ChangeNotifier`)
and persisted locally with `shared_preferences`. See
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Development

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

The debug APK is written to `build/app/outputs/flutter-apk/app-debug.apk`.

For release builds and store submission, see [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).
Architecture and design decisions are in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).
