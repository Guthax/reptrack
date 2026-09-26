# Research: Timed Exercise Focus Layout

**Feature**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md) | **Date**: 2026-09-26

This builds on feature 002. The current state is in `lib/controllers/active_workout_controller.dart`
(timed logging and stopwatch) and in `TimedLogSection` / `TimedSetRow` in
`lib/widgets/exercise_workout_card.dart`. No `NEEDS CLARIFICATION` items remain.

## R1. Where the new state lives

- **Decision**: All new state lives in `ActiveWorkoutController` as Rx fields:
  - the active set per exercise;
  - pending entries (time and weight) per set;
  - the current weight per exercise;
  - the stopwatch's resume offset.

  The widgets stay stateless apart from their animation state.
- **Rationale**: Constitution Principle I requires state in the screen's single controller.
  Holding it there also keeps entries when a `PageView` page is disposed while the user swipes
  between exercises (spec edge case), and makes the behaviour unit-testable without widget
  tests (Principle V).
- **Alternatives considered**: Keeping the time in a `StatefulWidget`, as `TimedSetRow` does
  today: rejected, because entries are lost when the user swipes away and can't be tested.

## R2. Pending entries replace `stopwatchResults`

- **Decision**: Replace `stopwatchResults` with `timedEntries: RxMap<String, TimedSetEntry>`,
  keyed by the existing row key `"$exerciseIndex-$equipmentId-$setNum"`.
  - `stopStopwatch()` writes the elapsed seconds into that set's entry.
  - The picker writes into the same entry.
  - `logTimedSet` keeps the entry after logging, so the logged row can show its time and
    weight, and an unlog pre-fills the previous time (spec Story 3, scenario 3).
- **Rationale**: `stopwatchResults` only existed so that the per-row text fields could pull
  in the stopped time. With one panel reading from the controller, a single source of truth
  is simpler. The feature 002 tests that assert on `stopwatchResults` are updated to assert
  on `timedEntries`.
- **Alternatives considered**: Keeping `stopwatchResults` next to `timedEntries`: rejected,
  because two maps would hold the same value.

## R3. Resuming the stopwatch (FR-004a)

- **Decision**: `startStopwatch(key)` takes the key's existing entry time as an offset.
  - Elapsed time is `offset + (clock() - startedAt)`, in whole seconds.
  - Resume is `startStopwatch(key)` on a set that already has an entry time.
  - Start on a set with no entry begins from 0.
- **Rationale**: Elapsed time stays clock-based, so it remains correct in the background (002
  R8). The time between Stop and Resume is not counted (spec edge case). No separate resume
  code path is needed.
- **Alternatives considered**: Using the `Stopwatch` class's pause and resume: rejected,
  because it can't use the injected test clock.

## R4. Panel phases

Each phase is derived from controller state, not stored:

| Phase | Condition | Large time | Primary button | Secondary |
|-------|-----------|------------|----------------|-----------|
| idle | no entry time and not running | target, or `0:00` (dimmed) | Start | — |
| running | `runningStopwatchKey == key` | live elapsed | Stop | — |
| ready | entry time > 0 and not running | entry time | Log set | Resume · Reset (hold) |
| allDone | every set logged | "All sets done" | — | Add extra set |

- Reset removes the entry, so the set goes back to idle.
- A picker confirm of 0:00 also removes the entry.

## R5. Which set is active

- **Decision**: `activeTimedSetNum(exerciseIndex, equipmentId, totalSets)` returns
  `_activeOverride[exerciseIndex]` if that set is still unlogged and within range. Otherwise
  it returns the first unlogged set, or `null` when all sets are logged.
  - Tapping a row sets the override.
  - Logging clears it, so the next unlogged set becomes active.
  - Unlogging sets it to the unlogged set.
- **Rationale**: This matches FR-002 and FR-007 with minimal state. A stale override (the set
  was logged, or removed as an extra set) is ignored automatically.

## R6. Carrying the weight over (FR-010)

- **Decision**: `timedWeightKg: RxMap<int, double?>` holds the current weight per exercise
  index, initialised from `getLastTimedWeight` on setup, swap and add. The chip edits it, and
  `logTimedSet` copies it into the set's entry. Removing the weight sets it to `null`.
- **Rationale**: The spec says the weight carries over to the following sets. An
  exercise-level value does exactly that; logged sets keep their own copy.

## R7. Rest and equipment interactions

- **Decision**:
  - `startStopwatch` calls `skipRestTimer()` first (clarification Q2, FR-009).
  - Changing the equipment of an exercise goes through a new
    `selectEquipment(exerciseIndex, equipmentId)`, which discards a running stopwatch.
    `TimedLogSection` uses it; the other sections keep writing `selectedEquipments` directly,
    so they stay unchanged (FR-012).
- **Rationale**: Set keys include the equipment id, so a stopwatch running under the old
  equipment would never be shown again.

## R8. Pickers

- **Decision**:
  - **Time:** a modal bottom sheet with two `CupertinoPicker` wheels, minutes 0–180 and
    seconds 0–59, plus Cancel and Done. `CupertinoPicker` ships with Flutter, so no new
    package is needed (Principle VII).
  - **Weight:** a bottom sheet with a decimal number field in the user's unit
    (`SettingsController.toKg` / `displayWeight`) and the actions Remove weight, Cancel and
    Done. The input formatter allows only digits and one decimal point, so negative values
    can't be entered (Story 4, scenario 6).
- **Rationale**: Wheels suit whole minutes and seconds, and can't produce invalid values.
  Weight has too many possible values for a wheel, so a numeric field with the number
  keyboard is quicker.

## R9. Press-and-hold Reset

- **Decision**: Reset is a `RawGestureDetector` with a `LongPressGestureRecognizer(duration:
  Duration(seconds: 1))` that removes the entry. A normal tap shows the hint "Hold to reset"
  through a `Tooltip` with `triggerMode: TooltipTriggerMode.tap`, and never changes the time.
- **Rationale**: The one-second hold is set explicitly, because the default long press is
  about 0.5 s and the user asked for Reset to be hard to trigger by accident.

## R10. Progress ring (FR-003a)

- **Decision**: Add a pure helper `double? targetProgress(int seconds, int targetSeconds)` to
  `lib/utils/duration_format.dart`. It returns `null` when the target is ≤ 0, otherwise
  `(seconds / target).clamp(0, 1)`.
  - The panel draws a `CircularProgressIndicator(value: …)` behind the large time.
  - Its colour is `AppColors.secondary` below the target and `AppColors.success` at or above
    it.
  - It is hidden when the helper returns `null`.
- **Rationale**: The testable logic is in `lib/utils/` (Principle V), and the drawing uses
  existing widgets and theme colours.

## R11. Code layout

- **Decision**: Move the timed logging UI out of the 1,700-line
  `lib/widgets/exercise_workout_card.dart` into a new `lib/widgets/timed_log_section.dart`,
  which holds `TimedLogSection`, the panel, the compact set row and the two sheets. Delete
  `TimedSetRow`.
- **Rationale**: The redesign replaces this code completely. A separate file keeps it
  reviewable without adding a new convention; widgets already live one or two per file
  in `lib/widgets/`.
