# Contract: Controller additions

These are internal Dart APIs. Validation failures the user can fix go through `AppSnackbar`;
database failures go through `AppErrorHandler.showSystemError` (Principle IV).

## ActiveWorkoutController

### Construction

```dart
ActiveWorkoutController(String workoutDayId, {DateTime Function() clock = DateTime.now});
```

The stopwatch reads time only through `clock`.

### State

| Field | Type | Meaning |
|-------|------|---------|
| `lastTimedSets` | `RxMap<String, List<WorkoutTimedSet>>` | Completed timed sets per exercise id, newest first. Prefetched on setup, on swap and on add-during-workout. |
| `runningStopwatchKey` | `RxnString` | `"$exerciseIndex-$equipmentId-$setNum"` of the running stopwatch, or null |
| `stopwatchElapsedSeconds` | `RxInt` | Elapsed whole seconds of the running stopwatch, refreshed every second |
| `stopwatchResults` | `RxMap<String, int>` | Elapsed seconds reported when a stopwatch stopped, keyed like `runningStopwatchKey`. The row reads the value into its fields and then clears it. |

### Logging

```dart
/// Validates and inserts a completed timed set, then marks it done locally.
Future<bool> logTimedSet({
  required int exerciseIndex,
  required String exerciseId,
  required String equipmentId,
  required int durationSeconds,
  double? weightKg,
  required int setNum,
  int? restSeconds,
});

/// Marks a previously logged timed set as incomplete.
Future<void> unlogTimedSet({
  required int exerciseIndex,
  required String exerciseId,
  required String equipmentId,
  required int setNum,
});

/// Returns the previous-session timed set for the given set number and equipment,
/// skipping sets with durationSeconds == 0; null when none.
WorkoutTimedSet? getPastTimedSetData(String exerciseId, int setNum, String? equipmentId);

/// Returns the weight (kg) of the most recent timed set of [exerciseId] that had one.
double? getLastTimedWeight(String exerciseId);
```

| Given | `logTimedSet` result |
|-------|----------------------|
| `durationSeconds = 75`, `weightKg = null` | Row inserted (75 s, weight null), set marked complete, rest timer started when `restSeconds` is given, returns `true` |
| `durationSeconds = 60`, `weightKg = 10` | Row inserted with weight 10.0, returns `true` |
| `durationSeconds = 0` | No row, snackbar "Enter a duration", returns `false` |
| `weightKg = -5` | No row, snackbar "Weight can't be negative", returns `false` |
| That row's stopwatch is running | Stopwatch stopped first; the caller passes the filled-in duration |

`isSetCompleted`, `isExerciseComplete` and `shouldAutoAdvance` work unchanged for timed
exercises, because they share the `"$index-$equipmentId-$setNum"` key and the
`setsSecondsList.length` planned-set count.

### Stopwatch

```dart
/// Starts the stopwatch for [key], stopping and reporting any other running one.
void startStopwatch(String key);

/// Stops the running stopwatch and returns its elapsed whole seconds (0 if none running).
int stopStopwatch();

/// Discards a running stopwatch without reporting a result.
void discardStopwatch();
```

| Given | Result |
|-------|--------|
| `start("0-1-1")`, clock +52.9 s, `stop()` | Returns `52`; `runningStopwatchKey` is null; `stopwatchResults["0-1-1"] == 52` |
| `start("0-1-1")`, clock +10 s, `start("0-1-2")` | `stopwatchResults["0-1-1"] == 10`; running key is `"0-1-2"`, starting from 0 |
| Clock moves 5 min while the app is backgrounded (no ticks) | `stop()` returns 300 |
| Running, then `swapExercise(...)` or `onClose()` | Stopwatch discarded; no result written |

### Swap and add during workout

- `swapExercise` supports `exerciseTypeId == '4'`. It builds a `ProgramExerciseVolume.timed`
  with `setsSeconds` = the original number of sets (strength/hybrid list length, or 1 for
  cardio) × `0`, keeps `restTimer`, and prefetches `lastTimedSets`.
- `addExerciseDuringWorkout` supports timed exercises with a default of `[60, 60, 60]`.

## BuildProgramController

- `addExerciseToDay(..., {List<int> setsSeconds = const [60]})`: routes
  `exerciseTypeId == '4'` to `db.addTimedExerciseToDay`.
- `updateExerciseInDay(..., {List<int> setsSeconds = const [60]})`: routes `volume.isTimed`
  to `db.updateProgramTimedExercise`.
- `removeExerciseFromDay`: routes `volume.isTimed` to `db.deleteProgramTimedExercise`.

## TrackingController

| Addition | Behaviour |
|----------|-----------|
| `timedSets: RxList<WorkoutTimedSet>` | Chronological (oldest first) sets for the selected timed exercise |
| `selectExercise` with type `'4'` | Loads `timedSets`, builds the equipment list like hybrid, sets `selectedChartType = ChartType.timedLongestHold` |
| `timedLongestHoldData` | `(day, max durationSeconds)` per calendar day, for the selected equipment, skipping `durationSeconds == 0`; no point for days with only such sets |
| `timedTotalTimeData` | `(day, sum durationSeconds)` per calendar day, same filtering |
| `activeChartData` | Maps the two new `ChartType` values to the getters above |

## CreateExerciseController

No API change. The type list is read from `ExerciseTypes`, so `'4' Timed` appears once
seeded. The dialog's subtitle for the Timed type reads "Time".

## Utils: duration formatting (`lib/utils/duration_format.dart`)

```dart
/// Formats [seconds] as m:ss below one hour and h:mm:ss from one hour up.
String formatDuration(int seconds);
```

| Input | Output |
|-------|--------|
| 0 | `0:00` |
| 45 | `0:45` |
| 75 | `1:15` |
| 3600 | `1:00:00` |
| 4530 | `1:15:30` |
