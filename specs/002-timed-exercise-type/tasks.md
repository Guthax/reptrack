---

description: "Task list for the Timed exercise type"
---

# Tasks: Timed Exercise Type

**Input**: Design documents from `/specs/002-timed-exercise-type/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/database.md](contracts/database.md),
[contracts/controllers.md](contracts/controllers.md), [quickstart.md](quickstart.md)

**Tests**: Required. Constitution Principle V says every change to controller, persistence or
utility logic needs tests in the matching `test/` subfolder, using the in-memory database
(`AppDatabase.forTesting(NativeDatabase.memory())` + `setupTestSqlite()` from
`test/test_helpers.dart`). No widget tests.

**Organization**: Tasks are grouped by user story. The spec has three P1 stories. They are
ordered here by dependency: **US2** (create/plan) comes before **US1** (log), because a timed
exercise has to be in a program before it can be logged. **US4** (upgrade) is next, then
**US3** (P2, tracking).

**Rules that apply to every task** (Constitution VI and CLAUDE.md):
- Every new class and method has a brief `///` doc comment.
- No `//` comments inside method bodies.
- Use `const` wherever possible.
- Run `dart format` on the edited files.
- User-fixable validation → `AppSnackbar.error(...)`.
- System failures → `AppErrorHandler.showSystemError(e, st)`.
- Never swallow exceptions.
- Timed type id is the string `'4'`, compared the same way as `'2'`/`'3'` (research R13).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on unfinished tasks)
- **[Story]**: The user story the task belongs to (US1–US4 from spec.md)

---

## Phase 1: Setup

**Purpose**: Confirm a clean baseline before any schema change.

- [X] T001 Run `flutter analyze` and `flutter test` from the repository root on the unchanged code and record the result (expected: no issues, all tests pass), so later failures can be attributed to this feature.

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: Schema v2, generated code, composites and shared helpers that every story uses.

**⚠️ CRITICAL**: No user-story work can start until this phase is complete.

### Tests for the foundation (write first; they must fail before implementation)

- [X] T002 [P] Create `test/utils/duration_format_test.dart` testing `formatDuration` with the contract table: 0 → `0:00`, 45 → `0:45`, 75 → `1:15`, 3600 → `1:00:00`, 4530 → `1:15:30`.
- [X] T003 [P] Extend `test/persistance/composites_test.dart` with a `ProgramExerciseVolume.timed` group:
  - `isTimed` is true and `isCardio`/`isHybrid` are false.
  - `id`, `workoutDayId`, `exerciseId`, `orderInProgram`, `equipmentId` and `restTimer` come from the timed row.
  - `weight` is `0.0`.
  - `setsSecondsList` parses `"[60,45,30]"` and falls back to `[60]` on invalid JSON.
  - `setsSecondsLabel` returns `"3 × 1:00"` for `[60,60,60]`, `"1:00, 0:45, 0:30"` for `[60,45,30]`, and `"3 sets"` for `[0,0,0]`.
  - `ExerciseWithVolume.isTimed` mirrors the volume.
- [X] T004 [P] Extend `test/persistance/database_test.dart` with a `Timed program exercises` group:
  - `addTimedExerciseToDay` returns an id, and the row has `setsSeconds` JSON-encoded.
  - `orderInProgram` counts existing strength, cardio, hybrid and timed entries on the day.
  - `addStrengthExerciseToDay` / `addCardioExerciseToDay` / `addHybridExerciseToDay` also count timed entries.
  - `updateProgramTimedExercise` and `deleteProgramTimedExercise` work.
  - `deleteProgram` removes `programTimedExercises` rows.
  - `reorderExercisesInDay` writes a timed volume's order.
  - `watchWorkoutDaysWithExercises` emits timed entries as `ProgramExerciseVolume.timed`, sorted with the other types.
  - `getTimedSetsForExercise` returns only `isCompleted = true` rows, newest first, including rows with `durationSeconds = 0`.
  - A fresh database has `schemaVersion == 2`.

### Implementation for the foundation

- [X] T005 Add table `ProgramTimedExercises` to `lib/persistance/database.dart` after `ProgramHybridExercises`, with a `///` doc comment:
  - `id` text PK, `clientDefault(() => _uuid.v4())`
  - `workoutDayId` text `references(WorkoutDays, #id, onDelete: KeyAction.cascade)`
  - `equipmentId` text nullable `references(Equipments, #id, onDelete: KeyAction.cascade)`
  - `exerciseId` text `references(Exercises, #id)`
  - `orderInProgram` int, default `0`
  - `setsSeconds` text (JSON `List<int>`), default `'[60]'`, "One target per set; `0` = no target"
  - `restTimer` int nullable
