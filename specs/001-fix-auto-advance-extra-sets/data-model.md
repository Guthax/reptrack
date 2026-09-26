# Data Model: Auto-Advance Only After All Sets Are Logged

No persistent data changes. No Drift tables, columns or migrations are involved. The feature
works on existing in-memory session state in `ActiveWorkoutController`.

## Session state used (existing, unchanged)

| Field | Type | Meaning |
|-------|------|---------|
| `exercisesWithVolume` | `RxList<ExerciseWithVolume>` | Ordered exercises in the workout; its length decides whether a next exercise exists |
| `completedSets` | `RxSet<String>` | Keys `"$exerciseIndex-$equipmentId-$setNum"` for sets logged this session |
| `extraSetsCount` | `RxMap<String, int>` | Extra sets per `"$exerciseIndex-$equipmentId"` |
| `selectedEquipments` | `RxMap<int, String?>` | Selected equipment per exercise index |

## Derived values

- **Total sets** for (exercise, equipment) = planned sets + `extraSetsCount[key] ?? 0`. This
  already exists as `getTotalSetsForExercise`.
- **Exercise complete** for (exercise, equipment) is true when every set number `1..total` is
  in `completedSets`.
- **Should auto-advance** is true when the exercise is complete and
  `exerciseIndex < exercisesWithVolume.length - 1`.

## State transitions (per exercise and equipment)

```text
incomplete ──log last open set──▶ complete ──(if next exercise exists)──▶ advance page
complete ──add extra set──▶ incomplete          (no advance)
complete ──unlog a set──▶ incomplete            (no advance)
incomplete ──remove open extra set──▶ complete  (no advance; only logging triggers it)
```
