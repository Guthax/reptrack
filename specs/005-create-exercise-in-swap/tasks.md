---

description: "Task list for creating an exercise from the swap dialog"
---

# Tasks: Create Exercise From Swap Dialog

**Input**: Design documents from `/specs/005-create-exercise-in-swap/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/swap-dialog.md](contracts/swap-dialog.md), [quickstart.md](quickstart.md)

**Tests**: Required for the controller change (Constitution Principle V). Put them in the existing `group('Swap and add to timed', ...)` inside `group('timed exercises', ...)` in `test/controllers/active_workout_controller_test.dart`. That group already has `db`, `timed`, `dayId`, `snackbarErrors` and `systemErrors`. No widget tests.

**Organization**: Grouped by the spec's user stories. US1 (create and swap, P1) and US2 (back out without changes, P2). The Foundational phase makes the controller change that both stories rely on.

**Rules for every task** (Constitution VI and CLAUDE.md):
- Every new or changed class, method and helper has a `///` doc comment.
- No `//` comments inside function bodies or trailing code.
- Use `const` wherever it compiles.
- Run `dart format` on edited files.
- Widgets never call `AppDatabase`.
- No new packages and no schema changes.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on unfinished tasks)
- **[Story]**: The user story the task belongs to (US1, US2 from spec.md)

---

## Phase 1: Setup

No setup needed: no new packages, files or schema changes.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Make the equipment argument of `swapExercise` optional, and add `getSwapCandidates`, so the swap dialog can leave both equipment lookup and exercise loading to the controller (research R3, R7, [contracts/swap-dialog.md](contracts/swap-dialog.md)).

**⚠️ CRITICAL**: US1 can't be finished until this phase is done.

### Tests (write first; they fail to compile until T004 and T005)

- [X] T001 [P] Add a test `'swapping without an equipment id picks the first compatible equipment'` to `group('Swap and add to timed', ...)` in `test/controllers/active_workout_controller_test.dart`:
  1. Add a strength slot to `timed.exercisesWithVolume`, like the existing `'swapping strength for timed keeps set count and rest'` test (exercise `bench`, `setsReps: '[12,10,8]'`, `restTimer: 90`).
  2. Create a strength exercise with `db.addExercise('Machine Row', exerciseTypeId: '1')` and link equipment `'2'` and `'3'` by inserting `ExerciseEquipmentCompanion` rows into `db.exerciseEquipment`.
  3. Call `timed.swapExercise(exerciseIndex: 1, newExercise: machineRow)` with no `newEquipmentId`.
  4. Expect `timed.selectedEquipments[1]` and `timed.exercisesWithVolume[1].equipment?.id` to equal `(await db.getEquipmentForExercise(machineRow.id)).first.id`, and `systemErrors` to be empty.
- [X] T002 [P] Add a test `'swapping to a newly created timed exercise uses the existing defaults'` to the same group in `test/controllers/active_workout_controller_test.dart`:
  1. Add the same strength slot at index 1.
  2. Create the exercise through `Get.put(CreateExerciseController())`: `exerciseTypeSelected('4')`, then `createExercise(name: 'Dead Hang', equipmentIds: {'1'})`.
  3. Call `timed.swapExercise(exerciseIndex: 1, newExercise: created!)` with no `newEquipmentId`.
  4. Expect `isTimed == true`, `volume.setsSecondsList == [0, 0, 0]`, `volume.restTimer == 90`, `timed.timedWeightKg[1] == null`, equipment id `'1'`, and `snackbarErrors` and `systemErrors` both empty.
  5. Clean up with `Get.delete<CreateExerciseController>()` at the end of the test.
- [X] T003 [P] Add `group('getSwapCandidates', ...)` with a test `'returns every exercise except the excluded one'` in `test/controllers/active_workout_controller_test.dart`. Use the top-level `controller` and `Get.find<AppDatabase>()`:
  1. Add two exercises with `db.addExercise('Swap A', exerciseTypeId: '1')` and `db.addExercise('Swap B', exerciseTypeId: '1')`, and keep their returned ids.
  2. Call `controller.getSwapCandidates(aId)`.
  3. Expect the ids in the result to contain `bId` and not contain `aId`, and the result length to equal `(await db.getAllExercises()).length - 1`.

### Implementation

