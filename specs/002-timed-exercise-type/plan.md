# Implementation Plan: Timed Exercise Type

**Branch**: `002-timed-exercise-type` | **Date**: 2026-09-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/002-timed-exercise-type/spec.md`

## Summary

This adds a fourth exercise type, **Timed**, whose sets record a duration and an optional
weight. The duration is typed in or captured with a per-set stopwatch.

**Storage.** Following the existing one-table-per-type pattern, the feature adds
`ProgramTimedExercises` and `WorkoutTimedSets`. It raises the Drift `schemaVersion` from
1 to 2, with an explicit `MigrationStrategy`.

**Upgrade.** In one transaction, the upgrade:
- creates the new tables;
- adds exercise type `'4' Timed`;
- converts the seven built-in hold exercises (Plank, Side Plank, Copenhagen Plank, Wall Sit,
  Hollow Body Hold, L-Sit, Isometric Curl Hold), moving their strength sets and program
  entries into the timed tables with `durationSeconds = 0` ("no time recorded"), keeping any
  weight above 0 kg, and keeping the number of sets.

No existing column changes, so all other data is untouched.

**Where Timed is handled.** Every branch that today reads "else = strength" gets an explicit
timed branch: composites, database queries, the three controllers, and the workout,
program-builder and tracking UI. Tracking gains the **Longest hold** and **Total time**
metrics.

## Technical Context

**Language/Version**: Dart SDK ^3.11, Flutter 3.47.5

**Primary Dependencies**: GetX 4.7.3 (state), Drift 2.31.0 + drift_dev (persistence and
codegen), fl_chart 0.69 (charts). No new packages.

**Storage**: SQLite through Drift (`reptrack.sqlite`); schema v1 → v2.

**Testing**: `flutter_test` with an in-memory `NativeDatabase.memory()` and
`setupTestSqlite()` from `test/test_helpers.dart`. There are no widget tests.

**Target Platform**: Android and iOS (Flutter mobile app).

**Project Type**: Mobile app, single project (`lib/`, `test/`).

**Performance Goals**: The migration finishes within normal app start time for a single
user's history (thousands of sets). The stopwatch display updates once per second.

**Constraints**: Works offline. The migration is all-or-nothing and runs exactly once.
Stopwatch accuracy does not depend on the app staying in the foreground.

**Scale/Scope**:
- 2 new tables, 1 migration step.
- About 16 source files touched (list in [research.md §R14](research.md#r14-places-where-else-currently-means-strength)).
- 1 new util (`lib/utils/duration_format.dart`).
- 1 new test file for the migration and 1 for the duration util; 4 existing test files
  extended.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Check | Status |
|-----------|-------|--------|
| I. GetX | Timed logging, stopwatch and history state live in `ActiveWorkoutController`; tracking state lives in `TrackingController`; all as Rx fields read via `Obx`. No new screens, so no new controllers. | ✅ |
| II. Layered structure | Tables and migration in `lib/persistance/`, logic in `lib/controllers/`, UI in `lib/widgets/` and `lib/pages/`, formatter in `lib/utils/`. New timed UI code reads through controllers only (R11). Earlier direct database calls in widgets are left as they are and are not extended. | ✅ |
| III. Drift-only persistence | Schema change in `database.dart` + regenerated `database.g.dart` + `schemaVersion` 1 → 2 with `onUpgrade`. The new kind gets both a program table (`ProgramTimedExercises`) and a set table (`WorkoutTimedSets`), matching strength, cardio and hybrid. No sqflite code. | ✅ |
| IV. Error handling split | Empty/zero duration and negative weight → `AppSnackbar.error`. Database failures in log/unlog/add/update/migration paths → `AppErrorHandler.showSystemError`. The migration does not catch errors: a failure rolls back the transaction and surfaces through the existing startup error path in `main.dart`. | ✅ |
| V. Testing | Migration, database, composites, controllers and util are tested with the in-memory database. There is no bug fix, so no regression test is required. | ✅ |
| VI. Code quality | `///` doc comments on all new classes and methods, no inline comments, `const` constructors, `dart format`, `flutter analyze` clean. | ✅ (enforced during implementation) |
| VII. Simplicity | No repository or domain layer, no new packages. Migration testing uses a hand-built v1 database instead of `drift_dev make-migrations` (R12). | ✅ |
| Implementation constraints | All four spec ambiguities were resolved in `/speckit-clarify`. The remaining design choices are recorded in research.md, not assumed silently. | ✅ |

