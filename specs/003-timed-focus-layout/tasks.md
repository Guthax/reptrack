---

description: "Task list for the timed exercise focus layout"
---

# Tasks: Timed Exercise Focus Layout

**Input**: Design documents from `/specs/003-timed-focus-layout/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/controller.md](contracts/controller.md),
[quickstart.md](quickstart.md)

**Tests**: Required. Constitution Principle V requires tests for controller and util logic.
Use the existing `timed exercises` group in
`test/controllers/active_workout_controller_test.dart`, with its injected `clock`, the
in-memory database and the `AppSnackbar` / `AppErrorHandler` overrides. No widget tests.

**Organization**: Grouped by the spec's user stories. US1 and US2 are P1; US3 and US4 are P2.

**Rules for every task** (Constitution VI and CLAUDE.md):
- Every new class and method has a `///` doc comment.
- No `//` comments inside function bodies.
- Use `const` wherever possible.
- Run `dart format` on edited files.
- Widgets never call `AppDatabase`; they go through `ActiveWorkoutController` /
  `SettingsController`.
- The row key is always `"$exerciseIndex-$equipmentId-$setNum"`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on unfinished tasks)
- **[Story]**: The user story the task belongs to (US1–US4 from spec.md)

---

## Phase 1: Setup

- [X] T001 Run `flutter analyze` and `flutter test` from the repository root and record the baseline (expected: the 9 existing info-level issues and 296 passing tests).

---

## Phase 2: Foundational (controller state shared by all stories)

**Purpose**: Entries, phases, the resume-capable stopwatch and the equipment/rest rules from
[contracts/controller.md](contracts/controller.md). Every story's UI builds on these.

**⚠️ CRITICAL**: No story UI work before this phase is complete.

### Tests (write first; they must fail before implementation)

- [X] T002 In `test/controllers/active_workout_controller_test.dart`, update the feature 002 `Stopwatch` group from `stopwatchResults` to `timedEntries`:
  - `stopwatchResults['0-1-1'] == 52` becomes `timedEntries['0-1-1']?.seconds == 52`.
  - "starting another stopwatch" expects `timedEntries['0-1-1']?.seconds == 10`.
  - The "no result" assertions become `timedEntries` being empty.
- [X] T003 In the same file, add a `Focus layout stopwatch` group covering the contract's stopwatch table:
  - start `0-1-1`, +30 s, stop, +60 s, start `0-1-1`, +10 s, stop → entry 40 s (Resume).
  - `remainingRestTime` at 45 → `startStopwatch` → `remainingRestTime == 0` (rest skip).
  - start, then `selectEquipment(0, '2')` → no entry and `runningStopwatchKey == null`; `selectedEquipments[0] == '2'`.
  - Stopping keeps an existing entry's `weightKg`.
- [X] T004 In the same file, add an `Entries and phases` group:
  - `timedPhase` is `idle` → `running` → `ready` → back to `idle` after `resetTimedEntry`.
  - `setTimedEntrySeconds(key, 48)` makes the phase `ready` with 48 s.
  - `setTimedEntrySeconds(key, 0)` removes the entry.
  - A successful `logTimedSet` stores `TimedSetEntry(seconds, weightKg)`.
  - `unlogTimedSet` keeps the entry.

### Implementation

- [X] T005 In `lib/controllers/active_workout_controller.dart`, add the top-level `///`-documented `class TimedSetEntry`:
  - `final int seconds; final double? weightKg;`
  - `const TimedSetEntry({required this.seconds, this.weightKg})`
  - `copyWith({int? seconds, double? weightKg})`
  - The data model says: "`seconds` … always > 0 (an entry of 0 is removed instead)".

  Also add `enum TimedSetPhase { idle, running, ready }`, with each value documented.
