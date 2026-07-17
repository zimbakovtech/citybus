# CityBus mobile

Flutter app: stop search + nearby, route maps, journey planner, live vehicle
tracking. See the root README for backend setup.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # only after model changes
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # Android emulator
flutter run --dart-define=API_BASE_URL=http://localhost:8000  # iOS simulator
flutter analyze && flutter test
```

Structure: feature-first (`lib/features/{stops,routes,planner,live_tracking}`)
with a `data` / `domain` / `presentation` split per feature; shared plumbing in
`lib/core` (Dio client with typed failures, WebSocket client, env config, OSM
map scaffold, status views) and `lib/app` (theme, GoRouter with a bottom-tab
shell).

Two deliberate simplifications, noted for reviewers:

- The freezed API models double as domain entities (no separate entity
  classes) — they are immutable value types already, and mirroring them would
  add boilerplate without insight.
- Repository interfaces stand in for use-case classes; providers call them
  directly.

Generated `*.freezed.dart` / `*.g.dart` files are committed so the project
builds without running `build_runner`.
