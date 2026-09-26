# Data Model: Create Exercise From Swap Dialog

No schema changes. `schemaVersion`, the Drift tables and `database.g.dart` stay as they are.

## Existing entities used

| Entity | Where | How this feature uses it |
|---|---|---|
| `Exercise` | `exercises` table | A new row is written by `CreateExerciseController.createExercise` (name must be unique and not empty; type id `1`–`4`). |
| `ExerciseEquipment` | `exercise_equipment` table | Links for the new exercise, written by the same method. At least one is required unless the exercise is cardio. |
| `ExerciseWithVolume` | Kept in memory in `ActiveWorkoutController.exercisesWithVolume` | The slot at `exerciseIndex` is replaced by `swapExercise`. Its `volume.id` and `orderInProgram` are kept. |

## What changes when a swap happens

`exercisesWithVolume[i]` goes from (old exercise, old volume) to (new exercise, converted volume):
- The conversion follows the existing rules in `swapExercise`, unchanged (see Clarifications).
- Completed sets for slot `i` are removed from `completedSets`, and a running stopwatch is discarded.
- The saved program isn't changed. The swap only lasts for this workout.

## Validation (existing, reused)

| Rule | Feedback |
|---|---|
| Name is empty | `AppSnackbar.error('Exercise name is required')` |
| Not cardio and no equipment chosen | `AppSnackbar.error('Please select at least one equipment type')` |
| Name already exists | `AppSnackbar.error('"<name>" already exists')` |
| Database error while saving | `AppErrorHandler.showSystemError` |