- [X] T006 In `lib/controllers/active_workout_controller.dart`, replace `stopwatchResults` with `final timedEntries = RxMap<String, TimedSetEntry>({})` and add `int _stopwatchOffsetSeconds = 0`. Rework the stopwatch per the contract:
  - **`startStopwatch(key)`:** call `skipRestTimer()`; if another key is running, `stopStopwatch()`; set `_stopwatchOffsetSeconds = timedEntries[key]?.seconds ?? 0`, `stopwatchElapsedSeconds.value = _stopwatchOffsetSeconds`; start the ticker.
  - **`_stopwatchElapsed()`** returns `_stopwatchOffsetSeconds + _clock().difference(_stopwatchStartedAt!).inSeconds`.
  - **`stopStopwatch()`** writes `timedEntries[key] = (timedEntries[key] ?? const TimedSetEntry(seconds: 0)).copyWith(seconds: elapsed)`; when `elapsed == 0`, it removes the entry instead.
  - **`_clearStopwatch()`** also resets `_stopwatchOffsetSeconds`.
  - Update all affected doc comments.
- [X] T007 In `lib/controllers/active_workout_controller.dart`, add these documented methods:
  - `void setTimedEntrySeconds(String key, int seconds)`: removes the entry when `seconds <= 0`, otherwise updates `seconds` and keeps the weight.
  - `void resetTimedEntry(String key)`: removes the entry.
  - `TimedSetPhase timedPhase(String key)`: `running` if `runningStopwatchKey.value == key`; `ready` if an entry exists and `!completedSets.contains(key)`; otherwise `idle`.
  - `void selectEquipment(int exerciseIndex, String equipmentId)`: calls `discardStopwatch()`, then sets `selectedEquipments[exerciseIndex] = equipmentId`.

  In `logTimedSet`, after a successful insert, store `timedEntries[key] = TimedSetEntry(seconds: durationSeconds, weightKg: weightKg)`.
- [X] T008 Keep the app compiling until US1 replaces the old UI: in `lib/widgets/exercise_workout_card.dart`, change `_TimedSetRowState` to read and consume `controller.timedEntries[_rowKey]?.seconds` instead of `stopwatchResults` in `_applyStopwatchResult` and its `ever` worker. Don't remove the entry in the old row.
- [X] T009 Run `flutter test test/controllers/active_workout_controller_test.dart` and make T002–T004 pass.

**Checkpoint**: The controller supports entries, phases, Resume, Reset, rest skip and
discarding on equipment change; all existing tests pass.

---

## Phase 3: User Story 1 – Time a set with one large button (Priority: P1) 🎯 MVP

**Goal**: The panel shows the active set with a large time, target, last time and progress
ring, and one full-width Start → Stop → Log set button. A compact read-only set list sits
below it.

**Independent Test**: quickstart §2, steps 1–3 and 6. Time and log 3 sets using only the big
button; the workout moves on after the last set.

### Tests (write first)

- [X] T010 [P] [US1] In `test/utils/duration_format_test.dart`, add a `targetProgress` group with the contract table: (30, 60) → 0.5, (90, 60) → 1.0, (0, 60) → 0.0, (30, 0) → null.
- [X] T011 [P] [US1] In `test/controllers/active_workout_controller_test.dart`, add an `Active set` group covering these rows of the contract's active-set table: nothing logged → 1; set 1 logged → 2; all 3 logged → `null`; all logged then `addExtraSet(0, '1')` → 4. Log sets through `logTimedSet`.

### Implementation

- [X] T012 [P] [US1] In `lib/utils/duration_format.dart`, add the documented `double? targetProgress(int seconds, int targetSeconds)`: returns `null` when `targetSeconds <= 0`, otherwise `(seconds / targetSeconds).clamp(0.0, 1.0)`.
- [X] T013 [US1] In `lib/controllers/active_workout_controller.dart`, add `final _activeTimedOverride = RxMap<int, int>({})` and the documented `int? activeTimedSetNum(int exerciseIndex, String equipmentId, int totalSets)`:
  - Return the override if it is within `1..totalSets` and not in `completedSets`.
  - Otherwise return the first `setNum` in `1..totalSets` that isn't completed.
  - Otherwise return `null`.

  In `logTimedSet`, after success, call `_activeTimedOverride.remove(exerciseIndex)`.
