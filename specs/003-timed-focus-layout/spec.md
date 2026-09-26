# Feature Specification: Timed Exercise Focus Layout

**Feature Branch**: `003-timed-focus-layout`

**Created**: 2026-09-26

**Status**: Draft

**Input**: User description: "Redesign the timed exercise logging screen during a workout into a 'focus' layout. Currently every timed set is a row with small minutes/seconds fields, a small stopwatch button and a weight toggle, which makes the timer buttons too small to use comfortably mid-workout. New layout: one large panel for the active set (by default the first unlogged set; tapping another set in the list selects it) showing set number, a large time display, the target and last time, and one full-width primary button that cycles Start → Stop → Log set. After stopping, the time can still be adjusted by tapping the large time, which opens a bottom sheet with minute/second pickers (also used for manual entry). The optional weight is a chip below the button that opens a picker sheet, pre-filled from the last weighted set. Logging moves to the next set, the rest countdown shows inside the big panel, and after the last set the workout auto-advances like today. Below the panel is a compact read-only list of all sets (logged with time, running, or target), where long-press unlogs, swiping removes an empty extra set, and there is an 'add extra set' action. The controller logic (stopwatch, logTimedSet, extra sets, auto-advance) stays as is; only an 'active set' selection is added. Strength, cardio and hybrid screens are unchanged."

**Builds on**: [002 – Timed Exercise Type](../002-timed-exercise-type/spec.md). All logging rules from that feature (durations, optional weight, stopwatch behaviour, extra sets, auto-advance, validation) still apply; this feature changes only how the timed logging screen is laid out and operated.

## Clarifications

### Session 2026-09-26

- Q: After tapping Stop, how can you continue or redo the timing, for example when you stopped by accident? → A: Two secondary actions appear after Stop. **Resume** continues counting from the stopped time. **Reset** returns the set to its starting time and must be hard to trigger by accident: it only works with a press-and-hold, and a normal tap only shows the hint "Hold to reset".
- Q: If you tap Start for the next set while the rest countdown is still running, what should happen? → A: Start skips the rest countdown and starts the stopwatch immediately.
- Q: Should the large time display show how close you are to the set's target while the stopwatch runs? → A: Yes. A progress ring around the large time fills up toward the target and changes colour once it's reached. It keeps counting past the target, with no sound or vibration, and is hidden when the set has no target.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Time a set with one large button (Priority: P1)

A user in the middle of a plank workout times each set with one large button: they tap Start, hold the plank, tap Stop, then tap Log set. The button is easy to hit without looking closely at the screen.

**Why this priority**: This is the problem the feature exists to solve. The current per-row stopwatch buttons are too small to use comfortably mid-workout.

**Independent Test**: Open a timed exercise with 3 planned sets in a workout, time and log all three sets using only the large button, and confirm each set is logged with its measured time.

**Acceptance Scenarios**:

1. **Given** a timed exercise with no sets logged, **When** the user opens it, **Then** a large panel shows "Set 1 / 3", a large time display, the set's target and the previous time for that set (when known), and one full-width button labelled "Start".
2. **Given** the active set is idle, **When** the user taps Start, **Then** the large time display counts up every second and the button changes to "Stop".
2a. **Given** a set with a 1:00 target and a running stopwatch at 0:30, **When** the user looks at the panel, **Then** the progress ring around the time is half full; at 1:00 it is full and changes to the "target reached" colour, and it stays that way while the time keeps counting.
3. **Given** the stopwatch is running, **When** the user taps Stop, **Then** the counting stops, the measured time stays in the large display and the button changes to "Log set".
4. **Given** a stopped set showing 0:52, **When** the user taps Log set, **Then** the set is logged as 52 seconds, it shows as done in the set list, and the next unlogged set becomes the active set.
5. **Given** the user logs the last unlogged set of the exercise, **When** it is logged, **Then** the workout moves on to the next exercise as it does today (including the extra-set rules).
6. **Given** the primary button, **When** it is displayed, **Then** it spans the full width of the panel and is at least 56 pt tall.
7. **Given** a stopped set showing 0:30, **When** the user taps **Resume**, **Then** the stopwatch continues from 0:30 (e.g. showing 0:40 ten seconds later) and the primary button reads "Stop" again.
8. **Given** a stopped set, **When** the user taps **Reset** briefly, **Then** nothing is reset and the hint "Hold to reset" is shown.
9. **Given** a stopped set, **When** the user presses and holds **Reset** for about one second, **Then** the time returns to the set's target (or 0:00 when there is no target) and the primary button reads "Start".

---

### User Story 2 - Enter or adjust a time without the stopwatch (Priority: P1)

A user who timed the set with another clock, or whose stopwatch reading is slightly off, taps the large time and sets it with minute and second pickers.

