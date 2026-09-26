# Research: Timed Exercise Type

**Feature**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md) | **Date**: 2026-09-26

All findings come from reading the current code base (Drift 2.31.0, Flutter 3.47.5). No
`NEEDS CLARIFICATION` items remain in the Technical Context.

## R1. How timed data is stored

- **Decision**: Add two new tables, `ProgramTimedExercises` and `WorkoutTimedSets`, next to
  the existing Strength, Cardio and Hybrid program and set tables. Existing tables are not
  altered.
- **Rationale**: Each exercise type already has its own program table and set table
  (`ProgramHybridExercises` / `WorkoutHybridSets`, and so on). Constitution Principle III
  requires a new exercise kind to have both a program table and a set table. Adding tables
  instead of columns means no existing row changes shape, which is what keeps older data
  readable.
- **Alternatives considered**:
  - Reusing `WorkoutStrengthSets` and storing seconds in `reps`: rejected. Timed sets would
    show up in strength charts and volume calculations, and nothing would tell the two
    apart.
  - Adding a nullable `durationSeconds` column to `WorkoutStrengthSets`: rejected. It
    changes an existing table and breaks the one-table-per-type pattern.

## R2. Migration mechanism

- **Finding**: `AppDatabase` has `schemaVersion => 1` and no `migration` getter, so Drift's
  default strategy is in use. That strategy creates all tables on first open and has no
  upgrade path.
- **Decision**: Raise `schemaVersion` to 2 and add a `MigrationStrategy`:
  - `onCreate`: `m.createAll()`, as today.
  - `onUpgrade`: when `from < 2`, run the v1 → v2 step (R3).
- **Rationale**: This is the standard Drift mechanism, and Principle III requires it.
  Without an `onUpgrade`, a version bump fails on existing installs.
- **Alternatives considered**: Creating the tables lazily from `seedDatabase` with raw
  `CREATE TABLE IF NOT EXISTS`: rejected, because it bypasses Drift's schema versioning.

## R3. Converting the built-in hold exercises (FR-012 to FR-016)

