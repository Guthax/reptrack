# Feature Specification: Create Exercise From Swap Dialog

**Feature Branch**: `feature/add-exercise-during-workout`

**Created**: 2026-09-26

**Status**: Draft

**Input**: User description: "Right now, exercises can only added outside the current workout. Adds the following: To the swap exercise dialog during a workout, add a small + icon to the top right, which opens the add exercise dialog for the user. When the user then creates a new exercise, replace the current exercise with that exercise."

## Clarifications

### Session 2026-09-26

- Q: When the user taps "+" in the swap dialog, which dialog should open? → A: The create new exercise dialog (name, type, muscle groups, equipment, note); set targets and rest timer are carried over from the replaced exercise using the existing swap rules.
- Q: When the new exercise is a different type from the one it replaces, should the swap use the existing rules, or keep the set count across all types? → A: Use the existing swap rules unchanged, for both new and existing exercises; improving cross-type defaults is out of scope.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create a new exercise and swap it in mid-workout (Priority: P1)

A user is tracking a workout and wants to replace the current exercise with one that does not exist in their exercise library yet (for example, the gym's machine is taken and they use an unfamiliar alternative). Today they would have to leave the workout to create the exercise. Instead, they open the swap exercise dialog, tap a small "+" icon in the top-right corner of the dialog, fill in the existing "create new exercise" form, and confirm. The newly created exercise immediately replaces the exercise they were swapping, and they can continue logging sets without leaving the workout.

**Why this priority**: This is the entire feature; it removes the need to abandon an active workout just to add a missing exercise.

**Independent Test**: Start a workout, open the swap dialog on any exercise, tap "+", create an exercise named "Test Row", confirm, and verify that the workout now shows "Test Row" in place of the original exercise and that "Test Row" appears in the exercise library afterwards.

**Acceptance Scenarios**:

1. **Given** an active workout with the swap dialog open for exercise A, **When** the user looks at the dialog header, **Then** a small "+" icon is visible in the top-right corner of the dialog.
2. **Given** the swap dialog is open for exercise A, **When** the user taps the "+" icon, **Then** the create new exercise dialog opens with the same fields and defaults it has elsewhere in the app.
3. **Given** the create new exercise dialog was opened from the swap dialog, **When** the user enters valid details and confirms, **Then** the new exercise is saved to the exercise library, exercise A is replaced by the new exercise at the same position in the workout, and the swap dialog is closed.
4. **Given** the new exercise was swapped in, **When** the user views it in the workout, **Then** it behaves exactly as if the user had picked that exercise from the swap list (same exercise-type handling, same position, same default equipment selection).

---

### User Story 2 - Back out without changing the workout (Priority: P2)

A user taps "+" in the swap dialog but changes their mind, or the exercise they try to create is invalid.

**Why this priority**: Protects the in-progress workout from accidental changes; secondary to the main flow.

**Independent Test**: Open the swap dialog, tap "+", then cancel the create dialog; verify the workout is unchanged and the swap dialog is still available.

**Acceptance Scenarios**:

1. **Given** the create new exercise dialog was opened from the swap dialog, **When** the user cancels it, **Then** no exercise is created, the current exercise is not replaced, and the user is returned to the swap dialog.
2. **Given** the create new exercise dialog was opened from the swap dialog, **When** the user submits invalid details (e.g. an empty or duplicate name), **Then** the same validation feedback shown elsewhere in the app appears, the create dialog stays open, and the workout is unchanged.

---

### User Story 3 - Create a new exercise while adding one to the workout (Priority: P2)

A user wants to add an extra exercise to the current workout, but it isn't in their exercise library yet. In the add-exercise dialog during the workout, they tap a small "+" icon in the top-right corner, fill in the create new exercise form and confirm. The new exercise is added to the end of the workout straight away, just like the swap flow.

**Why this priority**: Same need as US1 for the other workout dialog. It's independent of US1 and adds value on its own.

**Independent Test**: Start a workout, open the add-exercise dialog, tap "+", create "Test Fly" and confirm. It appears as the last exercise in the workout and in the exercise library.

**Acceptance Scenarios**:

1. **Given** the add-exercise dialog is open on its search step, **When** the user looks at the header, **Then** a small "+" icon is visible in the top-right corner. It isn't shown on the equipment or confirm step.
2. **Given** the user taps "+" and creates a valid exercise, **When** the create dialog closes, **Then** the exercise is saved to the library, added to the end of the workout with its first compatible equipment (none for cardio), and the add-exercise dialog closes.
3. **Given** the user taps "+" and cancels, or validation fails, **Then** nothing is added and the add-exercise dialog stays open.

---

### Edge Cases

- The user cancels the create dialog: the swap dialog remains open and the workout is unchanged.
- Validation fails (empty name, duplicate name, etc.): existing validation messages are shown and nothing is swapped.
- Saving the new exercise fails for a reason the user cannot fix: the error is reported the same way as other system errors, and the current exercise is not replaced.
- The new exercise is of a different type (strength, cardio, hybrid, timed) than the one being replaced: the swap follows the existing type-conversion rules unchanged, as when swapping to an existing exercise of that type. Because a new exercise has no history, any value the existing rules take from past workouts (e.g. hybrid distance unit and weight, timed weight) falls back to its default.
- The new exercise has no compatible equipment selected: it is swapped in with no equipment, as when swapping to an existing exercise without equipment.
- A stopwatch is running on the exercise being replaced: it is discarded, as with any other swap.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The swap exercise dialog shown during an active workout MUST display a small "+" icon in its top-right corner.
- **FR-002**: Tapping the "+" icon MUST open the app's existing create new exercise dialog, with the same fields, defaults and validation as when it is opened from the program builder.
- **FR-003**: When the user successfully creates an exercise from this entry point, the system MUST save it to the exercise library so it is available in all other exercise pickers afterwards.
- **FR-004**: When the user successfully creates an exercise from this entry point, the system MUST replace the exercise being swapped with the newly created exercise, at the same position in the workout, using the same swap behavior as choosing an existing exercise from the swap list, including the existing cross-type conversion rules without modification.
- **FR-005**: For non-cardio exercises, the swapped-in exercise MUST default to its first compatible equipment (if any), matching the behavior of choosing an existing exercise from the swap list.
- **FR-006**: After a successful create-and-swap, the swap dialog MUST close and the user MUST be returned to the workout.
- **FR-007**: If the user cancels the create dialog, the system MUST NOT create an exercise or change the workout, and the swap dialog MUST remain open.
- **FR-008**: If the create action fails validation or fails to save, the system MUST NOT change the workout, and MUST report the problem using the app's existing validation or system-error feedback.
- **FR-009**: The "+" icon MUST NOT alter any existing swap dialog behavior (search, selecting an existing exercise, cancel).
- **FR-010**: The add-exercise dialog shown during an active workout MUST display the same "+" icon in its top-right corner while on its search step, opening the same create new exercise dialog.
- **FR-011**: When the user successfully creates an exercise from the add-exercise dialog, the system MUST add it to the end of the workout with its first compatible equipment (none for cardio) and close the dialog. Cancelling or failing validation MUST add nothing and keep the dialog open.

### Key Entities

- **Exercise**: A named movement in the user's exercise library with a type (strength, cardio, hybrid, timed), optional muscle groups, note and compatible equipment. A new one is created by this feature.
- **Workout exercise slot**: The position in the active workout that currently holds the exercise being swapped; its exercise is replaced by the newly created one.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can create a brand-new exercise and have it replace the current exercise without leaving the active workout, in 100% of attempts with valid input.
- **SC-002**: The create-and-swap flow takes no more than one extra tap (the "+" icon) compared with creating an exercise from the program builder.
- **SC-003**: Cancelling or failing validation in the create dialog leaves the active workout unchanged in 100% of cases.
- **SC-004**: An exercise created during a workout is available in the exercise library and all exercise pickers immediately afterwards.

## Assumptions

- "Add exercise dialog" in the description refers to the existing **create new exercise** dialog (the form with name, exercise type, muscle groups, equipment and note), not the program builder's dialog for adding an exercise to a workout day with sets and rest configuration (confirmed in Clarifications).
- The swap only affects the current workout session, with the same scope as swapping to an existing exercise today; it does not change the saved program template.
- Set targets and rest timer for the swapped-in exercise follow the same rules the existing swap uses for an existing exercise of the same type.
- After a successful create-and-swap the user wants to return straight to the workout, so the swap dialog closes rather than staying open.
- Changing the existing cross-type swap defaults (e.g. set counts or target values when the type changes) is out of scope for this feature (confirmed in Clarifications).
- No new exercise types, fields or storage changes are needed; this feature only adds a new entry point to existing functionality.
