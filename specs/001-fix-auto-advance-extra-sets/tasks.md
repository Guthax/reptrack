---

description: "Task list for Auto-Advance Only After All Sets Are Logged"
---

# Tasks: Auto-Advance Only After All Sets Are Logged

**Input**: Design documents from `/specs/001-fix-auto-advance-extra-sets/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/active_workout_controller.md, quickstart.md

**Tests**: REQUIRED. Spec FR-007 asks for a regression test, and constitution Principle V requires
tests for controller logic and a regression test for every bug fix. Write the tests first and
confirm they fail before implementing.

**Organization**: Tasks are grouped by user story (spec.md: US1 = P1, US2 = P2).

**Project rules (constitution) that apply to every task**:
- Every new public method or class gets a brief `///` doc comment.
- No inline `//` comments.
- Use `const` where possible.
- Run `dart format` after each edit.
- No new packages, files in `lib/`, layers or DB changes.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: The user story the task belongs to (US1, US2)

## Path Conventions

Single Flutter project: `lib/` and `test/` at the repository root.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Record a baseline so that new failures can be told apart from existing ones

- [X] T001 Run `flutter analyze` and `flutter test` from the repository root and note any existing failures or analyzer issues before changing code (affects `lib/` and `test/`; no edits)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Test fixtures that both user stories' tests depend on

- [X] T002 In `test/controllers/active_workout_controller_test.dart`, add these top-level private helpers above `main()`, each with a `///` doc comment:
  - `ExerciseWithVolume _strengthExercise(int i)`. It returns
    `ExerciseWithVolume(exercise: Exercise(id: 'ex$i', name: 'Exercise $i', exerciseTypeId: '1'), volume: ProgramExerciseVolume.strength(ProgramStrengthExercise(id: 'se$i', workoutDayId: 'test-day-id', exerciseId: 'ex$i', orderInProgram: i, setsReps: '[12,10,8]', weight: 100.0)))`.
    Add `import 'package:reptrack/persistance/composites.dart';` if it is not present.
  - `void _logSets(ActiveWorkoutController c, int exerciseIndex, String equipmentId, List<int> setNums)`.
    It adds `'$exerciseIndex-$equipmentId-$n'` to `c.completedSets` for each `n`, mirroring how
    existing tests mark sets completed.
  - `Future<void> _waitForSetup(ActiveWorkoutController c)`. It polls until
    `c.isLoading.value == false`, using `await Future<void>.delayed(const Duration(milliseconds: 1))`,
    and fails with `fail('setup did not finish')` after 2 seconds. It is needed because `onInit`
    runs `_setupWorkout`, which ends with `exercisesWithVolume.assignAll(...)` and would otherwise
    overwrite fixtures added in a test.

**Checkpoint**: The test file compiles and all existing tests still pass (`flutter test test/controllers/active_workout_controller_test.dart`).

---

## Phase 3: User Story 1 - Stay on the exercise until extra sets are logged (Priority: P1) 🎯 MVP

**Goal**: The page advances only when every shown set is logged, planned and extra alike (FR-001, FR-002, FR-005).

**Independent Test**: The unit tests in T003–T004 pass. On a device, an exercise with 3 planned sets and 1 extra set stays on screen after sets 1–3 and advances after set 4 (quickstart.md steps 1–4 and 6).

### Tests for User Story 1 (write first, must FAIL before T005/T006)