**Why this priority**: The small text fields are being removed, so this is the only way left to enter a time by hand. Without it, users could only log times measured with the in-app stopwatch.

**Independent Test**: Tap the large time on an idle set, pick 1:15, log the set, and confirm it is saved as 75 seconds. Then time a set, stop it, correct it through the picker, and confirm the corrected value is logged.

**Acceptance Scenarios**:

1. **Given** an idle active set, **When** the user taps the large time, **Then** a bottom sheet opens with a minutes picker and a seconds picker (0–59), starting at the set's target, or at 0:00 when there is no target.
2. **Given** the picker sheet, **When** the user picks 1:15 and confirms, **Then** the large display shows 1:15 and the button reads "Log set".
3. **Given** a stopped set showing 0:52, **When** the user taps the large time, **Then** the picker opens at 0:52, and the confirmed value replaces the measured time.
4. **Given** the picker sheet, **When** the user dismisses it without confirming, **Then** the displayed time is unchanged.
5. **Given** the stopwatch is running, **When** the user taps the large time, **Then** nothing opens; the time can only be adjusted after stopping.
6. **Given** the large time shows 0:00, **When** the user tries to log, **Then** the set is not logged and the existing "Enter a duration" message is shown.

---

### User Story 3 - See and manage all sets in a compact list (Priority: P2)

Below the panel, the user sees every set of the exercise in a compact list. They can pick which set to work on, undo a logged set, add an extra set, or remove an empty extra set.

**Why this priority**: Users need an overview and some control over individual sets, but the main flow already works through the active-set panel.

**Independent Test**: With 3 planned sets, log set 1, select set 3 from the list and log it, long-press set 1 to unlog it, add an extra set, and swipe the empty extra set away. Check that the list and the active set follow each step.

**Acceptance Scenarios**:

1. **Given** the set list, **When** it is displayed, **Then** each row shows the set number and one of these states: logged (with its time, and its weight if any), running (with the live time), or not logged (with its target, or "no target").
2. **Given** the set list, **When** the user taps a not-logged set, **Then** that set becomes the active set in the panel.
3. **Given** a logged set, **When** the user long-presses it, **Then** it is unlogged, as today, and becomes the active set with its previously logged time pre-filled.
4. **Given** the set list, **When** the user taps "Add extra set", **Then** a new set row appears at the end; it becomes the active set if every other set is already logged.
5. **Given** an extra set that is the last row and not logged, **When** the user swipes it away, **Then** it is removed, as today.
6. **Given** the active set, **When** the list is displayed, **Then** the active set's row is visually highlighted.
7. **Given** a logged set, **When** the user taps it, **Then** nothing changes, because logged sets cannot become the active set without being unlogged first.

---

### User Story 4 - Rest countdown and weight inside the panel (Priority: P2)

After logging a set, the rest countdown appears inside the large panel. If the user adds weight to a hold, they set it with a chip under the main button.

**Why this priority**: Rest and weight already exist; this story keeps them working and easy to reach in the new layout.

**Independent Test**: Log a set with a 60 s rest timer and check that the countdown shows in the panel and can be skipped. Set a 10 kg weight through the chip, log a set, and check that the weight is saved and pre-filled for the next set.

**Acceptance Scenarios**:

1. **Given** a set was just logged and a rest time is configured, **When** the rest countdown runs, **Then** the panel shows the remaining rest time with a "Skip" action, above the next active set's details.
2. **Given** the rest countdown is running, **When** the user taps Start for the next set, **Then** the rest countdown is skipped and the stopwatch starts.
3. **Given** the weight chip reads "+ weight", **When** the user taps it, **Then** a picker sheet opens to enter a weight in the user's weight unit, with a "Remove weight" action.
4. **Given** the previous timed set of this exercise had a weight of 10 kg, **When** the exercise is opened, **Then** the chip already shows "10 kg" (in the user's unit), and this weight is used when logging unless the user changes or removes it.
5. **Given** a weight is set, **When** the user logs the set, **Then** the set is saved with that weight, and the chip keeps the weight for the next set.
6. **Given** the weight picker, **When** the user enters a negative value, **Then** it cannot be confirmed.

---

### Edge Cases

- **All sets logged:** the panel shows "All sets done" with the "Add extra set" action, and there is no primary button.
- **Switching sets while the stopwatch runs:** tapping another set in the list stops the stopwatch and keeps the measured time on the set it was running for (the existing rule that only one stopwatch runs at a time). The tapped set becomes active.
- **Switching equipment** while the stopwatch runs: the stopwatch is discarded, because set keys depend on equipment.
- **Swapping the exercise or leaving the workout** while the stopwatch runs: the stopwatch is discarded, as today.
- **App in the background or screen locked** while running: the elapsed time stays correct, as today.
- **Times of an hour or more:** the large display shows `h:mm:ss`, and the minutes picker allows at least 180 minutes.
- **Swiping between exercises:** each exercise keeps its own active set and its entered-but-not-logged time for as long as the workout stays open.
- **Resume after a long pause:** time between Stop and Resume is not counted; only the running periods add up.
- **Past the target:** the ring stays full in the "target reached" colour, and the time keeps counting until Stop.
- **Accidental Reset:** a short tap on Reset never changes the time.
- **Converted sets ("no time recorded") from earlier workouts:** they are not offered as the previous time.
- **Small screens:** the panel and the button keep their minimum sizes, and the set list scrolls underneath.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The timed exercise screen MUST show one active-set panel and, below it, a compact list of all planned and extra sets. The per-row minutes/seconds fields, stopwatch buttons and weight toggles MUST no longer be shown.
- **FR-002**: The active set MUST default to the first not-logged set, in set order. After a set is logged, the active set MUST move to the next not-logged set.
- **FR-003**: The panel MUST show the set number and total ("Set 2 / 3"), a large time display, the set's target (or "no target"), and the previous recorded time for that set number when one exists.
- **FR-003a**: When the active set has a target above 0:00, a progress ring around the large time MUST show the stopwatch time as a fraction of the target, capped at full. From the target onward, it MUST switch to a distinct "target reached" colour. It MUST NOT play a sound or vibrate, and it MUST be hidden for sets without a target.
- **FR-004**: The panel MUST have one full-width primary button, at least 56 pt tall, that reads "Start" when idle, "Stop" while running and "Log set" once a time above 0:00 is present.
- **FR-004a**: After Stop, the panel MUST offer two secondary actions that are smaller than the primary button. **Resume** continues the stopwatch from the stopped time, so the elapsed times add up. **Reset** restores the set's starting time and only works with a press-and-hold of about one second; a normal tap only shows "Hold to reset". Neither action is shown while the stopwatch runs or while the set is idle.
- **FR-005**: Tapping the large time while the stopwatch is not running MUST open a sheet with a minutes picker and a seconds picker (0–59). Confirming replaces the displayed time; dismissing leaves it unchanged.
- **FR-006**: The set list MUST show each set's state (logged with its time and weight, running with its live time, or not logged with its target) and highlight the active set.
- **FR-007**: Tapping a not-logged set MUST make it the active set. Long-pressing a logged set MUST unlog it and make it the active set with its previous time pre-filled.
- **FR-008**: "Add extra set" and swipe-to-remove of the last empty extra set MUST work as they do today.
- **FR-009**: The rest countdown MUST be shown inside the panel with a skip action. Starting the stopwatch MUST skip a running rest countdown.
- **FR-010**: A weight chip under the primary button MUST open a weight picker in the user's unit, with a remove action. The weight MUST be pre-filled from the most recent weighted timed set of the exercise and carried over to the following sets.
- **FR-011**: Logging, validation, the stopwatch, extra sets, auto-advance and rest behaviour MUST follow the rules of feature 002. The only new behaviour is the active-set selection, the time and weight entered for sets not yet logged, and resuming a stopped stopwatch (FR-004a). A resumed stopwatch MUST still measure elapsed time from the clock, so it stays correct in the background.
- **FR-012**: The strength, cardio and hybrid logging screens MUST be unchanged.

### Key Entities

- **Active set**: The set of the current timed exercise that the panel operates on, identified by its set number within the chosen equipment. It exists only while the workout is open.
- **Pending set entry**: The time (and optional weight) entered or measured for a set that is not logged yet. It is kept per exercise and set while the workout is open.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Timing and logging one set takes 3 taps (Start, Stop, Log set), all on the same full-width button, with no scrolling.
- **SC-002**: The primary button is at least 56 pt tall and spans the panel width on every supported phone screen size.
- **SC-003**: A typed-in time can be logged in at most 4 taps (tap the time, set the pickers, confirm, Log set).
- **SC-004**: All acceptance scenarios of feature 002's Story 1 (logging) still pass with the new layout.
- **SC-005**: The strength, cardio and hybrid logging screens show no visual or behavioural change.

## Assumptions

- The redesign applies only to logging timed exercises during a workout. The program builder, tracking screen and history dialog are unchanged.
- The equipment selector at the top of the timed exercise card stays as it is.
- Pickers show whole seconds only, matching the one-second precision of feature 002.
- The active set and pending entries are not saved to the database. Leaving the workout discards them, the same as unlogged input today.
- The previous time shown is the same reference used in feature 002 (same set number and equipment, recorded time only).