- [X] T006 Add table `WorkoutTimedSets` to `lib/persistance/database.dart` after `WorkoutHybridSets`, with a `///` doc comment:
  - `id` text PK, uuid client default
  - `workoutId` text `references(Workouts, #id, onDelete: KeyAction.cascade)`
  - `exerciseId` text `references(Exercises, #id)`
  - `equipmentId` text nullable `references(Equipments, #id)`
  - `setNumber` int
  - `durationSeconds` int ("`> 0` when logged by the user; `0` only for converted sets")
  - `weight` real nullable ("kg; `null` = no weight")
  - `isCompleted` bool, default `true`
  - `dateLogged` datetime, default `currentDateAndTime`

  Register both new tables in the `@DriftDatabase(tables: [...])` list.
- [X] T007 In `lib/persistance/database.dart`, set `schemaVersion => 2` and add a `///`-documented `MigrationStrategy get migration`:
  - `onCreate: (m) => m.createAll()`
  - `onUpgrade: (m, from, to)`: when `from < 2`, call a private documented `_migrateToV2(Migrator m)` that, inside `transaction(() async { ... })`, runs `m.createTable(programTimedExercises)`, `m.createTable(workoutTimedSets)`, and upserts `ExerciseTypesCompanion.insert(id: const Value('4'), name: 'Timed')`.

  Do not catch errors (research R3, plan Constitution IV). The hold-exercise conversion is added in T034.
- [X] T008 Regenerate Drift code with `flutter pub run build_runner build --delete-conflicting-outputs`, and confirm `lib/persistance/database.g.dart` now defines `ProgramTimedExercise`, `ProgramTimedExercisesCompanion`, `WorkoutTimedSet` and `WorkoutTimedSetsCompanion`.
- [X] T009 Add the database API from contracts/database.md to `lib/persistance/database.dart`, each with a `///` doc comment:
  - `addTimedExerciseToDay({required workoutDayId, required exerciseId, String? equipmentId, required List<int> setsSeconds, int? restTimer})`: `orderInProgram` = the count of strength + cardio + hybrid + timed rows for the day; `setsSeconds` stored with `jsonEncode`.
  - `deleteProgramTimedExercise(String id)`.
  - `updateProgramTimedExercise(ProgramTimedExercisesCompanion companion, String id)`.
  - `getTimedSetsForExercise(String exerciseId)`: completed rows, `dateLogged` descending.
- [X] T010 Update the existing methods in `lib/persistance/database.dart` to include timed rows:
  - `addStrengthExerciseToDay`, `addCardioExerciseToDay` and `addHybridExerciseToDay` add the timed row count to `orderInProgram`.
  - `deleteProgram` deletes `programTimedExercises` where `workoutDayId.isIn(dayIds)`.
  - `reorderExercisesInDay` gets an `else if (vol.isTimed)` branch that writes `ProgramTimedExercisesCompanion(orderInProgram: Value(i))`.
  - `watchWorkoutDaysWithExercises` gets a `timedQuery`, mirroring `hybridQuery` (join exercises, equipments, primary muscle group). Switch `CombineLatestStream.combine3` to `combine4`, and map timed rows to `ExerciseWithVolume(volume: ProgramExerciseVolume.timed(volume), equipment: equipment, ...)`.
- [X] T011 [P] Extend `lib/persistance/composites.dart`:
  - Add the private field `_timed` and the constructor `ProgramExerciseVolume.timed(ProgramTimedExercise data)`, which sets the other three to null. Set `_timed = null` in the existing constructors.
  - Add the getters `timed`, `isTimed`, and `setsSeconds` (raw JSON, default `'[60]'`).
  - Add `setsSecondsList` (parsed `List<int>`, fallback `[60]`) and `setsSecondsLabel` (uses `formatDuration` from T012; `"N sets"` when every target is 0).
  - Make the shared getters `id`, `workoutDayId`, `exerciseId`, `orderInProgram`, `equipmentId` and `restTimer` fall through to `_timed` so none ends in a bare `_hybrid!` null check.
  - Add `bool get isTimed => volume.isTimed;` to `ExerciseWithVolume`.
  - Update the class doc comments to mention timed.
- [X] T012 [P] Create `lib/utils/duration_format.dart` with a `///`-documented top-level `String formatDuration(int seconds)`: `m:ss` below 3600, `h:mm:ss` from 3600 up.
- [X] T013 [P] Update `lib/persistance/seed_data.dart`:
  - Add `'4': 'Timed'` to the `exerciseTypes` map.
  - Update the `seedDatabase` doc comment's "Seeds:" list to "Exercise types (Strength, Cardio, Hybrid, Timed)".
  - Do NOT add an every-start rename/retype loop for Timed (research R4).