- [X] T003 [US1] In `test/controllers/active_workout_controller_test.dart`, add `group('auto-advance with extra sets', ...)` containing the regression test named `'regression: 3 planned + 1 extra, 3 logged does not advance'`. Each test that uses `exercisesWithVolume` first calls `await _waitForSetup(controller)` and then `controller.exercisesWithVolume.assignAll([_strengthExercise(0), _strengthExercise(1)])`. Arrange with `controller.addExtraSet(0, 'eq1')` and `_logSets(controller, 0, 'eq1', [1, 2, 3])`. Assert that `controller.isExerciseComplete(0, 3, 'eq1')` is `false` and that `controller.shouldAutoAdvance(exerciseIndex: 0, plannedSets: 3, equipmentId: 'eq1')` is `false`.
- [X] T004 [US1] In the same group in `test/controllers/active_workout_controller_test.dart`, add tests matching the `isExerciseComplete` table in `specs/001-fix-auto-advance-extra-sets/contracts/active_workout_controller.md`:
  - 3 planned + 1 extra, sets `[1, 2, 3, 4]` logged: `isExerciseComplete` is `true` and `shouldAutoAdvance` is `true`.
  - 3 planned + 1 extra, sets `[1, 2, 4]` logged (out of order): `false`.
  - Sets `[1, 2, 3]` logged under `'eq2'` while checking `'eq1'`: `false`.
  - 2 planned + 2 extra (`addExtraSet` called twice), sets `[1, 2, 3]` logged: `false`; after also logging `4`: `true`. This covers the hybrid scenario from spec US1 scenario 3; the logic is shared.

### Implementation for User Story 1

- [X] T005 [US1] In `lib/controllers/active_workout_controller.dart`, directly below `getTotalSetsForExercise`, add `bool isExerciseComplete(int exerciseIndex, int plannedSets, String equipmentId)`. It returns `true` only if `isSetCompleted(exerciseIndex, equipmentId, s)` is true for every `s` in `1..getTotalSetsForExercise(exerciseIndex, plannedSets, equipmentId)`. Add a `///` doc comment stating that planned and user-added extra sets both count.
- [X] T006 [US1] In `lib/controllers/active_workout_controller.dart`, directly below `isExerciseComplete`, add `bool shouldAutoAdvance({required int exerciseIndex, required int plannedSets, required String equipmentId})`. It returns `isExerciseComplete(exerciseIndex, plannedSets, equipmentId) && exerciseIndex < exercisesWithVolume.length - 1`. Add a `///` doc comment stating that it is `false` for the last exercise.
- [X] T007 [P] [US1] In `lib/widgets/exercise_workout_card.dart`, in `_SetLogRowState`'s log button `onPressed` (after `await controller.logSet(...)`, around line 1146), replace the whole `final allDone = List.generate(widget.totalPlannedSets, ...)` block and the `if (allDone) { ... current ... total ... }` block with the following:
  `if (controller.shouldAutoAdvance(exerciseIndex: widget.exerciseIndex, plannedSets: widget.totalPlannedSets, equipmentId: widget.equipmentId)) { controller.pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut); }`.
  Keep the animation duration and curve unchanged.
- [X] T008 [US1] In `lib/widgets/exercise_workout_card.dart`, apply the same replacement as T007 in `_HybridSetRowState`'s log button `onPressed` (after `await controller.logHybridSet(...)`, around line 1373). This depends on T007 only because both edit the same file.
- [X] T009 [US1] Run `dart format lib test` and `flutter test test/controllers/active_workout_controller_test.dart`. T003 and T004 must pass.

**Checkpoint**: The bug is fixed for strength and hybrid exercises, and the regression test passes.

---

## Phase 4: User Story 2 - Unchanged behaviour when no sets are added (Priority: P2)

**Goal**: With no extra sets, the page still advances after the last planned set. The last exercise never advances, and only logging triggers an advance (FR-003, FR-004, FR-006).

**Independent Test**: The unit tests in T010–T012 pass. On a device, an exercise without extra sets advances after its last planned set, and the last exercise does not advance (quickstart.md steps 5 and 7).

**Depends on**: T005 and T006 (the controller methods must exist). This phase does not depend on T007 or T008.

### Tests for User Story 2

