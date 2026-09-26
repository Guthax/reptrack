# Contract: ActiveWorkoutController additions

These are internal Dart APIs. The app exposes no external interfaces. This contract fixes the
signatures and behaviour that the widgets and tests rely on.

## `bool isExerciseComplete(int exerciseIndex, int plannedSets, String equipmentId)`

Returns `true` if every set from 1 to
`getTotalSetsForExercise(exerciseIndex, plannedSets, equipmentId)` is completed for
`equipmentId`.

| Given | Result |
|-------|--------|
| 3 planned, 0 extra, sets 1–3 logged | `true` |
| 3 planned, 1 extra, sets 1–3 logged | `false` (regression case) |
| 3 planned, 1 extra, sets 1–4 logged | `true` |
| 3 planned, 1 extra, sets 1, 2, 4 logged | `false` |
| sets logged under a different equipment ID | `false` |

## `bool shouldAutoAdvance({required int exerciseIndex, required int plannedSets, required String equipmentId})`

Returns `isExerciseComplete(...) && exerciseIndex < exercisesWithVolume.length - 1`.

| Given | Result |
|-------|--------|
| exercise complete, not the last exercise | `true` |
| exercise complete, last exercise | `false` |
| exercise incomplete | `false` |

## Widget usage

`SetLogRow` and `HybridSetRow` in `lib/widgets/exercise_workout_card.dart` call `shouldAutoAdvance`
after `await logSet(...)` / `await logHybridSet(...)`. When it returns true they call
`controller.pageController.nextPage(duration: 400ms, curve: Curves.easeInOut)`. This replaces the
inline `allDone` block.
