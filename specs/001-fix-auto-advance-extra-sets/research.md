# Research: Auto-Advance Only After All Sets Are Logged

There were no NEEDS CLARIFICATION items in the Technical Context. The research below records the
root cause and the design decisions.

## R1. Root cause

- **Finding**: `SetLogRow` (strength, `lib/widgets/exercise_workout_card.dart` ~L1146) and
  `HybridSetRow` (hybrid, ~L1373) compute `allDone` with
  `List.generate(widget.totalPlannedSets, ...)`. `totalPlannedSets` is passed from the card as
  `plannedSetsReps.length` / `plannedDistances.length`, which is the program count only. The card
  itself renders `getTotalSetsForExercise(...)` rows (planned plus `extraSetsCount`), so the list
  on screen and the completion check disagree.
- **Effect**: with 3 planned sets and 1 extra set, logging sets 1 to 3 satisfies the check and
  the page advances while set 4 is still open.

## R2. Where the completion decision lives

- **Decision**: Add `isExerciseComplete` and `shouldAutoAdvance` to `ActiveWorkoutController`.
  The widgets only call `shouldAutoAdvance` and, when it returns true, trigger
  `pageController.nextPage`.
- **Rationale**: Constitution Principles II and V. Logic belongs in the controller and must be
  covered by unit tests, which are not possible while it sits inline in a widget callback (UI
  tests are out of scope). This also removes the duplicated block in the two rows.
- **Alternatives considered**:
  - Pass `totalSets` (planned plus extra) into the rows instead of `totalPlannedSets`. This is
    the smallest diff, but the logic stays untestable in widgets and duplicated, and the count
    would be captured at row build time and could go stale.
  - Move `nextPage` itself into the controller (`advanceIfExerciseComplete`). This was rejected
    because `PageController.nextPage` needs attached clients, which makes the controller method
    impossible to test without widget infrastructure.

## R3. "Is there a next exercise" check

- **Decision**: `shouldAutoAdvance` returns false when
  `exerciseIndex >= exercisesWithVolume.length - 1`.
- **Rationale**: The set being logged is always on the visible card, so `exerciseIndex` equals
  `currentPageIndex` at that moment. Using `exerciseIndex` keeps the method independent of page
  view state and testable. Behaviour is unchanged (FR-004).
- **Alternatives considered**: Keep reading `currentPageIndex`. This is equivalent in practice
  but couples the logic to page state that tests would have to set up by hand.

## R4. Which sets count

- **Decision**: Sets `1..getTotalSetsForExercise(exerciseIndex, plannedSets, equipmentId)` for
  the equipment currently selected. A set counts as done if
  `isSetCompleted(exerciseIndex, equipmentId, setNum)` returns true.
- **Rationale**: This matches exactly what the card renders, including out-of-order logging
  (spec edge case).

## R5. Triggers

- **Decision**: Only the log actions (`SetLogRow` and `HybridSetRow` check buttons) call
  `shouldAutoAdvance`. `addExtraSet`, `removeExtraSet`, `unlogSet` and `unlogHybridSet` are not
  changed.
- **Rationale**: FR-003. This preserves the current trigger model.

## R6. Cardio

- **Decision**: No change. The cardio card has a single entry, no extra sets and no auto-advance
  path today.