- [X] T014 [P] In `assets/data/exercises.csv`, change the type column (second field) from `1` to `4` for exactly these rows: `Plank`, `Side Plank`, `Copenhagen Plank`, `Wall Sit`, `Hollow Body Hold`, `L-Sit` and `Isometric Curl Hold`.
  - Leave `Plank Hip Dip`, `Plank Reach`, `Plank Row`, `L-Sit Pull-Up` and `Dead Bug` unchanged.
- [X] T015 Run `flutter test test/utils/duration_format_test.dart test/persistance/composites_test.dart test/persistance/database_test.dart` and make T002–T004 pass.

**Checkpoint**: Schema v2 exists on fresh installs, timed program entries flow through the
shared stream, and the seeded holds are Timed on a fresh install.

---

## Phase 3: User Story 2 – Create a timed exercise and add it to a program (Priority: P1)

**Goal**: The user can create a Timed exercise and plan it on a workout day with per-set
target durations and a rest timer, then edit, reorder and remove it.

**Independent Test**: quickstart §2. Create "Dead Hang" as Timed, add it with 3 × 0:45 and a
60 s rest, edit it to 1:00 / 0:45 / 0:30, and check the day's label.

### Implementation for User Story 2

- [X] T016 [US2] Update `lib/controllers/build_program_controller.dart`:
  - `addExerciseToDay` gets a named parameter `List<int> setsSeconds = const [60]` and routes `exercise.exerciseTypeId == '4'` to `db.addTimedExerciseToDay(workoutDayId: dayId, exerciseId: exercise.id, equipmentId: equipmentId, setsSeconds: setsSeconds, restTimer: restTimer)`.
  - `updateExerciseInDay` gets `List<int> setsSeconds = const [60]` and routes `volume.isTimed` to `db.updateProgramTimedExercise(ProgramTimedExercisesCompanion(exerciseId, equipmentId, setsSeconds: jsonEncode(setsSeconds), restTimer), volume.id)`.
  - `removeExerciseFromDay` routes `volume.isTimed` to `db.deleteProgramTimedExercise`.
  - Update the doc comments to describe the timed routing.
- [X] T017 [P] [US2] In `lib/widgets/create_exercise_dialog.dart`, make `_getExerciseSubtitle` return `'Time'` when the type name contains `'timed'`.
- [X] T018 [US2] In `lib/widgets/add_exercise_dialog.dart`:
  - Add `bool get _isTimed` / `_exerciseIsTimed(Exercise)` helpers (`exerciseTypeId == '4'`).
  - Add a documented `_buildTimedConfig()`: an equipment selector like hybrid; a per-set list of target durations, each a minutes field + a seconds field with `FilteringTextInputFormatter.digitsOnly` and `MaxValueInputFormatter` capping seconds at 59; add/remove-set buttons like the strength per-set reps UI; and the rest-timer input. Default: 3 sets of 60 s.
  - Show it when `_isTimed`, and enable confirm under the same equipment rule as hybrid.
  - On confirm, call `controller.addExerciseToDay(..., setsSeconds: <minutes*60+seconds per set>)`.
  - In the exercise list, give timed exercises the icon `Icons.timer_outlined` and the subtitle `'Timed'`.
  - Make sure the strength-only equipment/reps widgets are hidden for timed (the conditions that currently read `_isCardio || _isHybrid`).
- [X] T019 [US2] In `lib/widgets/edit_program_exercise_dialog.dart`:
  - Add `_isTimed` / `_exerciseIsTimed` helpers and a `_buildTimedConfig()` like T018, pre-filled from `widget.exerciseWithVolume.volume.setsSecondsList` and `restTimer`.
  - Load equipment for timed exercises in the init block that currently checks `isHybrid || !isCardio`.
  - On confirm, call `controller.updateExerciseInDay(..., setsSeconds: ...)`.
  - Give timed list items the timer icon and `'Timed'` subtitle.
  - The replacement list is already limited to the same type via `_originalTypeId`; keep that.
- [X] T020 [US2] In `lib/pages/build_program.dart`, extend the exercise tile subtitle chain with an `ex.isTimed` branch showing `'Timed • ${ex.equipment != null ? '${ex.equipment!.name} • ' : ''}${ex.volume.setsSecondsLabel}'`, and a timer leading icon if icons are chosen per type there. It must not reach the strength branch's `ex.equipment!`.
- [X] T021 [P] [US2] In `lib/widgets/workout_information_dialog.dart`, add a `vol.isTimed` branch to `_estimatedDurationSeconds`: `sum(setsSecondsList) + (sets × restTimer) + _equipmentC(equipmentId)`. Update the function's doc comment with the timed formula.