- [X] T010 [P] [US2] In `test/controllers/active_workout_controller_test.dart`, add `group('auto-advance without extra sets', ...)` using the same `_waitForSetup` and two-exercise fixture as T003. With 3 planned sets and `[1, 2, 3]` logged under `'eq1'`, assert `isExerciseComplete(0, 3, 'eq1')` is `true` and `shouldAutoAdvance(exerciseIndex: 0, plannedSets: 3, equipmentId: 'eq1')` is `true`. With `[1, 2]` logged, assert both are `false`.
- [X] T011 [US2] In the same group in `test/controllers/active_workout_controller_test.dart`, add a test for the last exercise. With `exerciseIndex: 1` (the last of 2) and `[1, 2, 3]` logged under `'eq1'` for exercise 1, assert `isExerciseComplete(1, 3, 'eq1')` is `true` and `shouldAutoAdvance(exerciseIndex: 1, plannedSets: 3, equipmentId: 'eq1')` is `false`.
- [X] T012 [US2] In the same group in `test/controllers/active_workout_controller_test.dart`, add state-transition tests from `specs/001-fix-auto-advance-extra-sets/data-model.md`:
  - Log `[1, 2, 3]` so the exercise is complete, then call `controller.addExtraSet(0, 'eq1')`: `isExerciseComplete(0, 3, 'eq1')` becomes `false`.
  - Log `[1, 2, 3]`, then remove `'0-eq1-2'` from `controller.completedSets`: `isExerciseComplete` becomes `false`.
  - 3 planned + 1 extra with `[1, 2, 3]` logged, then call `controller.removeExtraSet(0, 'eq1')`: `isExerciseComplete` is `true`. No advance happens by itself, because only the log button calls `shouldAutoAdvance` (FR-003).
- [X] T013 [US2] Run `flutter test test/controllers/active_workout_controller_test.dart`. All tests from T003–T012 must pass.

**Checkpoint**: Both stories are covered by passing unit tests.

---

## Phase 5: Polish & Cross-Cutting Concerns

- [X] T014 Run `dart format lib test` and confirm there is no diff left in `lib/controllers/active_workout_controller.dart`, `lib/widgets/exercise_workout_card.dart` or `test/controllers/active_workout_controller_test.dart`
- [X] T015 Run `flutter analyze` and confirm it reports no new issues compared with the T001 baseline (constitution VI). Check in particular for no inline `//` comments added in `lib/` and `///` doc comments on `isExerciseComplete` and `shouldAutoAdvance` in `lib/controllers/active_workout_controller.dart`.
- [X] T016 Run the full `flutter test` suite and confirm there are no new failures compared with the T001 baseline
- [ ] T017 Carry out the manual validation steps 1–7 in `specs/001-fix-auto-advance-extra-sets/quickstart.md` on a device or emulator

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (T001)** has no dependencies.
- **Foundational (T002)** depends on T001 and blocks all test tasks.
- **US1 (T003–T009)** depends on T002.
- **US2 (T010–T013)** depends on T002, T005 and T006. It does not need the widget changes (T007, T008).
- **Polish (T014–T017)** depends on US1 and US2 being complete.

### Within User Story 1

T003 → T004 (tests first, failing) → T005 → T006 → T007 → T008 → T009

### Story independence

US2 reuses the controller methods from US1, because both stories are about the same completion
rule. US2's tests can be written and run as soon as T006 is done.

---

## Parallel Opportunities

After T006:

```text
T007 [US1] edit lib/widgets/exercise_workout_card.dart (SetLogRow)
T010 [US2] edit test/controllers/active_workout_controller_test.dart
```

These edit different files and do not depend on each other. All other tasks share a file with a
neighbouring task and run sequentially.

---

## Implementation Strategy

### MVP (User Story 1 only)

1. T001–T002: baseline and fixtures
2. T003–T004: write the failing regression and unit tests
3. T005–T008: controller methods and widget wiring
4. T009: stop and validate. The reported bug is fixed.

### Full delivery

5. T010–T013: lock in the unchanged behaviour with tests (US2)
6. T014–T017: format, analyze, full test run, manual check