- [X] T014 [US1] Create `lib/widgets/timed_log_section.dart` with the documented `TimedLogSection` (same constructor as today: `item`, `exerciseIndex`, `alternatives`):
  - The equipment `ChoiceChip`s call `controller.selectEquipment(...)`.
  - Inside `Obx`, compute `equipmentId`, `planned = item.volume.setsSecondsList`, `totalSets = getTotalSetsForExercise(...)` and `active = activeTimedSetNum(...)`.
  - Render `_TimedFocusPanel` (T015) on top and `_TimedSetList` (T016) in an `Expanded` below.
  - The target for a set is `planned[setNum - 1]`, or `planned.last` for extra sets (0 = no target).
- [X] T015 [US1] In `lib/widgets/timed_log_section.dart`, add the documented `_TimedFocusPanel`. It shows:
  - "Set N / total" and the large time: the live `stopwatchElapsedSeconds` when running; the entry time when ready; otherwise the target dimmed, or `0:00`. Always rendered with `formatDuration`.
  - A `CircularProgressIndicator(value: targetProgress(...))` behind the time. Its colour is `AppColors.secondary` below the target and `AppColors.success` at or above it. It is hidden when `targetProgress` returns `null`.
  - A "target m:ss" or "no target" line, plus "last m:ss" from `getPastTimedSetData`.
  - A full-width `SizedBox(height: 56)` `ElevatedButton`:
    - **Start** (idle) → `startStopwatch(key)`.
    - **Stop** (running) → `stopStopwatch()`.
    - **Log set** (ready) → `logTimedSet(..., durationSeconds: entry.seconds, weightKg: controller.timedWeightKg[exerciseIndex], restSeconds: item.volume.restTimer ?? 60)`; on `true`, if `shouldAutoAdvance(...)` then `pageController.nextPage(...)`, as `HybridSetRow` does.
  - When `active == null`: "All sets done" and no primary button.
- [X] T016 [US1] In `lib/widgets/timed_log_section.dart`, add the documented `_TimedSetList` / `_TimedSetTile`: one compact row per set showing the set number and its state:
  - logged → `formatTimedSet(entry or past…)`: the logged entry's time, plus the weight in the user's unit;
  - running → the live time;
  - otherwise → "target m:ss" or "no target".

  The active row is highlighted with an `AppColors.secondary` border. The rows are read-only in this story.
- [X] T017 [US1] In `lib/widgets/exercise_workout_card.dart`, import `timed_log_section.dart` and delete the old `TimedLogSection`, `TimedSetRow` and `_TimedSetRowState`, together with the imports that become unused (`constants.dart` if nothing else uses it). The `else if (item.isTimed)` branch keeps constructing `TimedLogSection`.
- [X] T018 [US1] Run `flutter test test/utils/duration_format_test.dart test/controllers/active_workout_controller_test.dart` and make T010–T011 pass.

**Checkpoint**: A timed exercise can be timed and logged entirely with the big button.

---

## Phase 4: User Story 2 – Enter or adjust a time without the stopwatch (Priority: P1)

**Goal**: Tapping the large time opens minute and second pickers. After Stop, Resume and a
press-and-hold Reset are available.

**Independent Test**: quickstart §3, plus §2 steps 4–5 (Resume, hold-to-reset).

### Implementation

- [X] T019 [US2] In `lib/widgets/timed_log_section.dart`, add the documented `Future<int?> showTimedDurationSheet(BuildContext context, int initialSeconds)`:
  - A `showModalBottomSheet` with two `CupertinoPicker` wheels (minutes `0..180`, seconds `0..59`), starting at `initialSeconds`, with Cancel and Done.
  - Done returns `minutes * 60 + seconds`; Cancel or dismissing returns `null`.
- [X] T020 [US2] In `_TimedFocusPanel`, make the large time tappable when the phase is not `running`:
  - Open `showTimedDurationSheet` with the entry time, the target, or 0.
  - On a non-null result, call `controller.setTimedEntrySeconds(key, result)`.
  - While running, taps do nothing.