**Checkpoint**: A timed exercise can be created, planned, edited, reordered and removed; the
program screen shows "Timed • … • 3 × 0:45".

---

## Phase 4: User Story 1 – Log a timed exercise during a workout (Priority: P1) 🎯 MVP

**Goal**: The user logs each set's time, typed in or captured with the stopwatch, with an
optional weight. Previous values are shown as references, and extra sets and auto-advance
work as for the other types.

**Independent Test**: quickstart §3. Log Dead Hang with typed, stopwatch and
screen-locked stopwatch times; check validation, the extra set with 10 kg, and the
references in the next workout.

### Tests for User Story 1 (write first; they must fail before implementation)

- [X] T022 [US1] Extend `test/controllers/active_workout_controller_test.dart` with a `Timed logging` group, following the file's existing setup. Seed a workout day with a timed program entry `setsSeconds [60,60,60]`, `restTimer 60`.
  - `lastTimedSets` is prefetched on setup.
  - `logTimedSet(durationSeconds: 75)` inserts a row with 75 s and `weight == null`, marks `isSetCompleted`, starts the rest timer and returns `true`.
  - `weightKg: 10` stores `10.0`.
  - `durationSeconds: 0` returns `false` and inserts nothing.
  - `weightKg: -5` returns `false` and inserts nothing.
  - `unlogTimedSet` sets `isCompleted = false` and clears `isSetCompleted`.
  - `getPastTimedSetData` skips `durationSeconds == 0` rows.
  - `getLastTimedWeight` returns the newest non-null weight.
  - `shouldAutoAdvance` stays `false` after sets 1–3 when one extra set was added, and becomes `true` after set 4 (the regression case from feature 001, for timed).
- [X] T023 [US1] In the same file, add a `Stopwatch` group, constructing the controller with an injected `clock` that the test advances manually. Cover the contract table:
  - `start("0-1-1")`, +52.9 s, `stop()` → returns `52`, clears `runningStopwatchKey`, and sets `stopwatchResults["0-1-1"] == 52`.
  - `start("0-1-1")`, +10 s, `start("0-1-2")` → `stopwatchResults["0-1-1"] == 10`, and the running key is `"0-1-2"`.
  - The clock jumps +300 s with no ticks → `stop()` returns 300.
  - `discardStopwatch()` and `onClose()` leave no result.
  - `swapExercise` discards a running stopwatch.
- [X] T024 [US1] In the same file, add a `Swap and add to timed` group:
  - Swapping a strength exercise with 3 sets for a Timed exercise yields `volume.isTimed`, `setsSecondsList == [0,0,0]` and the same `restTimer`.
  - `addExerciseDuringWorkout` with a Timed exercise appends a timed volume with `setsSecondsList == [60,60,60]`.

### Implementation for User Story 1

- [X] T025 [US1] In `lib/controllers/active_workout_controller.dart`, add construction and state:
  - Constructor: `ActiveWorkoutController(this.workoutDayId, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;`, with a doc comment on `_clock`.
  - Rx fields, each documented: `lastTimedSets` (`RxMap<String, List<WorkoutTimedSet>>`), `runningStopwatchKey` (`RxnString`), `stopwatchElapsedSeconds` (`RxInt`) and `stopwatchResults` (`RxMap<String, int>`), plus private `_stopwatchStartedAt` and `_stopwatchTicker`.
  - In `_setupWorkout`, add a `timedQuery` mirroring `hybridQuery` over `db.programTimedExercises`, map it to `ProgramExerciseVolume.timed`, and prefetch `lastTimedSets` via `db.getTimedSetsForExercise` in an `else if (item.isTimed)` branch before the strength `else`.
- [X] T026 [US1] In `lib/controllers/active_workout_controller.dart`, implement per contracts/controllers.md, each documented:
  - `Future<bool> logTimedSet({exerciseIndex, exerciseId, equipmentId, durationSeconds, double? weightKg, setNum, int? restSeconds})`:
    - `durationSeconds < 1` → `AppSnackbar.error('Enter a duration')`, return false.
    - `weightKg != null && weightKg < 0` → `AppSnackbar.error("Weight can't be negative")`, return false.
    - If this row's stopwatch is running, call `stopStopwatch()` first.
    - Insert a `WorkoutTimedSetsCompanion.insert(..., weight: Value(weightKg), isCompleted: const Value(true))` into `db.workoutTimedSets`.
    - Add `"$exerciseIndex-$equipmentId-$setNum"` to `completedSets` and start the rest timer when `restSeconds != null`.
    - Return true. On a database error, call `AppErrorHandler.showSystemError` and return false.
  - `unlogTimedSet(...)`: mirrors `unlogHybridSet` on `db.workoutTimedSets`.
  - `WorkoutTimedSet? getPastTimedSetData(exerciseId, setNum, equipmentId)`: like `getPastHybridSetData`, but skips `durationSeconds == 0`.
  - `double? getLastTimedWeight(String exerciseId)`: first non-null `weight` in `lastTimedSets[exerciseId]`.
