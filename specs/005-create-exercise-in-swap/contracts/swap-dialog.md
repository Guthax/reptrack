# Contract: Swap Exercise Dialog and swapExercise

These are internal Dart APIs. The entities are in [data-model.md](../data-model.md).

## lib/controllers/active_workout_controller.dart (changed)

```dart
/// Replaces the exercise at [exerciseIndex] with [newExercise]. Uses
/// [newEquipmentId] when it is one of the new exercise's compatible equipment,
/// and otherwise the first compatible equipment (none for cardio).
Future<void> swapExercise({
  required int exerciseIndex,
  required Exercise newExercise,
  String? newEquipmentId,
});
```

- The only change is that `newEquipmentId` goes from `required String` to optional `String?`. Existing callers still work.
- If `exerciseIndex` is out of range, nothing happens (unchanged).
- Errors are reported with `AppErrorHandler.showSystemError` (unchanged).

```dart
/// Returns every exercise in the library except the one with
/// [excludeExerciseId], for the swap dialog's list. Reports errors with
/// [AppErrorHandler.showSystemError] and returns an empty list.
Future<List<Exercise>> getSwapCandidates(String excludeExerciseId);
```

- New method.

## lib/widgets/swap_exercise_dialog.dart (changed)

The constructor (`exerciseIndex`, `exerciseId`, `exerciseName`) stays the same.

| Element | Behavior |
|---|---|
| Title | A row with "Swap {exerciseName}" (one line, ellipsis) and a "+" `IconButton` on the right (`Icons.add_circle_outline`, tooltip "Create new exercise"). |
| Tapping "+" | `Get.dialog<Exercise>(const CreateExerciseDialog())`. If it returns an exercise, the dialog calls `_swapTo(exercise)` and then `Get.back()`. If it returns `null`, nothing happens. |
| Tapping a list item | `_swapTo(exercise)` and then `Get.back()` (same result as before, but the dialog no longer reads the database). |
| Loading the list | `_loadInitialData` calls `ActiveWorkoutController.getSwapCandidates(widget.exerciseId)`. The dialog no longer imports or calls `AppDatabase`. |
| Search and Cancel | Unchanged. |

`_swapTo(Exercise)` is a private helper that calls `ActiveWorkoutController.swapExercise(exerciseIndex: widget.exerciseIndex, newExercise: exercise)`.

## lib/widgets/create_exercise_dialog.dart

Unchanged. It returns the created `Exercise` through `Get.back(result:)`, or `null` when cancelled.
