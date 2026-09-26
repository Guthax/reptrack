# Feature Specification: Timed Exercise Type

**Feature Branch**: `002-timed-exercise-type`

**Created**: 2026-09-26

**Status**: Draft

**Input**: User description: "Right now, the following exercise types exist: Strength, which is logged by kgs and reps; Cardio, which is logged by distance; and Hybrid, which is logged by distance and kgs. I need a new exercise type, which is logged by time. This is for exercises like the plank etc. Add this exercise, keeping the database backwards compatible."

## Clarifications

### Session 2026-09-26

- Q: When existing hold sets are converted to timed sets, how should their reps value become a time? → A: Don't guess. Converted sets get a duration of 0 seconds ("no time recorded") and are left out of the tracking chart; only the fact that the set was done is kept.
- Q: Should a timed set also be able to store a weight, so a weighted plank or weighted wall sit can be logged? → A: Yes. Time plus an optional weight (kg); the weight input is hidden until the user expands it, and the weight is shown in history when present.
- Q: When logging a timed set, should the app have a built-in timer, or does the user type in the time? → A: Both. The time can be typed in, or a start/stop stopwatch in the set row fills it in. There is no countdown or alert.
- Q: Now that timed sets can store a weight, should the built-in "Isometric Curl Hold" also become Timed? → A: Yes, it is added to the list of hold exercises that become Timed.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Log a timed exercise during a workout (Priority: P1)

A user doing a workout that contains a hold exercise such as a plank records how long they held each set, instead of being forced to enter reps. For a weighted hold they can also add the weight used.

**Why this priority**: Logging the actual performance is the core value of the app; without it the new type is useless.

**Independent Test**: With a program day containing a timed exercise, start the workout, enter a duration for each set, mark the sets done, finish the workout and confirm the durations are stored and shown when the workout is revisited.

**Acceptance Scenarios**:

1. **Given** an active workout containing a timed exercise with 3 planned sets of 60 seconds, **When** the user opens that exercise, **Then** they see 3 set rows that each ask for a duration (minutes and seconds), with no reps or distance inputs, and with the weight input hidden until the user expands it.
2. **Given** a timed set row, **When** the user enters 1:15 and logs the set, **Then** the set is saved as 75 seconds and marked complete.
3. **Given** a logged timed set, **When** the user un-logs it, **Then** the set is no longer recorded for that workout.
4. **Given** the user has logged this timed exercise in a previous workout, **When** they open it in a new workout, **Then** the previous duration for each set is shown as a reference, the same way previous values are shown for other types.
5. **Given** a timed set row, **When** the user expands the weight input, enters 1:00 and 10 kg and logs the set, **Then** the set is saved as 60 seconds with 10 kg, and history shows "1:00 · 10 kg".
6. **Given** a timed set row, **When** the user taps start, holds the plank and taps stop after 52 seconds, **Then** the duration field shows 0:52, and the user can still edit it before logging the set.
7. **Given** a timed exercise whose previous set was logged with a weight, **When** the user opens it in a new workout, **Then** the weight input is already expanded and filled in with that weight.
8. **Given** a timed set row, **When** the user tries to log it with an empty or zero duration, **Then** the set is not saved and the user is told to enter a valid duration.

---

### User Story 2 - Create a timed exercise and add it to a program (Priority: P1)

A user creates a new exercise, chooses "Timed" as its type, and adds it to a workout day with a number of sets and a target duration per set.

**Why this priority**: Users cannot log timed exercises until they can define them and put them in a program; it ships together with Story 1.

**Independent Test**: Create an exercise of type Timed, add it to a program day with 3 sets of 45 seconds and a rest timer, reopen the program and confirm the plan is kept.

**Acceptance Scenarios**:

1. **Given** the create-exercise dialog, **When** the user views the type options, **Then** "Timed" is offered alongside Strength, Cardio and Hybrid, with a short description (e.g. "Logged by time").
2. **Given** the create-exercise dialog with "Timed" selected, **When** the user fills in a name and saves, **Then** the new exercise is stored as Timed and can be found and added to programs straight away.
3. **Given** a timed exercise, **When** the user adds it to a workout day, **Then** they can set the number of sets, a target duration per set and an optional rest timer.
4. **Given** a timed exercise in a program, **When** the user edits it, **Then** they can change the sets, target durations and rest timer, and the program view labels the exercise as Timed.
5. **Given** a timed exercise in a program, **When** the user removes it, **Then** it disappears from the day and the order of the remaining exercises is kept.
6. **Given** an active workout, **When** the user swaps any exercise for a timed exercise (or a timed exercise for any other exercise), **Then** the replacement shows the input rows that match its own type, keeping the rest timer, the same way swaps between Strength, Cardio and Hybrid work today.

---

### User Story 3 - See progress for a timed exercise (Priority: P2)

A user opens the tracking screen for a timed exercise and sees how their hold times have developed over time.

**Why this priority**: Progress tracking is valuable but the feature is already usable without it.

**Independent Test**: Log a timed exercise in several workouts on different days, open it in tracking and confirm the chart and history show the durations per day.

**Acceptance Scenarios**:

1. **Given** a timed exercise with history, **When** the user selects it in tracking, **Then** a chart shows duration over time, with the longest hold per workout day as the default metric.
2. **Given** the timed exercise chart, **When** the user switches metric, **Then** they can choose between "Longest hold" (longest single set per day) and "Total time" (sum of all set durations per day), in the same way strength offers max weight and total volume.
3. **Given** a timed exercise with history, **When** the user views its history, **Then** each past workout lists its sets with durations shown as minutes and seconds, followed by the weight for sets that have one.
4. **Given** a timed exercise without history, **When** the user selects it, **Then** an empty state is shown, as for other types.

---

### User Story 4 - Existing data keeps working after the update (Priority: P1)

A user who already has programs, exercises and workout history installs the update. Everything they had before is still there, and the built-in hold exercises (such as Plank) become Timed, with their past sets and program entries converted. Past sets keep that they were done but get no time, because the old reps value is not a reliable time.

**Why this priority**: Losing or corrupting existing training history is unacceptable; the user explicitly asked for backwards compatibility.

**Independent Test**: Take a database from the current app version filled with strength, cardio and hybrid programs and history, including logged Plank sets and a program containing Plank. Open it with the new version and confirm that all other data is unchanged, the Timed type is available, and the Plank history and program entry are now timed, with sets marked as "no time recorded" and empty target durations.

**Acceptance Scenarios**:

1. **Given** a database from the previous app version, **When** the new version opens it, **Then** all exercises, programs, workouts and sets other than the converted hold exercises are kept with their original values and types.
2. **Given** a database from the previous app version, **When** the new version opens it, **Then** the Timed exercise type is available for creating exercises without the user doing anything.
3. **Given** a database with Plank logged as 3 strength sets of 45 reps at 0 kg in a past workout, **When** the new version opens it, **Then** that workout shows 3 timed Plank sets marked "no time recorded" (0 seconds) on the same date, with the same set numbers and completion state.
4. **Given** a program day containing Plank planned as 3 sets of 30 reps with a 60-second rest timer, **When** the new version opens it, **Then** the day contains Plank as a timed exercise with 3 sets with no target duration, the same position in the day, the same equipment and the same rest timer.
5. **Given** a user-created exercise, or a built-in exercise that is not on the hold list, **When** the new version opens the database, **Then** its type and history are unchanged.
6. **Given** a fresh install, **When** the app starts, **Then** Strength, Cardio, Hybrid and Timed are all available, and the built-in hold exercises are Timed from the start.

---

### Edge Cases