- [X] T004 In `lib/controllers/active_workout_controller.dart`, change `swapExercise`'s `required String newEquipmentId` to an optional `String? newEquipmentId`. The existing `equipmentList.firstWhereOrNull((e) => e.id == newEquipmentId) ?? (equipmentList.isNotEmpty ? equipmentList.first : null)` already handles `null`, so leave the body alone. Rewrite the doc comment as: "Replaces the exercise at [exerciseIndex] with [newExercise]. Uses [newEquipmentId] when it is one of the new exercise's compatible equipment, and otherwise the first compatible equipment (none for cardio)." Existing callers and tests that pass `newEquipmentId` must still compile.
- [X] T005 In `lib/controllers/active_workout_controller.dart`, add `Future<List<Exercise>> getSwapCandidates(String excludeExerciseId)` next to `swapExercise`, with the doc comment: "Returns every exercise in the library except the one with [excludeExerciseId], for the swap dialog's list. Reports errors with [AppErrorHandler.showSystemError] and returns an empty list." Body: in a `try`, return `(await db.getAllExercises()).where((e) => e.id != excludeExerciseId).toList()`. In `catch (e, st)`, call `AppErrorHandler.showSystemError(e, st)` and return `[]` (Principle IV).
- [X] T006 Run `flutter test test/controllers/active_workout_controller_test.dart` and confirm that T001–T003 and every existing swap test pass.

**Checkpoint**: The controller accepts swaps without an equipment id and provides the swap list.

---

## Phase 3: User Story 1 - Create a new exercise and swap it in mid-workout (Priority: P1) 🎯 MVP

**Goal**: A "+" in the swap dialog opens the create exercise dialog, and the created exercise replaces the current one (FR-001–FR-006, FR-009).

**Independent Test**: Quickstart steps 1–3 and 7–9: start a workout, open swap, tap "+", create "Test Row". It replaces the exercise in the same slot with the same sets, reps and rest, and it's now in the exercise library.

### Implementation for User Story 1

- [X] T007 [US1] In `lib/widgets/swap_exercise_dialog.dart`, add a private helper `Future<void> _swapTo(Exercise exercise)` to `_SwapExerciseDialogState`, with a `///` doc comment. It calls `Get.find<ActiveWorkoutController>().swapExercise(exerciseIndex: widget.exerciseIndex, newExercise: exercise)` without `newEquipmentId`, then closes the swap dialog with `Get.back()`, but only if `mounted`.
- [X] T008 [US1] In `lib/widgets/swap_exercise_dialog.dart`, replace the list item's `onTap` body with `() => _swapTo(ex)`. Remove the `db.getEquipmentForExercise` lookup, the `defaultEquipId` variable and `final db = Get.find<AppDatabase>();` from `build`. Change `_loadInitialData` to `allExercises = await Get.find<ActiveWorkoutController>().getSwapCandidates(widget.exerciseId);` followed by the existing `filteredExercises.assignAll(allExercises);`, and remove the old `removeWhere` line. Keep `import 'package:reptrack/persistance/database.dart';`, because the `Exercise` type comes from it, but the file must no longer mention `AppDatabase` anywhere. This makes the list path match FR-004/FR-005 through the shared helper and removes both direct database calls (Principle II, research R7).
- [X] T009 [US1] In `lib/widgets/swap_exercise_dialog.dart`, change the `AlertDialog` `title` to a `Row`:
  - An `Expanded` holding `Text("Swap ${widget.exerciseName}", maxLines: 1, overflow: TextOverflow.ellipsis)`.
  - Then an `IconButton` with `icon: const Icon(Icons.add_circle_outline)`, `color: AppColors.primary`, `tooltip: 'Create new exercise'`. It matches the button in the title of `lib/widgets/add_exercise_dialog.dart`.
  - Its `onPressed` is an async handler: `final created = await Get.dialog<Exercise>(const CreateExerciseDialog()); if (created == null || !mounted) return; await _swapTo(created);`.
  - Add `import 'package:reptrack/widgets/create_exercise_dialog.dart';`.
  - Leave search, the list and the Cancel action as they are (FR-009).

**Checkpoint**: US1 works on its own. Run quickstart steps 1–3 and 7–9.

---

## Phase 4: User Story 2 - Back out without changing the workout (Priority: P2)

**Goal**: Cancelling, or failing validation or saving, in the create dialog leaves the workout unchanged and the swap dialog open (FR-007, FR-008).

**Independent Test**: Quickstart steps 4–6: tap "+", then Cancel → back in the swap dialog with nothing changed. Tap "+" again → the form is empty. Submit a duplicate or empty name → error snackbar and nothing changed.

### Implementation for User Story 2

