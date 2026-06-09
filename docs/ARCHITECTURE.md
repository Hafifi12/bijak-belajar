# Architecture — Bijak Belajar

A Flutter learning app for kids (ages 3–8) with three layered systems: an offline
voice tutor, a visual/animation layer, and a gamification engine. Fully offline,
child-safe (no network, no analytics, no ads), local progress storage only.

## Tech stack & why

| Concern | Choice | Why |
|---|---|---|
| State management | **flutter_riverpod** | App-wide providers (`progressServiceProvider`, `audioServiceProvider`, `appStateProvider`) without prop-drilling. The pre-loaded `ProgressService` is injected via a `ProviderScope` override in `main.dart`. |
| Persistence | **shared_preferences** | The app already shipped with a `shared_preferences` schema. Per the project constraint of not migrating an existing production schema, we kept it rather than moving to Hive. All gamification state (stars, streak, badges, quests) lives in the same store. |
| Voice tutor (TTS) | **flutter_tts** | On-device, zero-network narration. Slower speech rate (0.45) and higher pitch (1.2) tuned for young children. Wrapped in `AudioService`. |
| Speech input (STT) | **speech_to_text** | On-device recognition for the letter-recognition activity (`learn_letters_screen`). Transcripts are processed locally and discarded. |
| Mascot animation | **lottie** | Chosen over Rive: the asset pipeline is plain bundled JSON (`assets/animations/mascot_*.json`) with no `.riv` tooling required. `MascotWidget` swaps idle/celebrate/encourage clips and has an emoji fallback if an asset fails to load. |
| Reward FX | **confetti** | Pure-Dart particle bursts on level-up and badge unlock. |
| Misc UI | flutter_staggered_animations, font_awesome_flutter | Entrance animations and iconography. |

## Directory structure

```
lib/
├── main.dart                 # Boots ProgressService, injects it via ProviderScope
├── app.dart                  # MaterialApp + named routes + RouteObserver
├── providers/
│   └── app_state.dart        # Riverpod providers + read-only AppState snapshot
├── services/
│   ├── progress_service.dart # ChangeNotifier: stars/XP, level, streak, badges, quests, persistence
│   └── audio_service.dart    # flutter_tts wrapper (speak/locale/effects)
├── models/                   # level, badge, quest, challenge, progress, language, …
├── screens/                  # 21 screens (learn modules, games, rewards, parent gate/settings)
├── widgets/
│   ├── mascot_widget.dart       # Lottie mascot with idle/celebrate/encourage states
│   ├── xp_popup.dart            # Animated +stars popup overlay
│   ├── badge_unlock_overlay.dart# Full-screen badge unlock dialog + confetti
│   └── star_counter.dart, …
└── data/badge_data.dart      # 25 badge definitions
assets/animations/            # Lottie mascot JSON (idle / celebrate / encourage)
```

## Gamification model (`ProgressService`)

`ProgressService` is the single source of truth, exposed app-wide as a
`ChangeNotifier` via `progressServiceProvider`. `appStateProvider` derives a
read-only `AppState { xp, level, streak, unlockedBadges }` snapshot from it.

- **Stars / XP** — `stars` is the lifetime currency. Earned per lesson (+1),
  per challenge (+1), and as **daily-quest completion bonuses**.
- **Levels** — 10 tiers defined in `models/level.dart`, derived from total stars
  via `levelForStars` (e.g. L1 0–9★, L2 10–24★, L3 25–49★…). Crossing a tier sets
  a one-shot `_pendingLevelUp` consumed by the home screen to show `LevelUpDialog`.
- **Streak** — `_checkStreak()` on load compares `last_login_date` to today /
  yesterday; consecutive days increment, gaps reset to 1. A new day raises a
  one-shot daily-reward flag (`DailyRewardDialog`).
- **Badges** — 25 definitions (`data/badge_data.dart`) keyed by condition
  (stars / games / streak / level / module completion). `_checkAllBadges()` runs
  after every award and queues newly earned badges in `_pendingBadges`.
- **Daily quests** — three rotating quests; progress tracked per day, completion
  grants bonus stars.

### One-shot "reward event" pattern

Business logic stays out of widgets. The service exposes one-shot consumers that
the home screen drains in sequence after any progress change:

- `consumeDailyRewardFlag()` → `DailyRewardDialog`
- `consumeLevelUp()` → `LevelUpDialog`
- `consumePendingBadges()` → `BadgeUnlockOverlay` (shown one at a time)

The home screen listens to `ProgressService` for live star gains (animated XP
popup + mascot celebrate) and, on each return-to-home, drains the one-shot
queues. The service reference is cached so `dispose()`/listeners never touch
Riverpod `ref` outside the mounted lifecycle.

## Key design decisions

1. **No live LLM / no network.** All tutor speech is device TTS over local
   strings; STT is on-device. This guarantees child-safety and offline use.
2. **shared_preferences over Hive.** Deliberate — avoids migrating an existing
   production schema. Gamification keys were added alongside the existing ones.
3. **Lottie over Rive.** No custom `.riv` pipeline; JSON clips are bundled and
   lazy-loaded per screen, with a graceful emoji fallback.
4. **Persist after mutation.** Quest bonuses and badge unlocks mutate star/badge
   state *after* the base award, so persistence happens after that processing
   (a bug where bonus stars were dropped on reload was fixed here).
