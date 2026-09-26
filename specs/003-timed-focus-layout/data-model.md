# Data Model: Timed Exercise Focus Layout

**Feature**: [spec.md](spec.md) | **Research**: [research.md](research.md)

**No database change.** The schema stays at version 2. Everything below is in-memory state in
`ActiveWorkoutController` that exists only while the workout is open.

## TimedSetEntry (new value class)

The time and weight entered or measured for one set, keyed by the row key
`"$exerciseIndex-$equipmentId-$setNum"`.

| Field | Type | Meaning |
|-------|------|---------|
| `seconds` | `int` | Entered or measured duration; always > 0 (an entry of 0 is removed instead) |
| `weightKg` | `double?` | Weight copied from the exercise's current weight when the set is logged; `null` before logging and for sets without a weight |

This is an immutable class with a `const` constructor and `copyWith`, stored in
`lib/controllers/active_workout_controller.dart`.

## Controller state (additions)

| Field | Type | Meaning |
|-------|------|---------|
| `timedEntries` | `RxMap<String, TimedSetEntry>` | Pending and logged entries per row key. Replaces `stopwatchResults`. |
| `timedWeightKg` | `RxMap<int, double?>` | Current weight per exercise index, carried to the next sets |
| `_activeTimedOverride` | `RxMap<int, int>` | Set number the user tapped, per exercise index |
| `_stopwatchOffsetSeconds` | `int` | Seconds already counted before the current run (for Resume) |

Removed: `stopwatchResults` (research R2).

## Derived values

- `activeTimedSetNum(exerciseIndex, equipmentId, totalSets)` → `int?`: the tapped set if it
  is still unlogged and in range, otherwise the first unlogged set, or `null` when all are
  logged.
- `timedPhase(key)` → `TimedSetPhase { idle, running, ready }`:
  - `running` when `runningStopwatchKey == key`;
  - `ready` when `timedEntries[key]` exists and the set is not logged;
  - otherwise `idle`.
- Stopwatch elapsed = `_stopwatchOffsetSeconds + clock().difference(startedAt).inSeconds`.

## State transitions: one set

```text
          start            stop              log
idle ───────────▶ running ───────▶ ready ──────────▶ logged
  ▲                 ▲  │            │ │                │
  │   pick > 0:00   │  │ resume     │ │ hold Reset     │ long-press (unlog)
  ├─────────────────┼──┼────────────┘ │                ▼
  │                 └──┴──────────────┤            ready (entry kept)
  └───────── hold Reset / pick 0:00 ──┘
running ── tap another set / start on another set ──▶ ready (elapsed kept)
running ── change equipment / swap / leave ────────▶ previous state (stopwatch discarded)
```

## Validation

- Logging from `ready` calls the existing `logTimedSet`. Its rules are unchanged: duration
  ≥ 1 s, weight ≥ 0.
- The minutes picker covers 0–180 and the seconds picker 0–59. Confirming 0:00 removes the
  entry.
- The weight sheet accepts only digits and one decimal point.