- [X] T010 [US2] In `lib/widgets/swap_exercise_dialog.dart`, check that the "+" handler from T009 returns right away when `Get.dialog<Exercise>` gives `null`: no call to `_swapTo` and no `Get.back()`, so the swap dialog stays open (FR-007). `CreateExerciseController.createExercise` already shows the errors from [data-model.md](data-model.md): "Exercise name is required", "Please select at least one equipment type", "\"<name>\" already exists" and `AppErrorHandler.showSystemError`. It returns `null` and the create dialog stays open (FR-008), so `lib/controllers/create_exercise_controller.dart` and `lib/widgets/create_exercise_dialog.dart` stay unchanged.
- [ ] T011 [US2] Run quickstart step 5 ([quickstart.md](quickstart.md)): open "+" twice and check that the second create form is empty, with Strength selected by default (research R5). If it still has the previous input, add `Get.delete<CreateExerciseController>()` after the `Get.dialog` call in the "+" handler in `lib/widgets/swap_exercise_dialog.dart`. Otherwise change nothing.

**Checkpoint**: US1 and US2 both work.

---

## Phase 4b: User Story 3 - Create a new exercise while adding one to the workout (Priority: P2)

**Goal**: The same "+" in the add-exercise dialog during a workout; the created exercise is added to the end of the workout (FR-010, FR-011).

**Independent Test**: Tap "+" in the add-exercise dialog, create "Test Fly" → it's the last exercise in the workout, with its first compatible equipment selected.

- [X] T016 [US3] Add a test `'adding without an equipment id picks the first compatible equipment'` to `group('Swap and add to timed', ...)` in `test/controllers/active_workout_controller_test.dart`: create a strength exercise with equipment `'2'` and `'3'` through `CreateExerciseController`, call `timed.addExerciseDuringWorkout(exercise: created!)`, and expect the added slot's `equipment?.id`, `volume.equipmentId` and `selectedEquipments[index]` to equal the first compatible equipment.
- [X] T017 [US3] In `lib/controllers/active_workout_controller.dart`, make `addExerciseDuringWorkout` fall back to `(await db.getEquipmentForExercise(exercise.id)).firstOrNull` when `equipmentId` is `null` (not for cardio), and use `equipment?.id` for the volume's `equipmentId`. Update its doc comment.
- [X] T018 [US3] In `lib/widgets/add_workout_exercise_dialog.dart`, add `_createAndAdd()` (opens `CreateExerciseDialog`, returns on `null`, otherwise calls `addExerciseDuringWorkout(exercise: created)` and `Get.back()`), and turn the title into a `Row` with an `Expanded` title text and, only while `selectedExercise.value == null`, an `IconButton` (`Icons.add_circle_outline`, `AppColors.primary`, tooltip "Create new exercise"). Add `///` docs to the file's undocumented members.
- [ ] T019 [US3] In the running app: open the add-exercise dialog, tap "+", create an exercise with two pieces of equipment → it's added last with the first one selected; tap "+" and Cancel → the dialog stays open and nothing is added.

---

## Phase 5: Polish & Cross-Cutting Concerns

- [X] T012 Run `dart format lib/widgets/add_workout_exercise_dialog.dart lib/widgets/swap_exercise_dialog.dart lib/controllers/active_workout_controller.dart test/controllers/active_workout_controller_test.dart`.
- [ ] T013 Run `flutter analyze` and fix any issues until it reports "No issues found" (e.g. an unused import or `const`).
- [X] T014 Run `flutter test` and confirm the whole suite passes.
- [ ] T015 Hot-reload the app and go through every step in [quickstart.md](quickstart.md), including the long-name check in step 1.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: empty.
- **Foundational (Phase 2)**: T001–T003 are written together, then T004 and T005 (same file, one after the other), then T006. This blocks US1.
- **US1 (Phase 3)**: needs Phase 2. T007 → T008 → T009 (same file, so one after another).
- **US2 (Phase 4)**: needs T009, because it checks and possibly adjusts the handler T009 adds.
- **Polish (Phase 5)**: after the stories are done.

### User Story Dependencies

- **US1 (P1)**: depends only on Foundational.
- **US2 (P2)**: needs US1's "+" button to exist. It adds almost no code; it mostly checks behavior.

### Parallel Opportunities

- T001–T003 (separate tests in the same file) can be written in parallel with each other, before T004 and T005.
- The rest are one after another: every implementation task edits `lib/widgets/swap_exercise_dialog.dart` or depends on the step before.

### Parallel Example: Foundational

```text
Task: "T001 test: swap without equipment id picks first compatible equipment"
Task: "T002 test: swap to newly created timed exercise uses existing defaults"
Task: "T003 test: getSwapCandidates excludes the given exercise"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 2 (T001–T006): controller changes with tests.
2. Phase 3 (T007–T009): "+" button and shared swap helper.
3. **Stop and check**: quickstart steps 1–3 and 7–9.

### Incremental Delivery

1. Foundational → US1 (MVP, the whole feature is usable).
2. US2 → check cancel and validation, and create-form reset.
3. Polish → format, analyze, test and a full quickstart run.