- [X] T027 [US1] In `lib/controllers/active_workout_controller.dart`, implement the stopwatch, each documented:
  - `void startStopwatch(String key)`:
    - If another key is running, write its elapsed time to `stopwatchResults[oldKey]` first.
    - Set `runningStopwatchKey = key`, `_stopwatchStartedAt = _clock()` and `stopwatchElapsedSeconds = 0`.
    - Start a 1 s `Timer.periodic` that sets `stopwatchElapsedSeconds = _clock().difference(_stopwatchStartedAt!).inSeconds`.
  - `int stopStopwatch()`: computes elapsed via `_clock()` (whole seconds, rounded down), writes `stopwatchResults[key]`, cancels the ticker, clears the key, and returns elapsed; returns 0 when none is running.
  - `void discardStopwatch()`: cancels and clears without writing a result.
  - Call `discardStopwatch()` at the start of `swapExercise` and in `onClose`.
- [X] T028 [US1] In `lib/controllers/active_workout_controller.dart`:
  - `swapExercise` gets an `isNewTimed = newExercise.exerciseTypeId == '4'` branch that:
    - loads equipment as for strength and prefetches `lastTimedSets`;
    - builds `ProgramExerciseVolume.timed(ProgramTimedExercise(id: originalItem.volume.id, workoutDayId, exerciseId: newExercise.id, equipmentId: newEquip?.id, orderInProgram, setsSeconds: jsonEncode(List.filled(n, 0)), restTimer: originalItem.volume.restTimer))`, where `n` = the original planned set count (`setsSecondsList`/`setsDistancesList`/`setsRepsList` length, or 1 for cardio).
  - `addExerciseDuringWorkout` gets a timed branch defaulting to `setsSeconds [60,60,60]`, with the `lastTimedSets` prefetch.
  - Check that no other `else` in this file treats timed as strength.
- [X] T029 [US1] In `lib/widgets/exercise_workout_card.dart`:
  - Header label: add `item.isTimed ? 'Timed'` before the muscle-group fallback.
  - Pass `isTimed: item.isTimed` to `ExerciseHistoryDialog`.
  - Add an `else if (item.isTimed)` branch rendering a new `TimedLogSection(item:, exerciseIndex:, alternatives:)` before the strength `else`.
- [X] T030 [US1] In `lib/widgets/exercise_workout_card.dart`, add the documented widgets `TimedLogSection` (Stateful) and `TimedSetRow` (Stateful), modelled on `HybridLogSection` / `HybridSetRow`. All data comes through `ActiveWorkoutController` and `SettingsController`, never `AppDatabase` (research R11).
  - **Section**: an equipment `ChoiceChip`s row like hybrid; one `TimedSetRow` per set up to `getTotalSetsForExercise(exerciseIndex, volume.setsSecondsList.length, equipmentId)`; add/remove extra-set buttons.
  - **Row fields**: a minutes field and a seconds field (`digitsOnly`, seconds capped at 59 with `MaxValueInputFormatter`), pre-filled from the planned target when it is > 0, otherwise empty. Show a hint with the previous duration from `getPastTimedSetData`, rendered with `formatDuration`.
  - **Row stopwatch**: a start/stop `IconButton` that calls `startStopwatch(rowKey)` / `stopStopwatch()`. While running, show `formatDuration(stopwatchElapsedSeconds)` inside `Obx`. When `stopwatchResults[rowKey]` appears, write it into the minutes/seconds fields and remove the entry.
  - **Row weight**: a collapsed "+ weight" toggle revealing a weight field in the user's unit. It starts expanded and filled when `getLastTimedWeight` is non-null (converted via `SettingsController.fromKg`). An empty field means `weightKg: null`; otherwise use `SettingsController.toKg`.
  - **Row log/unlog button**: log calls `logTimedSet(...)`; on `true`, it auto-advances with `shouldAutoAdvance` exactly like `HybridSetRow`. Unlog calls `unlogTimedSet`.
