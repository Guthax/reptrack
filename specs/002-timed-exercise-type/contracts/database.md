# Contract: AppDatabase additions

These are internal Dart APIs; the app exposes no external interfaces. This contract fixes the
signatures and behaviour that the controllers and tests rely on. The tables are described in
[data-model.md](../data-model.md).

## Schema

- `schemaVersion` returns `2`.
- `migration` returns a `MigrationStrategy`:
  - `onCreate`: create all tables.
  - `onUpgrade(from < 2)`: run the v1 → v2 step in one transaction.

| Given (v1 database) | After opening with v2 |
|---------------------|-----------------------|
| Plank with 3 strength sets (45 reps, 0 kg) in workout W | 3 timed sets in W, `durationSeconds = 0`, `weight = null`, same `setNumber`/`isCompleted`/`dateLogged`; 0 strength sets for Plank |
| Wall Sit strength set with 20 kg | Timed set with `weight = 20.0`, `durationSeconds = 0` |
| Day D: Plank `setsReps = [30,30,30]`, `restTimer = 60`, `orderInProgram = 2` | Timed entry on D: `setsSeconds = [0,0,0]`, `restTimer = 60`, `orderInProgram = 2`; no strength entry |
| Bench Press sets and program entries | Unchanged |
| Plank Row sets | Unchanged, still Strength |
| Exercise type rows | `'1'`–`'3'` unchanged, plus `'4' Timed` |

## Program exercises

```dart
/// Inserts a timed exercise entry at the end of [workoutDayId] and returns its id.
Future<String> addTimedExerciseToDay({
  required String workoutDayId,
  required String exerciseId,
  String? equipmentId,
  required List<int> setsSeconds,
  int? restTimer,
});

/// Deletes a timed program exercise by its [id].
Future<int> deleteProgramTimedExercise(String id);

/// Updates the timed program exercise identified by [id] with [companion].
Future<int> updateProgramTimedExercise(
  ProgramTimedExercisesCompanion companion,
  String id,
);
```

- `addTimedExerciseToDay` sets `orderInProgram` to the combined count of strength, cardio,
  hybrid and timed entries on that day. The existing `add…ExerciseToDay` methods must also
  count timed entries.
- `deleteProgram` also deletes `programTimedExercises` rows of the program's days.
- `reorderExercisesInDay` writes `orderInProgram` for timed volumes to
  `programTimedExercises`.
- `watchWorkoutDaysWithExercises` combines a fourth, timed query, and yields
  `ExerciseWithVolume(volume: ProgramExerciseVolume.timed(...), equipment: …)` sorted
  together with the other types.

## Timed sets

```dart
/// Returns all completed timed sets for [exerciseId], newest first.
Future<List<WorkoutTimedSet>> getTimedSetsForExercise(String exerciseId);
```

- Returns only rows with `isCompleted = true`, ordered by `dateLogged` descending, the same
  as `getHybridSetsForExercise`.
- Includes rows with `durationSeconds = 0`. Callers decide whether to show or skip them.
