# Data Model: Timed Exercise Type

**Feature**: [spec.md](spec.md) | **Research**: [research.md](research.md) | **Schema version**: 1 → 2

## Unchanged tables

The migration changes no columns in any existing table. These tables keep their exact v1
shape:

- `Exercises`
- `ExerciseTypes`
- `ProgramStrengthExercises`
- `ProgramCardioExercises`
- `ProgramHybridExercises`
- `WorkoutStrengthSets`
- `WorkoutCardioSets`
- `WorkoutHybridSets`
- all remaining tables

Only rows belonging to the [hold list](#hold-list) are rewritten (see
[Migration v1 → v2](#migration-v1--v2)).

## ExerciseTypes (new row)

| id | name |
|----|------|
| `'1'` | Strength |
| `'2'` | Cardio |
| `'3'` | Hybrid |
| **`'4'`** | **Timed** |

The row is inserted by the migration (existing installs) and by `seedDatabase` (every start,
idempotent upsert).

## ProgramTimedExercises (new table)

A timed exercise planned on a workout day. Mirrors `ProgramStrengthExercises`, with
`setsReps` replaced by `setsSeconds` and without a planned weight.

| Column | Type | Null | Default | Notes |
|--------|------|------|---------|-------|
| `id` | text, PK | no | uuid v4 | |
| `workoutDayId` | text → `WorkoutDays.id` | no | | `onDelete: cascade` |
| `equipmentId` | text → `Equipments.id` | yes | | `onDelete: cascade`, as in strength |
| `exerciseId` | text → `Exercises.id` | no | | |
| `orderInProgram` | int | no | `0` | Shared ordering with the other program tables |
| `setsSeconds` | text (JSON `List<int>`) | no | `'[60]'` | One target per set; `0` = no target |
| `restTimer` | int | yes | | Seconds |

**Validation**
- `setsSeconds` has at least one entry, and every entry is ≥ 0.
- The number of planned sets is the list's length.

## WorkoutTimedSets (new table)

One logged set of a timed exercise. Mirrors `WorkoutStrengthSets`, with `reps` replaced by
`durationSeconds` and `weight` made optional.

| Column | Type | Null | Default | Notes |
|--------|------|------|---------|-------|
| `id` | text, PK | no | uuid v4 | |
| `workoutId` | text → `Workouts.id` | no | | `onDelete: cascade` |
| `exerciseId` | text → `Exercises.id` | no | | |
| `equipmentId` | text → `Equipments.id` | yes | | |
| `setNumber` | int | no | | 1-based; extra sets continue the numbering |
| `durationSeconds` | int | no | | `> 0` when logged by the user; `0` only for converted sets ("no time recorded") |
| `weight` | real | yes | | kg; `null` = no weight |
| `isCompleted` | bool | no | `true` | Un-logging sets it to `false`, as for the other types |
| `dateLogged` | datetime | no | now | |

**Validation (on log, reported via `AppSnackbar`)**
- `durationSeconds` must be ≥ 1. An empty or zero duration is rejected.
- `weight`, when given, must be ≥ 0. An empty field is stored as `null`.

**Read rules**
- Tracking charts and previous-duration references ignore rows with `durationSeconds == 0`.
- History shows rows with `durationSeconds == 0` as "no time recorded".
- Only `isCompleted = true` rows are read for history, charts and references, the same as
  `getHybridSetsForExercise`.

## Composite: ProgramExerciseVolume

- Gains a `.timed(ProgramTimedExercise)` constructor.
- `isTimed` is true for timed entries.
- `setsSeconds` holds the raw JSON (default `'[60]'`); `setsSecondsList` is the parsed list,
  falling back to `[60]`.
- `setsSecondsLabel` reads, for example, "3 × 1:00", or "1:00, 0:45, 0:30" when the targets
  differ, or "3 sets" when every target is 0.
- The shared getters (`id`, `workoutDayId`, `exerciseId`, `orderInProgram`, `equipmentId`,
  `restTimer`) include the timed entry. `weight` returns `0.0` for timed entries.

`ExerciseWithVolume` gains `isTimed`.

## Hold list

These exercises are matched on `lower(trim(name))`:

| Name | CSV type before | CSV type after |
|------|-----------------|----------------|
| Plank | 1 | 4 |
| Side Plank | 1 | 4 |
| Copenhagen Plank | 1 | 4 |
| Wall Sit | 1 | 4 |
| Hollow Body Hold | 1 | 4 |
| L-Sit | 1 | 4 |
| Isometric Curl Hold | 1 | 4 |

These stay Strength: Plank Hip Dip, Plank Reach, Plank Row, L-Sit Pull-Up and Dead Bug.

## Migration v1 → v2

All steps run in one transaction inside `onUpgrade` when `from < 2`:

1. `createTable(programTimedExercises)` and `createTable(workoutTimedSets)`.
2. Upsert `ExerciseTypes('4', 'Timed')`.
3. `holdIds` = the ids of exercises whose `lower(trim(name))` is in the hold list.
4. For each `WorkoutStrengthSets` row where `exerciseId ∈ holdIds`, insert a
   `WorkoutTimedSets` row:

   | Timed column | Value |
   |--------------|-------|
   | `id`, `workoutId`, `exerciseId`, `equipmentId`, `setNumber`, `isCompleted`, `dateLogged` | copied |
   | `durationSeconds` | `0` |
   | `weight` | old `weight` if `> 0`, else `null` |

5. For each `ProgramStrengthExercises` row where `exerciseId ∈ holdIds`, insert a
   `ProgramTimedExercises` row:

   | Timed column | Value |
   |--------------|-------|
   | `id`, `workoutDayId`, `equipmentId`, `exerciseId`, `orderInProgram`, `restTimer` | copied |
   | `setsSeconds` | JSON list of `0` repeated `len(setsReps)` times; `[0]` if `setsReps` cannot be parsed |

6. Delete the `WorkoutStrengthSets` and `ProgramStrengthExercises` rows where
   `exerciseId ∈ holdIds`.
7. Update `Exercises.exerciseTypeId = '4'` where `id ∈ holdIds`.

**Invariants after the migration**
- The number of sets per workout (strength + timed) is unchanged (SC-006).
- The number of program entries per day is unchanged, and `orderInProgram` values are
  unchanged.
- No row remains in `WorkoutStrengthSets` or `ProgramStrengthExercises` for `holdIds`
  (FR-015).
- No row of any exercise outside `holdIds` is changed (FR-016).

## State: timed set row during a workout

```text
empty ──type/stopwatch──▶ filled ──log (valid)──▶ logged ──un-log──▶ filled
  │                          │                        ▲
  └──start──▶ running ──stop─┘                        │
                 └────────log (auto-stop, fill)───────┘
running ──start on another row──▶ filled (this row keeps its elapsed time)
running ──swap / leave workout──▶ discarded (row unchanged)
```
