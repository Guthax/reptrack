# Research: Create Exercise From Swap Dialog

No open questions remained after `/speckit-clarify`. The decisions below settle how the feature fits the existing code.

## R1. Which dialog the "+" icon opens

- **Decision**: Open the existing `CreateExerciseDialog` with `Get.dialog<Exercise>(const CreateExerciseDialog())`, and use the `Exercise` it returns.
- **Rationale**: Confirmed in Clarifications. The dialog already validates input, saves the exercise and returns it with `Get.back(result: exercise)`. `AddExerciseDialog` in `lib/widgets/add_exercise_dialog.dart` already uses it this way.
- **Alternatives considered**: `AddExerciseDialog` (rejected in Clarifications). Writing a new create form (duplicates code and breaks Principle II's "follow the existing structure").

## R2. Placing the "+" icon

- **Decision**: Make the `AlertDialog` title a `Row`: the existing "Swap {name}" text in an `Expanded` with ellipsis, then an `IconButton` with `Icons.add_circle_outline`, `AppColors.primary` and the tooltip "Create new exercise".
- **Rationale**: This matches the create button in the title of `AddExerciseDialog`, so both entry points look the same. `Expanded` with ellipsis stops long exercise names from pushing the icon off the dialog.
- **Alternatives considered**: A button under the search field or in the dialog actions (the spec asks for the top-right corner). A floating button (not how the app does dialogs).

## R3. Picking equipment for the new exercise

- **Decision**: Make `newEquipmentId` in `ActiveWorkoutController.swapExercise` optional (`String?`). When it's null or doesn't match, the controller already falls back to the first compatible equipment (`firstWhereOrNull(...) ?? equipmentList.first`). The swap dialog gets one private helper, `_swapTo(Exercise)`. Both the list tap and the "+" path call it, and it passes no equipment id. The dialog's direct `db.getEquipmentForExercise` call is removed.
- **Rationale**: FR-004 and FR-005 require the "+" path to behave exactly like picking from the list, and one shared helper guarantees that. Removing the dialog's database call puts both paths in line with Principle II (widgets must not query the database). The controller already does the fallback, so the result doesn't change.
- **Alternatives considered**: Copying the dialog's equipment lookup into the "+" path (adds a second direct database call from a widget). Adding a separate `swapToNewExercise` controller method (duplicates `swapExercise` for no gain, against Principle VII).

## R4. Closing dialogs after creating

- **Decision**: After `Get.dialog<Exercise>` returns a non-null exercise, check `mounted`, call `_swapTo(exercise)` and then close the swap dialog with `Get.back()`. If it returns `null` (Cancel or back button), do nothing, so the swap dialog stays open.
- **Rationale**: The create dialog closes itself before returning, so the swap dialog is back on top and `Get.back()` closes it. This covers FR-006 and FR-007. Validation errors are shown by `CreateExerciseController` with `AppSnackbar` and keep the create dialog open. Save failures are shown with `AppErrorHandler.showSystemError` and return `null`. Both already meet FR-008 and Principle IV.
- **Alternatives considered**: Leaving the swap dialog open after creating (the spec says it closes).

## R5. `CreateExerciseController` lifetime

- **Decision**: No change. `CreateExerciseDialog` registers the controller with `Get.put` in `initState`. GetX removes it when the dialog route closes, as it does when the dialog is opened from the program builder.
- **Rationale**: Same behavior as the program builder. Quickstart step 5 checks that opening the create dialog a second time starts empty.
- **Alternatives considered**: Deleting the controller by hand after the dialog closes (not needed; could be added if quickstart step 5 fails).

## R7. Loading the swap list

- **Decision**: Add `Future<List<Exercise>> getSwapCandidates(String excludeExerciseId)` to `ActiveWorkoutController`. It returns `db.getAllExercises()` without the exercise with id `excludeExerciseId`. On an error it reports with `AppErrorHandler.showSystemError` and returns an empty list. `_loadInitialData` in the swap dialog calls it instead of `Get.find<AppDatabase>().getAllExercises()`, and the dialog drops its `AppDatabase` import.
- **Rationale**: The dialog's direct `getAllExercises` call breaks Principle II (widgets must not query the database). The feature is changing this file anyway, and the plan's Constitution Check must be accurate. The swap dialog belongs to the active workout, so `ActiveWorkoutController` is the right owner.
- **Alternatives considered**: Recording the existing violation as a deviation in Complexity Tracking (leaves it in place). Reusing `BuildProgramController`'s exercise loading (that controller belongs to another screen and isn't registered during a workout).

## R6. Tests

- **Decision**: Add controller tests to `test/controllers/active_workout_controller_test.dart`:
  1. `swapExercise` with no equipment id picks the new exercise's first compatible equipment.
  2. Swapping to an exercise that was just created and has no history uses the existing defaults (e.g. timed: weight `null`, targets `0`).
  3. `getSwapCandidates` returns every exercise except the excluded one.
- **Rationale**: Principle V requires tests when controller logic changes. The dialog layout doesn't need UI tests.
