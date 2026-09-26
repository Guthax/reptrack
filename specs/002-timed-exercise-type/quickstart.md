# Quickstart: Validating the Timed Exercise Type

**Feature**: [spec.md](spec.md) | **Contracts**: [database](contracts/database.md), [controllers](contracts/controllers.md)

## Prerequisites

- Flutter 3.47.5 and a working device or emulator.
- For the upgrade check (scenario 5): a device with the **current release (schema v1)**
  installed, with some workouts logged, including at least one Plank workout and a program
  that contains Plank.

## 1. Build and static checks

```bash
flutter pub run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze        # expect: No issues found!
flutter test           # expect: all tests pass
```

These test groups must exist and pass:

| File | Covers |
|------|--------|
| `test/persistance/migration_test.dart` | v1 → v2 conversion table in [contracts/database.md](contracts/database.md#schema) and the invariants in [data-model.md](data-model.md#migration-v1--v2) |
| `test/persistance/database_test.dart` | `addTimedExerciseToDay`, ordering with mixed types, `deleteProgram`, `getTimedSetsForExercise` |
| `test/persistance/composites_test.dart` | `ProgramExerciseVolume.timed`, `setsSecondsList`, `setsSecondsLabel` |
| `test/controllers/active_workout_controller_test.dart` | `logTimedSet` / `unlogTimedSet`, validation, stopwatch table, swap into timed, auto-advance with timed extra sets |
| `test/controllers/tracking_controller_test.dart` | `timedLongestHoldData`, `timedTotalTimeData`, 0-second sets skipped |
| `test/utils/duration_format_test.dart` | The `formatDuration` table |

## 2. Create a timed exercise (Story 2)

1. Open a program, tap **Add exercise**, then **Create new**.
2. **Expect**: the type options include **Timed** with the subtitle "Time".
3. Create "Dead Hang" as Timed, then add it to a day with 3 sets of 0:45 and a 60 s rest.
4. **Expect**: the day shows "Dead Hang", labelled Timed, with "3 × 0:45".
5. Edit it to 1:00 / 0:45 / 0:30. **Expect**: the label reads "1:00, 0:45, 0:30".

## 3. Log a timed workout (Story 1)

1. Start that day's workout and open Dead Hang.
2. **Expect**: 3 rows with minutes and seconds fields, and a collapsed weight input. There
   are no reps or distance fields.
3. Row 1: type 1:15 and log it. **Expect**: the row is logged and the rest timer starts at
   60 s.
4. Row 2: tap start, wait about 10 s, and tap stop. **Expect**: the fields show about 0:10.
   Log the row.
5. Row 3: tap start, lock the phone for 30 s, unlock, and tap stop. **Expect**: about 0:30.
6. Row 3: clear the fields and try to log. **Expect**: a snackbar asks for a duration, and
   the set is not logged.
7. Add an extra set, expand the weight input, enter 10 kg and 0:20, and log it. **Expect**:
   the workout advances to the next exercise only after this extra set is logged.
8. Start a new workout of the same day. **Expect**: the previous durations are shown as
   references, and the extra set's row has its weight input expanded and filled with 10 kg.

## 4. Tracking (Story 3)

1. Open **Tracking** and select Dead Hang.
2. **Expect**: the chart defaults to **Longest hold** (1:15 for today). Switch to **Total
   time** and expect about 2:15 for today.
3. **Expect**: the history lists the sets as `1:15`, `0:10`, `0:30`, `0:20 · 10 kg`.

## 5. Upgrade from the current release (Story 4)

1. On the prepared v1 device, install this build over the old one. Do not uninstall.
2. **Expect**: the app opens without errors, and all programs and workouts are present.
3. Open the program containing Plank. **Expect**: Plank is labelled Timed, sits in the same
   position, has the same number of sets with no target time ("3 sets"), and has the same
   rest timer.
4. Open **Tracking** and select Plank. **Expect**: the history shows the old Plank sets as
   "no time recorded", with the old weight where it was above 0 kg. The chart shows no
   points for those days.
5. Select Bench Press (or any non-hold exercise). **Expect**: its chart and history are
   identical to before the upgrade.
6. Select Plank Row. **Expect**: it is still Strength, with its history unchanged.

## 6. Fresh install

1. Uninstall and install the build.
2. **Expect**: the create-exercise dialog lists Strength, Cardio, Hybrid and Timed, and
   Plank, Side Plank, Copenhagen Plank, Wall Sit, Hollow Body Hold, L-Sit and Isometric Curl
   Hold are Timed.
