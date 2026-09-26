# Implementation Plan: Create Exercise From Swap Dialog

**Branch**: `feature/add-exercise-during-workout` | **Date**: 2026-09-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/005-create-exercise-in-swap/spec.md`

## Summary

This adds a "+" icon to the top right of the swap exercise dialog during a workout. It opens the existing `CreateExerciseDialog`. When that dialog returns a new `Exercise`, the swap dialog swaps it in with the existing `ActiveWorkoutController.swapExercise` and closes. Cancelling leaves everything unchanged.

Both the new "+" path and the existing list tap go through one private `_swapTo` helper, so they behave the same. To support this, `swapExercise` gets an optional `newEquipmentId`. When it's left out, the controller's existing "first compatible equipment" fallback applies. The list of exercises to swap to is now loaded through a new `ActiveWorkoutController.getSwapCandidates`. Together these remove both of the swap dialog's direct database queries, so the dialog no longer touches `AppDatabase` (research R3, R7).

No schema change, no new packages, and no change to the rules for swapping between types.

## Technical Context

**Language/Version**: Dart SDK ^3.11, Flutter

**Primary Dependencies**: GetX ^4.7.3 (`Get.dialog`, `Get.back`, `Obx`) and Drift, both already used. No new packages.

**Storage**: Uses the existing Drift `exercises` and `exercise_equipment` tables through `CreateExerciseController`. No schema change.

**Testing**: `flutter_test` with the in-memory database from `test/test_helpers.dart`. New controller tests go in `test/controllers/active_workout_controller_test.dart`. No widget tests (Principle V).

**Target Platform**: Android and iOS (the existing Flutter app)

**Project Type**: Mobile app

**Performance Goals**: The new exercise appears in the workout as soon as the create dialog closes, with no noticeable delay (the same single swap as today).

**Constraints**: Must work offline, as the app already does. The swap lasts only for the current workout and doesn't change the program.

**Scale/Scope**: 2 source files changed (`swap_exercise_dialog.dart`, `active_workout_controller.dart`) and 1 test file extended.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Status |
|---|---|---|
| I. GetX State Management | No new screen. Reuses `ActiveWorkoutController` and `CreateExerciseController`. The dialogs are widgets, not screens. | ✅ |
| II. Layered Structure | Changes stay in `lib/widgets/` and `lib/controllers/`. Both of the swap dialog's existing direct database calls (`getAllExercises` in `_loadInitialData` and `getEquipmentForExercise` in the list tap) move behind `ActiveWorkoutController`, so the dialog no longer imports or calls `AppDatabase`. | ✅ (fixes an existing violation) |
| III. Drift-Only Persistence | No schema change and no sqflite. | ✅ |
| IV. Error Handling Split | Reuses `AppSnackbar` for validation and `AppErrorHandler.showSystemError` for system failures in `CreateExerciseController` and `swapExercise`. No new `catch` blocks. | ✅ |
| V. Testing Discipline | The `swapExercise` signature changes and `getSwapCandidates` is new, so tests are added for both (research R6). | ✅ |
| VI. Code Quality & Docs | `///` doc for `_swapTo` and the updated `swapExercise` doc. No inline comments. Use `const` where possible, then `dart format` and `flutter analyze`. | ✅ |
| VII. Simplicity | No new layers or packages. One small controller method (`getSwapCandidates`) is added, only to meet Principle II. | ✅ |

**Post-design re-check**: All gates still pass after Phase 1. No deviations, so Complexity Tracking is empty.

## Project Structure

### Documentation (this feature)

```text
specs/005-create-exercise-in-swap/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── swap-dialog.md
├── checklists/
│   └── requirements.md
└── tasks.md             # created by /speckit-tasks
```

### Source Code (repository root)

```text
lib/
├── controllers/
│   └── active_workout_controller.dart   # swapExercise: newEquipmentId optional; new getSwapCandidates
└── widgets/
    ├── swap_exercise_dialog.dart        # title Row with "+" button; _swapTo helper; no AppDatabase use
    └── create_exercise_dialog.dart      # unchanged, reused

test/
└── controllers/
    └── active_workout_controller_test.dart  # new swapExercise and getSwapCandidates tests
```

**Structure Decision**: Uses the existing layered structure. No new files in `lib/`.

## Complexity Tracking

No violations.