- [X] T031 [P] [US1] In `lib/widgets/swap_exercise_dialog.dart`, show timed exercises with `Icons.timer_outlined` and the subtitle `'Timed'`, and load default equipment for them as for strength.
- [X] T032 [P] [US1] In `lib/widgets/add_workout_exercise_dialog.dart`, add `_isTimed` / `_exerciseIsTimed` helpers, the timer icon and `'Timed'` subtitle in the list, and allow equipment selection for timed exercises as for hybrid.
- [X] T033 [US1] Run `flutter test test/controllers/active_workout_controller_test.dart` and make T022–T024 pass.

**Checkpoint**: A timed workout can be logged end to end (quickstart §3). This is the MVP,
together with US2.

---

## Phase 5: User Story 4 – Existing data keeps working after the update (Priority: P1)

**Goal**: Upgrading from schema v1 keeps all data and converts the seven built-in holds to
Timed, all-or-nothing.

**Independent Test**: quickstart §5. Install over the current release and check Plank,
Bench Press and Plank Row. In tests, `test/persistance/migration_test.dart`.

### Tests for User Story 4 (write first; they must fail before implementation)

- [X] T034 [US4] Create `test/persistance/migration_test.dart`:
  - A documented helper builds a **v1** in-memory database with `NativeDatabase.memory(setup: (raw) { ... })`. It executes the v1 `CREATE TABLE` statements for every v1 table, taken from the pre-change `database.g.dart` (via `git show HEAD:lib/persistance/database.g.dart`) or written by hand to match the v1 columns in data-model.md "Unchanged tables". It then inserts v1 rows and runs `PRAGMA user_version = 1`.
  - Opening `AppDatabase.forTesting(...)` on that executor then runs `onUpgrade`.
  - Seed data:
    - exercise types 1–3;
    - exercises Plank, Wall Sit, Isometric Curl Hold, Bench Press and Plank Row (all type `'1'`);
    - one workout with Plank 3 × (45 reps, 0 kg), Wall Sit 1 × (30 reps, 20 kg), Bench Press 2 sets, Plank Row 1 set, and one unlogged (`is_completed = 0`) Plank set;
    - a day with Plank `setsReps [30,30,30]`, `restTimer 60`, `orderInProgram 2`, and Bench Press at order 0.
  - Assert:
    - Type `'4' Timed` exists.
    - Plank, Wall Sit and Isometric Curl Hold have type `'4'`; Bench Press and Plank Row keep `'1'`.
    - The Plank timed sets have the same ids, `setNumber`, `isCompleted` and `dateLogged`, with `durationSeconds 0` and `weight null`.
    - The Wall Sit timed set has `weight 20.0`.
    - No strength sets or strength program entries remain for the converted exercises.
    - The Plank timed program entry has `setsSeconds [0,0,0]`, `restTimer 60`, `orderInProgram 2`.
    - The Bench Press and Plank Row rows are byte-for-byte unchanged.
    - The per-workout set count (strength + timed) is unchanged (SC-006).
  - Add a second test: an exercise named `"plank"` in a different case is also converted, and a renamed `"My Plank"` is not.

### Implementation for User Story 4

- [X] T035 [US4] In `lib/persistance/database.dart`, extend `_migrateToV2` inside its transaction, after table creation and the type upsert:
  - Add a documented private `static const _holdExerciseNames = {'plank', 'side plank', 'copenhagen plank', 'wall sit', 'hollow body hold', 'l-sit', 'isometric curl hold'}`.
  - `holdIds` = the ids of exercises where `name.trim().toLowerCase()` is in the set.
  - For each `workoutStrengthSets` row with `exerciseId ∈ holdIds`, insert a `WorkoutTimedSetsCompanion`: copy `id`, `workoutId`, `exerciseId`, `equipmentId`, `setNumber`, `isCompleted` and `dateLogged`; `durationSeconds: 0`; `weight: Value(row.weight > 0 ? row.weight : null)`.
  - For each `programStrengthExercises` row with `exerciseId ∈ holdIds`, insert a `ProgramTimedExercisesCompanion`: copy `id`, `workoutDayId`, `equipmentId`, `exerciseId`, `orderInProgram` and `restTimer`; `setsSeconds: jsonEncode(List.filled(n, 0))`, where `n` = the length of the parsed `setsReps`, or 1 if it cannot be parsed.
  - Delete those strength sets and strength program entries.
  - Update the exercises' `exerciseTypeId` to `'4'`.
  - Skip the conversion when `holdIds` is empty.
- [X] T036 [US4] Run `flutter test test/persistance/migration_test.dart` and make T034 pass. Also run the full `flutter test` to confirm that fresh-install databases (the `onCreate` path) are unaffected.

**Checkpoint**: Upgrading keeps all data, and the holds are Timed with "no time recorded"
history.

---

## Phase 6: User Story 3 – See progress for a timed exercise (Priority: P2)

**Goal**: The tracking screen shows Longest hold (default) and Total time charts plus a
history list for timed exercises.