- [X] T021 [US2] In `_TimedFocusPanel`, when the phase is `ready`, add a row of two smaller secondary actions under the primary button:
  - **Resume**: an `OutlinedButton` that calls `startStopwatch(key)`.
  - **Reset**: a `Tooltip(message: 'Hold to reset', triggerMode: TooltipTriggerMode.tap)` wrapping a `RawGestureDetector` with `LongPressGestureRecognizer(duration: const Duration(seconds: 1))` that calls `controller.resetTimedEntry(key)`.

  Neither is shown when idle or running.

**Checkpoint**: Times can be typed in, corrected, resumed and reset without the small fields.

---

## Phase 5: User Story 3 – See and manage all sets in a compact list (Priority: P2)

**Goal**: Tap to select a set, long-press to unlog, add and swipe away extra sets.

**Independent Test**: quickstart §4, steps 2 and 4.

### Tests (write first)

- [X] T022 [US3] In `test/controllers/active_workout_controller_test.dart`, extend the `Active set` group with the remaining contract rows:
  - `selectTimedSet(0, '1', 3)` with set 1 logged → 3.
  - `selectTimedSet(0, '1', 3)`, then set 3 logged → the first unlogged set.
  - `selectTimedSet(0, '1', 2)` while set 2 is logged → unchanged.
  - start `0-1-1`, `selectTimedSet(0, '1', 2)` → stopwatch stopped, entry `0-1-1` > 0, active 2.
  - `unlogTimedSet` of set 1 → active 1 with its entry kept.

### Implementation

- [X] T023 [US3] In `lib/controllers/active_workout_controller.dart`, add the documented `void selectTimedSet(int exerciseIndex, String equipmentId, int setNum)`:
  - Do nothing if `"$exerciseIndex-$equipmentId-$setNum"` is completed.
  - If a stopwatch runs for another key, `stopStopwatch()`.
  - Set `_activeTimedOverride[exerciseIndex] = setNum`.

  In `unlogTimedSet`, after success, call `selectTimedSet(exerciseIndex, equipmentId, setNum)`.
- [X] T024 [US3] In `lib/widgets/timed_log_section.dart`, make `_TimedSetTile` interactive:
  - A tap on a not-logged row → `selectTimedSet`.
  - A long-press on a logged row → `unlogTimedSet`.
  - Taps on logged rows do nothing.
  - Wrap the rows in `Dismissible`, with the same rule as today: only the last row, only when it's an unlogged extra set, and only start-to-end; `onDismissed` → `removeExtraSet`.
  - Add an "ADD EXTRA SET" `OutlinedButton` at the end of the list (`addExtraSet`), also shown in the panel's "All sets done" state.
- [X] T025 [US3] Run `flutter test test/controllers/active_workout_controller_test.dart` and make T022 pass.

**Checkpoint**: The set list is fully functional.

---

## Phase 6: User Story 4 – Rest countdown and weight inside the panel (Priority: P2)

**Goal**: The rest countdown shows in the panel, and the weight chip and sheet carry the
weight to the next sets.

**Independent Test**: quickstart §2 step 7 and §4 step 1. Rest inside the panel, Start skips
the rest, and the 10 kg weight is saved and pre-filled.

### Tests (write first)

- [X] T026 [US4] In `test/controllers/active_workout_controller_test.dart`, add a `Timed weight` group:
  - After setup, `timedWeightKg[0] == 12.5` (from the seeded past weighted set).
  - `setTimedWeight(0, 10)`, then `logTimedSet(..., weightKg: timed.timedWeightKg[0])` → the entry and the database row have 10.0, and `timedWeightKg[0]` is still 10.
  - `setTimedWeight(0, null)` clears it.
  - `addExerciseDuringWorkout` with a timed exercise initialises `timedWeightKg` for the new index.

### Implementation