- **Decision**: The v1 → v2 step runs inside one explicit `transaction(...)`:
  1. Create `program_timed_exercises` and `workout_timed_sets`.
  2. Insert or update exercise type `'4'` / `'Timed'`.
  3. Look up exercises whose `lower(name)` is in the hold list (see
     [data-model.md](data-model.md#hold-list)).
  4. For each strength set of those exercises, insert a timed set with the same `id`,
     `workoutId`, `exerciseId`, `equipmentId`, `setNumber`, `isCompleted` and `dateLogged`;
     `durationSeconds = 0`; and `weight` = the old weight if it was above 0, otherwise null.
  5. For each strength program entry of those exercises, insert a timed program entry with
     the same `id`, `workoutDayId`, `equipmentId`, `exerciseId`, `orderInProgram` and
     `restTimer`, and `setsSeconds` = a JSON list of `0` with one entry per planned set.
  6. Delete the converted strength sets and strength program entries.
  7. Set `exerciseTypeId = '4'` on the matched exercises.
- **Rationale**: The explicit transaction makes the step all-or-nothing (FR-015). Drift runs
  `onUpgrade` only once per version bump, so it cannot run twice. The data volume is small
  (one user's history), so Dart loops over typed rows are clear and fast enough. Keeping the
  row `id`s keeps conversions traceable in tests.
- **Alternatives considered**:
  - Converting in `seedDatabase`, which runs on every start: rejected. It would reconvert
    rows on every launch, and a failure would not roll back together with the schema change.
  - Pure SQL `INSERT … SELECT`: rejected for program entries, because building `[0,0,0]`
    from `json_array_length` is awkward. The Dart loop is also easier to read and test.

## R4. Fresh installs and seeding

- **Finding**: `seedDatabase` runs on every start and is idempotent. It upserts exercise
  types, and it only inserts CSV exercises whose name does not exist yet. The Hybrid rollout
  also retypes exercises by name on every start.
- **Decision**:
  - Add `'4': 'Timed'` to the seeded exercise types.
  - Change the type column of the seven hold exercises in `assets/data/exercises.csv` from
    `1` to `4`.
  - Do **not** add an every-start retype by name for Timed.
- **Rationale**: Fresh installs get Timed holds straight from the CSV. Existing installs are
  converted once by the migration. An every-start retype would change the type of an
  exercise with strength history (for example, one the user recreated after renaming the
  original) without moving its data, leaving that history orphaned.

## R5. Program target durations

- **Decision**: `ProgramTimedExercises.setsSeconds` is a JSON list of integer seconds, one
  per set (e.g. `"[60,60,45]"`), with default `'[60]'`. A value of `0` means "no target".
- **Rationale**: It mirrors `setsReps` and `setsDistances`, so the add, edit and
  set-count logic stays the same. Cardio already treats a duration of `0` as unset
  (`durationLabel`).

## R6. Duration input and display

- **Finding**: `CardioLogSection` uses separate hours, minutes and seconds text fields with
  `FilteringTextInputFormatter.digitsOnly` and `MaxValueInputFormatter` (`lib/utils/app_theme.dart`).
- **Decision**:
  - Timed set rows use a minutes field and a seconds field. The seconds field is capped at
    59 by `MaxValueInputFormatter`, so "0:90" cannot be typed (this resolves the spec edge
    case).
  - The minutes field is uncapped, so durations over an hour can be entered as, for
    example, 75:00.
  - Display is `m:ss` below an hour and `h:mm:ss` from an hour up, via one shared formatter
    in `lib/utils/`.
- **Rationale**: This reuses the existing input pattern and formatter, and it keeps one
  source of truth for duration text across the set rows, history, program labels and
  charts.

## R7. Weight unit

- **Finding**: Strength and hybrid inputs display weight in the user's unit and convert with
  `SettingsController.toKg` / `fromKg`. Storage is always kg.
- **Decision**: The optional timed weight follows the same rule: it is shown in the user's
  unit and stored in kg. An empty field is stored as `null`.

## R8. Stopwatch (FR-004a)

- **Decision**: Stopwatch state lives in `ActiveWorkoutController`:
  - The running row's key (`"$exerciseIndex-$equipmentId-$setNum"`) and the `DateTime` at
    which start was tapped are kept in Rx fields.
  - A 1-second `Timer.periodic` only refreshes the displayed elapsed time.
  - Elapsed time is always `DateTime.now().difference(startedAt)`, rounded down to whole
    seconds, so it stays correct while the app is backgrounded or the screen is off.
  - Starting a second stopwatch stops the first and reports its elapsed time to that row.
  - `swapExercise` and `onClose` discard a running stopwatch.
- **Rationale**: The rest timer already uses a controller-held `Timer.periodic`. Holding the
  state in the controller satisfies Principle I and makes the behaviour unit-testable,
  because the clock is injected (R9). No new package is needed.
- **Alternatives considered**: Using the `Stopwatch` class inside the widget: rejected,
  because state in a `StatefulWidget` is lost when a `PageView` page is disposed, and it
  cannot be tested without widget tests (Principle V).

## R9. Testability of time-based logic

- **Decision**: `ActiveWorkoutController` gets an optional `DateTime Function() clock`
  constructor parameter, which defaults to `DateTime.now`. The stopwatch reads time only
  through it.
- **Rationale**: Controller tests can then move the clock forward and assert elapsed time
  without waiting in real time.

## R10. Tracking metrics (FR-008)

- **Decision**: Add `ChartType.timedLongestHold` (the default) and `ChartType.timedTotalTime`.
  Both group sets by calendar day and filter by the selected equipment, like strength and
  hybrid. Both skip sets with `durationSeconds == 0`, and a day left with no sets has no
  point. The Y-axis values are in seconds and are labelled with the shared duration
  formatter.
- **Rationale**: It matches the existing two-metric pattern for strength and hybrid, and the
  per-day grouping helpers already exist.

## R11. Layering of new UI code (Principle II)

- **Finding**: Several existing widgets call `AppDatabase` directly, for example
  `ExerciseHistoryDialog`'s history lists and the equipment lookups in dialogs. These are
  earlier deviations and fall outside this feature.
- **Decision**: New timed UI code reads only through controllers:
  - Timed history in the workout comes from `ActiveWorkoutController.lastTimedSets`.
  - The tracking screen reads `TrackingController.timedSets`.
  - The `_TimedHistoryList` inside `ExerciseHistoryDialog` receives its sets from
    `ActiveWorkoutController` instead of querying the database.
- **Rationale**: New code must follow the constitution, even when some existing code nearby
  does not.

## R12. Migration testing

- **Decision**: Test the upgrade with a hand-built v1 database:
  - In a test, open `NativeDatabase.memory(setup: ...)`, run the v1 `CREATE TABLE`
    statements for the tables involved, insert v1 rows, and set `PRAGMA user_version = 1`.
  - Then open `AppDatabase.forTesting` on that executor and assert the converted state.
- **Rationale**: This needs no new package and no `build.yaml` schema-export setup
  (Principle VII), and it follows Principle V (in-memory database via
  `test/test_helpers.dart`).
- **Alternatives considered**: `drift_dev make-migrations` with generated schema snapshots:
  a stronger long-term tool, but it needs extra configuration and a v1 schema dump taken
  before any table edits. It can be adopted in a later feature.

## R13. Exercise type id

- **Decision**: Timed uses exercise type id `'4'`. It is checked with the same string
  comparison as the existing `'2'` and `'3'` (`exercise.exerciseTypeId == '4'`), plus an
  `isTimed` getter on `ProgramExerciseVolume` / `ExerciseWithVolume`.
- **Rationale**: It follows the existing convention (Principle II: no parallel conventions).

## R14. Places where "else" currently means Strength

- **Finding**: Many branches are written `if (isCardio) … else if (isHybrid) … else /*
  strength */`, and `ProgramExerciseVolume` getters end in `_hybrid!`. Every one of these
  needs an explicit timed branch, or a timed exercise will be treated as strength or crash
  on a null check.
- **Affected files**:
  - `lib/persistance/composites.dart`
  - `lib/persistance/database.dart`: `deleteProgram`, `reorderExercisesInDay`, the
    `addXExerciseToDay` order counts, `watchWorkoutDaysWithExercises`
  - `lib/controllers/active_workout_controller.dart`: setup queries, prefetch,
    `swapExercise`, `addExerciseDuringWorkout`
  - `lib/controllers/build_program_controller.dart`
  - `lib/controllers/tracking_controller.dart`
  - `lib/pages/build_program.dart`
  - `lib/pages/tracking.dart`
  - `lib/widgets/add_exercise_dialog.dart`
  - `lib/widgets/edit_program_exercise_dialog.dart`
  - `lib/widgets/add_workout_exercise_dialog.dart`
  - `lib/widgets/exercise_workout_card.dart`
  - `lib/widgets/exercise_history_card_widget.dart`
  - `lib/widgets/swap_exercise_dialog.dart`
  - `lib/widgets/workout_information_dialog.dart`
  - `lib/widgets/create_exercise_dialog.dart` (the subtitle "Time")
