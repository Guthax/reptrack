# Implementation Plan: Timed Exercise Focus Layout

**Branch**: `003-timed-focus-layout` | **Date**: 2026-09-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/003-timed-focus-layout/spec.md`

## Summary

This replaces the per-row timed logging UI from feature 002 with a **focus layout**:
- one large panel for the active set, with a large time and a progress ring toward the
  target, and one full-width Start → Stop → Log set button;
- Resume and a press-and-hold Reset after Stop;
- picker sheets for the time and the weight;
- a compact set list underneath.

**Controller changes.** State moves into `ActiveWorkoutController`:
- the active set per exercise;
- pending entries per set, in `timedEntries`, which replaces `stopwatchResults`;
- the carried-over weight per exercise;
- a resume offset for the stopwatch.

Start skips a running rest countdown, and changing equipment discards a running stopwatch.

**No database change.** Strength, cardio and hybrid screens are untouched.

## Technical Context

**Language/Version**: Dart SDK ^3.11, Flutter 3.47.5

**Primary Dependencies**: GetX 4.7.3, Drift 2.31.0 (unchanged), Flutter's built-in
`CupertinoPicker`. No new packages.

**Storage**: None added; schema stays at v2.

**Testing**: `flutter_test` controller and util tests with the in-memory database and an
injected clock. No widget tests (Principle V).

**Target Platform**: Android and iOS.

**Project Type**: Mobile app, single Flutter project.

**Performance Goals**: The large time updates once per second; the ring animates at frame
rate without jank.

**Constraints**:
- The primary button is ≥ 56 pt tall and full width.
- A Reset needs a one-second hold.
- Stopwatch accuracy doesn't depend on the app staying in the foreground.

**Scale/Scope**:
- 1 controller extended.
- 1 new widget file, replacing about 450 lines in `exercise_workout_card.dart`.
- 1 util helper.
- 2 test files extended.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Check | Status |
|-----------|-------|--------|
| I. GetX | All new state is Rx fields in `ActiveWorkoutController`, read through `Obx`. No new screen, so no new controller. | ✅ |
| II. Layered structure | UI in `lib/widgets/timed_log_section.dart`, logic in the controller, the pure helper in `lib/utils/`. Widgets read only through controllers, never `AppDatabase`. | ✅ |
| III. Drift-only | No schema change. | ✅ (n/a) |
| IV. Error handling | Logging validation stays in `logTimedSet` (`AppSnackbar`). No new database calls. The pickers can't produce invalid values. | ✅ |
| V. Testing | Controller tests for every contract table, and a util test for `targetProgress`. The feature 002 stopwatch tests are updated from `stopwatchResults` to `timedEntries`. | ✅ |
| VI. Code quality | `///` docs, no inline comments, `const`, format and analyze. | ✅ (enforced during implementation) |
| VII. Simplicity | No new packages or layers. `CupertinoPicker` and `RawGestureDetector` are part of Flutter. | ✅ |
| Implementation constraints | Three clarifications were answered in `/speckit-clarify`. The remaining design choices are recorded in research.md (R1–R11). | ✅ |

**Post-design re-check**: still passes. Removing `stopwatchResults` changes an internal
API that only `TimedSetRow` used, and that widget is deleted in this feature. Complexity
Tracking is empty.

## Project Structure

### Documentation (this feature)

```text
specs/003-timed-focus-layout/
├── spec.md
├── plan.md              # This file
├── research.md          # R1–R11
├── data-model.md        # In-memory state + set state machine
├── quickstart.md        # Validation guide
├── contracts/
│   └── controller.md    # ActiveWorkoutController + util contract
├── checklists/
│   └── requirements.md
└── tasks.md             # /speckit-tasks (not created here)
```

### Source Code (repository root)

```text
lib/
├── controllers/
│   └── active_workout_controller.dart   # TimedSetEntry, TimedSetPhase, timedEntries,
│                                        #   timedWeightKg, active set, resume offset,
│                                        #   selectEquipment, rest skip on start
├── utils/
│   └── duration_format.dart             # + targetProgress
└── widgets/
    ├── timed_log_section.dart           # NEW: TimedLogSection, _TimedFocusPanel,
    │                                    #   _TimedSetTile, time/weight sheets, hold-to-reset
    └── exercise_workout_card.dart       # remove TimedLogSection/TimedSetRow, import new file

test/
├── controllers/
│   └── active_workout_controller_test.dart
└── utils/
    └── duration_format_test.dart
```

**Structure Decision**: Existing layered layout. The timed logging UI moves into its own
widget file, because this feature rewrites it completely (research R11).

## Implementation Order (for /speckit-tasks)

1. **Controller foundation**: `TimedSetEntry`, `TimedSetPhase`, `timedEntries` replacing
   `stopwatchResults`, stopwatch resume offset, rest skip, `selectEquipment`. Update the
   feature 002 stopwatch tests, and add tests for the new tables.
2. **Story 1**: active set logic, the panel with the big button and progress ring, the
   compact list (read-only), auto-advance, and `targetProgress` with its tests.
3. **Story 2**: time picker sheet, `setTimedEntrySeconds`, Resume, and press-and-hold Reset.
4. **Story 3**: tapping a row to select a set, long-press unlog re-activating it, add and
   remove extra sets, and the "All sets done" state.
5. **Story 4**: rest countdown inside the panel, weight chip and sheet, `timedWeightKg`
   carry-over.
6. **Polish**: remove the old widgets, format, analyze, test, and walk through the
   quickstart.

## Complexity Tracking

No constitution violations; nothing to justify.