- [X] T027 [US4] In `lib/controllers/active_workout_controller.dart`, add `final timedWeightKg = RxMap<int, double?>({})` and the documented `void setTimedWeight(int exerciseIndex, double? weightKg)`. Initialise `timedWeightKg[index] = getLastTimedWeight(exerciseId)` for timed items in `_setupWorkout` (after prefetch), `swapExercise` (timed branch) and `addExerciseDuringWorkout` (timed branch).
- [X] T028 [US4] In `lib/widgets/timed_log_section.dart`, add the documented `Future<void> showTimedWeightSheet(BuildContext context, int exerciseIndex)`:
  - A bottom sheet with a decimal `TextField` in the user's unit, pre-filled via `SettingsController.displayWeight`, with `FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))` and `MaxValueInputFormatter(100000)`.
  - Actions: Remove weight → `setTimedWeight(i, null)`; Cancel; Done → `setTimedWeight(i, settings.toKg(value))`, or `null` when the field is empty.
- [X] T029 [US4] In `_TimedFocusPanel`:
  - Add an `ActionChip` under the primary button reading "+ weight", or the weight in the user's unit (e.g. "10 kg"), which opens `showTimedWeightSheet`.
  - When `remainingRestTime > 0`, show a rest strip at the top of the panel: "Rest 0:45" via `formatDuration` and a SKIP `TextButton` → `skipRestTimer()`.
  - Remove the separate bottom rest container from `TimedLogSection`.
- [X] T030 [US4] Run `flutter test test/controllers/active_workout_controller_test.dart` and make T026 pass.

**Checkpoint**: All four stories work.

---

## Phase 7: Polish

- [X] T031 Check that `lib/widgets/exercise_workout_card.dart` no longer contains timed-specific UI apart from the header label, the history `isTimed` flag and the `TimedLogSection` branch. Check that `grep -rn "stopwatchResults" lib test` returns nothing.
- [X] T032 [P] Review the doc comments in `lib/controllers/active_workout_controller.dart` for the stopwatch, entries and active set, so they describe the new behaviour. Make sure no `//` comments were added inside function bodies.
- [X] T033 Run `dart format lib test`, then `flutter analyze` (no new issues compared with the 9 baseline issues), then `flutter test` (all pass).
- [ ] T034 Walk through [quickstart.md](quickstart.md) §2–§4 on a device or emulator, including §4 step 6 (the strength, cardio and hybrid screens are unchanged).

---

## Dependencies and execution order

- **Phase 1 → Phase 2**, which blocks all stories.
- **US1 (Phase 3)** depends on Phase 2.
- **US2, US3 and US4** depend on US1's widget file (T014–T016) and can then proceed in any
  order. They all touch `timed_log_section.dart`, so they run one after another.
- **Polish** comes after all stories.

Within phases:
- Tests are written before the code they cover: T002–T004 before T005–T008, T010–T011 before
  T012–T016, T022 before T023–T024, and T026 before T027–T029.
- T005 → T006 → T007, same file.
- T013 → T023 → T027, all in the controller.
- T014 → T015 → T016 → T020 → T021 → T024 → T028 → T029, all in `timed_log_section.dart`.

## Parallel opportunities

- T010 and T011 (different test files), and T012 alongside T013.
- T032 alongside T031.

## Implementation strategy

1. **MVP: Phase 2 + US1.** The big-button flow works end to end; stop and validate with
   quickstart §2.
2. **US2** adds picker entry, Resume and Reset. Together with US1 it covers all P1 needs and
   replaces the old UI completely.
3. **US3, then US4.**
4. **Polish.**

Never commit or push; the user does that themselves (CLAUDE.md).

## Implementation notes (2026-09-26)

- **Order:** the controller parts of US3 (T022/T023) and US4 (T026/T027) were implemented and
  tested before the widget file, so `timed_log_section.dart` could be written in one pass
  (T014–T016, T019–T021, T024, T028–T029). Tests were still written before the code they
  cover.
- **Weight sheet:** it is a small `StatefulWidget` (`_TimedWeightSheet`), so its text
  controller is disposed with the sheet and not while the sheet is still closing.
- **Rebuilds:** the active-set body has its own `Obx`, so the live stopwatch time and the
  entry changes rebuild it.
- **Analyzer:** `flutter analyze` still reports only the 9 info-level issues that existed
  before this feature.
- **T034:** not done. It needs a device or emulator (quickstart §2–§4).