**Independent Test**: quickstart §4 (charts and history for Dead Hang), and §5.4 (converted
Plank shows "no time recorded" and no chart points).

### Tests for User Story 3 (write first; they must fail before implementation)

- [X] T037 [US3] Extend `test/controllers/tracking_controller_test.dart` with a `Timed exercise` group, following the file's existing setup. Seed timed sets over two days:
  - Day 1: 60 s and 45 s on equipment A, 30 s on equipment B.
  - Day 2: 0 s and 0 s (converted).
  - Day 3: 90 s.

  Assert:
  - `selectExercise` on a type `'4'` exercise fills `timedSets` oldest first, sets `selectedChartType == ChartType.timedLongestHold` and builds `availableEquipment`.
  - For equipment A, `timedLongestHoldData` gives `[(day1, 60), (day3, 90)]` with no day-2 point.
  - `timedTotalTimeData` gives `[(day1, 105), (day3, 90)]`.
  - `activeChartData` switches with `selectedChartType`.
  - `clearSelection` clears `timedSets`.

### Implementation for User Story 3

- [X] T038 [US3] In `lib/controllers/tracking_controller.dart`:
  - Add `timedLongestHold` and `timedTotalTime` to `ChartType`, each with a `///` doc comment (no new `//` comments).
  - Add the documented field `timedSets` (`RxList<WorkoutTimedSet>`) and clear it in `selectExercise` and `clearSelection`.
  - Add a `typeId == '4'` branch in `selectExercise`: load `db.getTimedSetsForExercise`, reverse it into `timedSets`, build equipment exactly like the hybrid branch, and default `selectedChartType` to `timedLongestHold`.
  - Add the documented getters `timedLongestHoldData` and `timedTotalTimeData`: group by calendar day, filter by `selectedEquipment`, skip `durationSeconds == 0`, values in seconds as `double`.
  - Map both in `activeChartData`.
  - Update the `selectedExerciseTypeId` doc comment to include `'4'=timed`.
- [X] T039 [US3] In `lib/pages/tracking.dart`:
  - Add a timed branch to the metric selector (the `typeId` switch around the cardio/hybrid `DropdownMenuItem`s) with items "Longest hold" → `ChartType.timedLongestHold` and "Total time" → `ChartType.timedTotalTime`.
  - Add chart cases that render `timedLongestHoldData` / `timedTotalTimeData`, with the Y-axis and tooltip labels formatted by `formatDuration`.
  - Show the equipment selector for timed as for hybrid.
  - Show a per-session set history for timed from `controller.timedSets`, in the same way the page shows history for the other types. Each set reads `formatDuration(durationSeconds)`, plus ` · <weight in user unit>` when the weight is non-null, or "no time recorded" when `durationSeconds == 0`.
  - Show the existing empty state when `timedSets` is empty.
- [X] T040 [US3] In `lib/widgets/exercise_history_card_widget.dart`:
  - Add the parameter `isTimed` (default `false`) to `ExerciseHistoryDialog`, and a `_TimedHistoryList` branch.
  - `_TimedHistoryList` takes `exerciseId` and reads `Get.find<ActiveWorkoutController>().lastTimedSets[exerciseId]` inside `Obx`. It does not query `AppDatabase` (research R11).
  - It groups sets by workout (newest first) and renders each set with the same text rules as T039.
- [X] T041 [US3] Run `flutter test test/controllers/tracking_controller_test.dart` and make T037 pass.

**Checkpoint**: All four stories work independently.

---

## Phase 7: Polish and cross-cutting concerns

- [X] T042 Audit every type branch listed in research R14. Run `grep -rn "isHybrid\|isCardio\|== '3'\|== '2'\|_hybrid!" lib --include=*.dart | grep -v "\.g\.dart"` and confirm that each `if/else` chain either handles `isTimed` / `'4'` explicitly or is correct for timed by construction. Fix any spot that still treats timed as strength or null-checks `_hybrid!`.
- [X] T043 [P] Check the doc comments that list the exercise types (e.g. `BuildProgramController.addExerciseToDay`, the `ProgramExerciseVolume` class comment, `ExerciseWithVolume.equipment`, `seedDatabase`) and make them mention Timed. Make sure no new inline `//` comments were added.
- [X] T044 Run `dart format .`, then `flutter analyze` (expect "No issues found!"), then `flutter test` (expect all tests pass, including the new ones). Fix any failure.
- [ ] T045 Walk through [quickstart.md](quickstart.md) §2–§6 on a device or emulator. That includes the upgrade from the current release (§5) and a fresh install (§6). Note any deviation from the listed expectations.

---

## Dependencies and execution order

