# Quickstart: Validate Auto-Advance Fix

## Prerequisites

- Flutter 3.41.x, with dependencies installed (`flutter pub get`)
- Linux: `libsqlite3.so.0` available (used by `setupTestSqlite`)

## Automated validation

```bash
dart format lib test
flutter analyze
flutter test test/controllers/active_workout_controller_test.dart
flutter test
```

Expected results:
- `flutter analyze` reports no issues.
- The new tests pass, including the regression case "3 planned + 1 extra, 3 logged → no
  advance". See the scenario tables in [contracts/active_workout_controller.md](contracts/active_workout_controller.md).
- The regression test fails when run against the old logic, which ignores extra sets.

## Manual validation (on device or emulator)

1. Start a workout that has at least 2 exercises. The first should be a strength exercise with
   3 planned sets.
2. Tap **ADD EXTRA SET**, so 4 sets are shown.
3. Log sets 1, 2 and 3. **Expected**: the page stays on the first exercise.
4. Log set 4. **Expected**: the page moves to the next exercise.
5. Repeat on an exercise without extra sets. **Expected**: the page moves on after the last
   planned set, as before.
6. Repeat steps 2–4 with a hybrid exercise. **Expected**: same behaviour.
7. On the last exercise, log all sets. **Expected**: no page change.