**Post-design re-check (after Phase 1)**: still passing. The contracts add one optional
constructor parameter (`clock`) to `ActiveWorkoutController` and no new layers. Complexity
Tracking is empty.

## Project Structure

### Documentation (this feature)

```text
specs/002-timed-exercise-type/
├── spec.md
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1–R14
├── data-model.md        # Phase 1: tables, hold list, migration steps
├── quickstart.md        # Phase 1: validation guide
├── contracts/
│   ├── database.md      # AppDatabase API + migration behaviour
│   └── controllers.md   # Controller, composite and util APIs
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
assets/data/
└── exercises.csv                    # 7 hold exercises: type 1 → 4

lib/
├── persistance/
│   ├── database.dart                # +2 tables, schemaVersion 2, MigrationStrategy,
│   │                                #   timed CRUD/queries, 4-way stream combine
│   ├── database.g.dart              # regenerated
│   ├── composites.dart              # ProgramExerciseVolume.timed, isTimed, setsSeconds*
│   └── seed_data.dart               # '4': 'Timed'
├── controllers/
│   ├── active_workout_controller.dart  # logTimedSet/unlogTimedSet, lastTimedSets,
│   │                                   #   stopwatch, clock, swap/add support
│   ├── build_program_controller.dart   # timed add/update/remove routing
│   └── tracking_controller.dart        # timedSets, 2 ChartTypes, data getters
├── pages/
│   ├── build_program.dart           # "Timed" label, setsSecondsLabel
│   └── tracking.dart                # timed metric selector + chart + history
├── utils/
│   └── duration_format.dart         # NEW: formatDuration
└── widgets/
    ├── exercise_workout_card.dart   # TimedLogSection, TimedSetRow (stopwatch, weight)
    ├── add_exercise_dialog.dart     # per-set target duration inputs
    ├── edit_program_exercise_dialog.dart
    ├── add_workout_exercise_dialog.dart
    ├── exercise_history_card_widget.dart  # timed history list (data via controller)
    ├── swap_exercise_dialog.dart    # Timed label/icon
    ├── workout_information_dialog.dart    # duration estimate for timed
    └── create_exercise_dialog.dart  # subtitle "Time"

test/
├── persistance/
│   ├── migration_test.dart          # NEW
│   ├── database_test.dart
│   └── composites_test.dart
├── controllers/
│   ├── active_workout_controller_test.dart
│   └── tracking_controller_test.dart
└── utils/
    └── duration_format_test.dart    # NEW
```

**Structure Decision**: This is the existing single Flutter project with the constitution's
layered `lib/` layout. No new directories are needed; the only new source file is
`lib/utils/duration_format.dart`.

## Implementation Order (for /speckit-tasks)

1. **Foundation**: tables, migration and regenerated code, seed plus CSV,
   `duration_format`, composites. Tests: migration, database, composites, util.
2. **Program builder (Story 2)**: `BuildProgramController` routing, add/edit dialogs, labels,
   create-dialog subtitle.
3. **Workout logging (Story 1)**: controller log/unlog/references/weight, stopwatch with
   `clock`, `TimedLogSection`/`TimedSetRow`, swap/add-during-workout, duration estimate.
   Tests: controller.
4. **Tracking (Story 3)**: `TrackingController` data and chart types, tracking page, history
   list. Tests: tracking controller.
5. **Polish**: audit every `else`-means-strength branch from R14, run `dart format` /
   `flutter analyze` / `flutter test`, and walk through quickstart §2–§6.

## Complexity Tracking

No constitution violations; nothing to justify.