### Phase dependencies

- **Setup (Phase 1)** → **Foundational (Phase 2)**, which blocks every story.
- **US2 (Phase 3)** depends on Phase 2.
- **US1 (Phase 4)** depends on Phase 2. For manual testing it also needs US2, so there is a timed exercise in a program. Its controller tests (T022–T024) seed program rows directly and only need Phase 2.
- **US4 (Phase 5)** depends on Phase 2 only (T007 migration skeleton). It can run in parallel with US2/US1.
- **US3 (Phase 6)** depends on Phase 2. T040 depends on T025 (`lastTimedSets`).
- **Polish (Phase 7)** depends on all stories.

### Within phases

- Tests are written before the implementation they cover: T002–T004 before T005–T014, T022–T024 before T025–T032, T034 before T035, and T037 before T038–T040.
- T005 → T006 → T007 → T008 → T009 → T010, all in the same file (`database.dart`) plus codegen.
- T011 needs T008 (generated `ProgramTimedExercise`) and T012 (`formatDuration`).
- T025 → T026 → T027 → T028, all in the same file.
- T029 → T030, same file.

### Parallel opportunities

- Phase 2: T002, T003 and T004 (different test files); then T011, T012, T013 and T014 once T008 is done (different files).
- Phase 3: T017 and T021 alongside T016/T018–T020.
- Phase 4: T031 and T032 alongside T029/T030.
- Across stories: after Phase 2, US4 (T034–T036) can proceed alongside US2/US1.

## Parallel example: Phase 2

```text
Task: "T002 Create test/utils/duration_format_test.dart"
Task: "T003 Extend test/persistance/composites_test.dart with ProgramExerciseVolume.timed"
Task: "T004 Extend test/persistance/database_test.dart with Timed program exercises"
# after T008:
Task: "T011 Extend lib/persistance/composites.dart"
Task: "T012 Create lib/utils/duration_format.dart"
Task: "T013 Update lib/persistance/seed_data.dart"
Task: "T014 Update assets/data/exercises.csv"
```

## Parallel example: User Story 1

```text
Task: "T031 Timed label/icon in lib/widgets/swap_exercise_dialog.dart"
Task: "T032 Timed support in lib/widgets/add_workout_exercise_dialog.dart"
```

## Implementation strategy

### MVP (US2 + US1)

1. Phase 1 → Phase 2 (foundation, fresh-install holds are Timed).
2. Phase 3 (US2): timed exercises can be created and planned.
3. Phase 4 (US1): timed sets can be logged.
4. **Stop and validate** with quickstart §2–§3 on a fresh install.

### Incremental delivery

5. Phase 5 (US4): upgrade path. **Required before any release to existing users**, because
   schema v2 without the conversion would leave holds as Strength.
6. Phase 6 (US3): tracking charts and history.
7. Phase 7: audit, format, analyze, test, and the full quickstart.

### Notes

- Never commit or push. The user does that themselves (CLAUDE.md).
- `database.g.dart` must be regenerated (T008) after every table change and kept with the
  migration.

## Implementation notes (2026-09-26)

Deviations from the task text, made during `/speckit-implement`:

- **AppSnackbar test hook**: `AppSnackbar` gained `overrideErrorForTest` / `resetForTest`,
  mirroring `AppErrorHandler`, because `Get.snackbar` needs an overlay that controller tests
  don't have. Tested in `test/utils/app_snackbar_test.dart`.
- **Shared formatters**: `formatTimedSet` was added next to `formatDuration` in
  `lib/utils/duration_format.dart`. It formats "1:15 · 10 kg" and "no time recorded", and is
  used by both history views.
- **Shared editor widget**: the per-set target duration editor used by both program dialogs
  is `lib/widgets/timed_sets_editor.dart`.
- **Order count helper**: `_countExercisesInDay` counts all four program tables. As a side
  effect, it also fixes strength and cardio entries that previously ignored hybrid entries
  when computing `orderInProgram`.
- **T040**: the workout history dialog loads data through
  `ActiveWorkoutController.loadTimedHistory`, which reads fresh data and includes the current
  session. It does not read the prefetched `lastTimedSets`.
- **T039**: the tracking page shows timed history in a dialog opened from a history button,
  because the page has no inline history list for any type. `_WeightChart` gained an optional
  `axisLabelFormatter` so the y-axis shows `m:ss`.
- **T038**: `activeChartData` now maps every `ChartType`, not only the strength ones.
- **T044**: `flutter analyze` still reports the 9 info-level issues that existed before this
  feature. No new issues were introduced.
- **T045**: not done. It needs a device or emulator, including one with the current release
  installed for the upgrade check (quickstart §5).