- Durations above one hour (e.g. a long wall sit): the input must accept them and display them as hours, minutes and seconds or as total minutes and seconds without truncation.
- Seconds input of 60 or more (e.g. "0:90"): normalised to 1:30 or rejected with a clear message.
- A user logs more sets than planned (extra sets): extra timed sets are saved and numbered like extra sets of other types.
- Auto-advance to the next set/exercise after logging behaves the same as for other types, including extra sets.
- Deleting a timed exercise, program or workout removes its timed sets and plan entries the same way it does for other types.
- A timed exercise with no target duration set in the program: set rows start empty and the user enters the duration.
- A timed set logged without expanding the weight input, or with the weight left empty, has no weight; it is not stored as 0 kg, and history shows the duration only.
- A negative weight is rejected with a fixable validation message.
- Stopwatch left running while the app is in the background or the screen is off: the elapsed time stays correct, because it is measured from the moment start was tapped.
- Stopwatch started on a second set row while another is running: the first stops and its elapsed time is filled into its row, so only one stopwatch runs at a time.
- User logs a set while its stopwatch is still running: the stopwatch stops, fills in the time and the set is logged with that time.
- Stopwatch running when the user leaves the workout or swaps the exercise: the stopwatch is discarded and nothing is filled in.
- Stopwatch reaches the target duration: nothing happens (no countdown, sound or vibration); it keeps counting until stopped.
- Converted sets have 0 seconds: history shows them as "no time recorded" rather than "0:00", and they are left out of both chart metrics. A day with only converted sets shows no chart point.
- In a new workout, a converted set is not offered as a previous-duration reference; the row starts empty.
- A converted hold exercise had a weight logged (e.g. a weighted plank): a weight above 0 kg is kept as the timed set's weight, and a weight of 0 kg becomes "no weight".
- The upgrade is interrupted (e.g. the app is killed during the first launch): either the whole conversion is applied or none of it, so no exercise ends up half converted.
- A built-in hold exercise has been renamed by the user: it is no longer recognised and stays Strength. The user can still create a Timed exercise themselves.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST offer a fourth exercise type, "Timed", whose sets are recorded as a duration plus an optional weight in kg.
- **FR-002**: The create-exercise dialog MUST offer "Timed" as a selectable exercise type next to Strength, Cardio and Hybrid. Users MUST be able to create and edit exercises of type Timed with the same name, note, muscle group and equipment options as other types.
- **FR-003**: Users MUST be able to add a timed exercise to a workout day with a number of sets, a target duration per set and an optional rest timer, and to edit, reorder, swap and remove it.
- **FR-004**: During a workout, a timed exercise MUST show one row per planned set with a duration input (minutes and seconds), and MUST let the user log, un-log and add extra sets.
- **FR-004a**: Each timed set row MUST offer a start/stop stopwatch. Stopping it MUST fill the elapsed time, rounded down to whole seconds, into that row's duration field without logging the set. At most one stopwatch MAY run at a time, and elapsed time MUST stay correct while the app is in the background.
- **FR-004b**: Each timed set row MUST offer an optional weight input that is collapsed by default. It MUST start expanded and filled in when the previous set of that exercise had a weight. An empty weight MUST be stored as "no weight"; a negative weight MUST be reported as a fixable validation message.
- **FR-005**: Durations MUST be stored with one-second precision and MUST be greater than zero to be logged by the user (0 seconds is reserved for converted sets, see FR-013); invalid input MUST be reported to the user as a fixable validation message.
- **FR-006**: Previously logged durations for the same exercise MUST be shown as a reference when logging, consistent with the other types.
- **FR-007**: The rest timer MUST start after logging a timed set when a rest time is configured, consistent with strength sets.
- **FR-008**: The tracking screen MUST show a duration-over-time progress chart for timed exercises, with two selectable metrics: "Longest hold" (longest single set per day, the default) and "Total time" (sum of set durations per day). It MUST also show the set history. Sets with 0 seconds MUST be shown as "no time recorded" and MUST be excluded from both chart metrics and from previous-duration references (FR-006).
- **FR-009**: Everywhere the exercise type is shown (program builder, workout card, exercise lists), timed exercises MUST be labelled "Timed".
- **FR-010**: Upgrading from the previous app version MUST make the Timed type available automatically, and MUST keep all existing exercises, programs, workouts and logged sets intact and unchanged, except for the hold exercises converted under FR-012.
- **FR-011**: The upgrade MUST NOT require the user to reinstall the app, clear data or take any manual action.
- **FR-012**: These built-in hold exercises MUST become Timed, on both fresh installs and upgrades, matched by name (case-insensitive): Plank, Side Plank, Copenhagen Plank, Wall Sit, Hollow Body Hold, L-Sit and Isometric Curl Hold.
- **FR-013**: On upgrade, every logged strength set of a converted exercise MUST be converted into a timed set on the same workout, with the same exercise, equipment, set number, completion state and date logged. The duration is set to 0 seconds, meaning "no time recorded", and the reps value is dropped. A weight above 0 kg is kept as the set's weight; 0 kg becomes "no weight".
- **FR-014**: On upgrade, every program entry of a converted exercise MUST be converted into a timed program entry with the same workout day, position, equipment and rest timer. The number of planned sets is kept, but each target duration is left empty.
- **FR-015**: The conversion MUST be all-or-nothing and MUST run only once. After it, no strength sets or strength program entries MAY remain for the converted exercises.
- **FR-016**: Exercises that are not on the FR-012 list, including user-created exercises, MUST NOT be converted.

