# Implementation Plan: Auto-Advance Only After All Sets Are Logged

**Branch**: `001-fix-auto-advance-extra-sets` | **Date**: 2026-09-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-fix-auto-advance-extra-sets/spec.md`

## Summary

After a set is logged, the workout page view moves to the next exercise if "all sets are done".
The check lives in two widget rows (`SetLogRow` for strength and `HybridSetRow` for hybrid) in
`lib/widgets/exercise_workout_card.dart`. It only iterates over `totalPlannedSets`, the
program-prescribed count, and ignores `extraSetsCount`. Any extra set added during the workout
is therefore skipped.

The fix moves the decision into `ActiveWorkoutController` as two public methods:

- `isExerciseComplete` checks every set up to `getTotalSetsForExercise`, which already combines
  planned sets and extra sets.
- `shouldAutoAdvance` also requires a next exercise to exist.

Both widget rows call `shouldAutoAdvance` in place of their duplicated inline check. The
animation call itself stays in the widget. A regression test in the existing controller test
file covers the reported scenario.

## Technical Context

**Language/Version**: Dart ^3.11.0, Flutter 3.41.1 (stable)

**Primary Dependencies**: GetX ^4.7.3 (state), Drift ^2.31.0 (persistence; not touched)

**Storage**: Drift/SQLite; no schema change

**Testing**: `flutter test`; controller unit tests using the in-memory database
(`AppDatabase.forTesting(NativeDatabase.memory())` plus `setupTestSqlite` from
`test/test_helpers.dart`)

**Target Platform**: Android/iOS mobile app

**Project Type**: mobile-app (single Flutter project)

**Performance Goals**: N/A. The check is O(number of sets) and runs once per logged set.

**Constraints**: No change to the transition animation (400 ms, `easeInOut`) or to the cardio
flow.

**Scale/Scope**: 1 controller, 1 widget file (2 call sites), 1 test file

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. GetX State Management | Logic lives in the existing `ActiveWorkoutController`; state stays in Rx fields (`completedSets`, `extraSetsCount`, `exercisesWithVolume`) | PASS |
| II. Layered Structure | Decision logic moves from `widgets/` into `controllers/`; no new folders; no DB access from widgets | PASS |
| III. Drift-Only Persistence | No schema or persistence change | PASS (N/A) |
| IV. Error Handling Split | No new failure paths; `logSet`/`logHybridSet` keep their existing `AppErrorHandler` handling. If logging fails, the set is not marked complete, so no advance happens. | PASS |
| V. Testing Discipline | Regression test for the bug plus unit tests for the new controller methods in `test/controllers/active_workout_controller_test.dart`, using the in-memory DB; no UI test | PASS |
| VI. Code Quality & Documentation | New public methods get `///` doc comments; no inline comments; `dart format` and `flutter analyze` clean | PASS |
| VII. Simplicity | No new layers, packages or abstractions; two small methods on an existing controller | PASS |

**Post-design re-check**: PASS. The design in research.md, data-model.md and contracts/ adds no
new violations.

## Project Structure

### Documentation (this feature)

```text
specs/001-fix-auto-advance-extra-sets/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── active_workout_controller.md
├── checklists/
│   └── requirements.md
└── tasks.md             # created by /speckit-tasks
```

### Source Code (repository root)

```text
lib/
├── controllers/
│   └── active_workout_controller.dart   # add isExerciseComplete, shouldAutoAdvance
└── widgets/
    └── exercise_workout_card.dart       # SetLogRow + HybridSetRow call shouldAutoAdvance

test/
└── controllers/
    └── active_workout_controller_test.dart  # regression + unit tests
```

**Structure Decision**: Use the existing flat layered layout (Principle II). No new files in
`lib/`; the only test changes are additions to the existing controller test file.

## Complexity Tracking

No constitution violations. This section is intentionally empty.
