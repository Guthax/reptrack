# Contract: ActiveWorkoutController changes for the focus layout

These are internal Dart APIs. Existing behaviour from
[002 contracts](../../002-timed-exercise-type/contracts/controllers.md) stays unless it is
changed here. `key` always means `"$exerciseIndex-$equipmentId-$setNum"`.

## New types

```dart
/// Time and weight entered or measured for one timed set.
class TimedSetEntry {
  final int seconds;
  final double? weightKg;
  const TimedSetEntry({required this.seconds, this.weightKg});
  TimedSetEntry copyWith({int? seconds, double? weightKg});
}

/// Where a timed set is in its time-then-log flow.
enum TimedSetPhase { idle, running, ready }
```

## Active set

```dart
/// Returns the set number the panel operates on, or null when every set is logged.
int? activeTimedSetNum(int exerciseIndex, String equipmentId, int totalSets);

/// Makes [setNum] the active set of [exerciseIndex] when it is not logged.
/// A running stopwatch on another set is stopped and keeps its time (as an entry).
void selectTimedSet(int exerciseIndex, String equipmentId, int setNum);
```

| Given (3 sets, equipment `1`) | `activeTimedSetNum` |
|-------------------------------|---------------------|
| nothing logged | 1 |
| set 1 logged | 2 |
| sets 1 and 2 logged, `selectTimedSet(…, 3)` earlier | 3 |
| set 1 logged, `selectTimedSet(…, 3)` | 3 |
| `selectTimedSet(…, 3)`, then set 3 logged | 1 if set 1 is unlogged, otherwise the next unlogged set |
| all 3 logged | `null` |
| all 3 logged, `addExtraSet` | 4 |
| `selectTimedSet(…, 2)` while set 2 is logged | unchanged (no effect) |

## Entries and phases

```dart
final RxMap<String, TimedSetEntry> timedEntries;   // replaces stopwatchResults
final RxMap<int, double?> timedWeightKg;

/// Sets the time of [key] from the picker; 0 removes the entry.
void setTimedEntrySeconds(String key, int seconds);

/// Removes the entry of [key] so the set is idle again (press-and-hold Reset).
void resetTimedEntry(String key);

/// Sets or clears the current weight of [exerciseIndex].
void setTimedWeight(int exerciseIndex, double? weightKg);

/// Derived phase of [key].
TimedSetPhase timedPhase(String key);
```

- `timedWeightKg[i]` is initialised from `getLastTimedWeight(exerciseId)` in `_setupWorkout`,
  `swapExercise` and `addExerciseDuringWorkout` for timed exercises.
- `logTimedSet(...)`, when successful, stores
  `timedEntries[key] = TimedSetEntry(seconds: durationSeconds, weightKg: weightKg)` and
  clears the active-set override of that exercise. The signature is unchanged; the panel
  passes `timedWeightKg[exerciseIndex]`.
- `unlogTimedSet(...)` keeps the entry and makes the set active (`selectTimedSet`).

## Stopwatch (changed)

| Call | Behaviour |
|------|-----------|
| `startStopwatch(key)` | Skips a running rest timer. Stops any other running stopwatch into its entry. Starts counting from `timedEntries[key]?.seconds ?? 0` (Resume when an entry exists). |
| `stopStopwatch()` | Writes the elapsed total into `timedEntries[key].seconds` (keeping any weight) and returns it; returns 0 when nothing runs. |
| `discardStopwatch()` | Unchanged: stops without writing. |
| `selectEquipment(exerciseIndex, equipmentId)` | New. Sets `selectedEquipments[exerciseIndex]` and discards a running stopwatch. |

| Given | Result |
|-------|--------|
| start `0-1-1`, +30 s, stop, +60 s (paused), start `0-1-1`, +10 s, stop | entry `0-1-1` = 40 s |
| rest timer at 45 s, `startStopwatch` | `remainingRestTime == 0`, stopwatch running |
| start `0-1-1`, `selectTimedSet(0, '1', 2)` | stopwatch stopped, entry `0-1-1` holds the elapsed time, active set 2 |
| start `0-1-1`, `selectEquipment(0, '2')` | stopwatch discarded, no entry for `0-1-1` |
| entry 0:52, `resetTimedEntry` | no entry, `timedPhase == idle` |
| `setTimedEntrySeconds(key, 0)` | entry removed |

## Utils: `lib/utils/duration_format.dart` (addition)

```dart
/// Fraction of [targetSeconds] reached by [seconds], clamped to 0–1; null when there is no target.
double? targetProgress(int seconds, int targetSeconds);
```

| seconds | target | result |
|---------|--------|--------|
| 30 | 60 | 0.5 |
| 90 | 60 | 1.0 |
| 0 | 60 | 0.0 |
| 30 | 0 | null |