### Key Entities

- **Exercise Type**: The category of an exercise that decides how it is planned and logged. Gains a fourth value, Timed, next to Strength, Cardio and Hybrid.
- **Program Timed Exercise**: A timed exercise planned on a workout day: the exercise, its position in the day, optional equipment, a list of target durations (one per set) and an optional rest timer.
- **Workout Timed Set**: One logged set of a timed exercise in a workout: the exercise, optional equipment, set number, duration in seconds (0 = no time recorded, only possible for converted sets), optional weight in kg, completed flag and date logged.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can create a timed exercise, add it to a program and log a first set in under 2 minutes.
- **SC-002**: Logging a timed set takes no more taps than logging a strength set.
- **SC-003**: After upgrading, 100% of existing exercises, programs, workouts and sets are present. Those not on the hold list have identical values, and every converted set and program entry keeps its workout, date, set number or position, equipment and completion state.
- **SC-006**: After upgrading, the number of logged sets per workout is identical to before the upgrade. No history rows are lost by the conversion.
- **SC-004**: Timed exercises appear in every place the other three types appear (creation, program builder, workout, swap, tracking, history), with no screen missing support.
- **SC-005**: Durations shown anywhere in the app match the logged duration to the second.

## Assumptions

- Timed sets record a duration and an optional weight, but no reps. The tracking chart plots duration only; charting weight for timed exercises is out of scope.
- Program entries for timed exercises plan durations only; a planned weight is not part of the program. The weight is carried over from the previous set instead (FR-004b).
- The duration is typed in or filled in by the per-set stopwatch (FR-004a). A countdown to the target, and sounds or vibrations, are out of scope.
- Stopping the stopwatch does not log the set automatically; the user logs it with the same single action as today, so the rest timer and auto-advance behave as for manually entered sets.
- Durations are entered and displayed as minutes and seconds (m:ss).
- Timed exercises support optional equipment selection like strength and hybrid exercises.
- Swapping during a workout already allows any exercise type as the replacement; Timed joins that behaviour, and the swap list labels timed exercises as such.
- When converting, no time is derived from old reps values, because it is unknown what users typed into the reps field for holds. Program entries follow the same rule and keep only their set count.
- The hold list is limited to exercises that are purely a static hold. Rep-based plank variations (Plank Hip Dip, Plank Reach, Plank Row) stay Strength, because their reps carry meaning that time cannot capture. Isometric Curl Hold is converted, because it is a pure hold and its weight is kept.
- Hold exercises are recognised by name, case-insensitively, because built-in exercises get no stable identity when they are added. Renamed exercises are therefore not converted.
- This is a single-user, offline app; no sync or multi-device concerns apply.
