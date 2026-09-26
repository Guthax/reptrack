# Feature Specification: Auto-Advance Only After All Sets Are Logged

**Feature Branch**: `bugfix/previous-weight-reset-during-workout`

**Created**: 2026-09-26

**Status**: Draft

**Input**: User description: "Bugfix: Only have ui switch to next exercise automatically if all the
defined sets are logged. Right now, the ui sweeps to the next exercise during a workout, when the
number of predefined sets are completed. It could be that someone adds a set during their workout,
then the automatic sweep to the next exercise should happen when all of those sets are logged. So
as an example: I start an exercise with 3 predefined sets. I add a 4th set. I then log 3 sets, it
should [not] sweep to the next until i have logged the last one."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Stay on the exercise until extra sets are logged (Priority: P1)

During a workout, a user adds one or more extra sets to an exercise on top of the sets the
program prescribes. After logging the planned sets, the user stays on the current exercise and
can log the extra sets. The workout moves on to the next exercise automatically only once every
set shown for that exercise (planned plus extra) has been logged.

**Why this priority**: This is the bug being fixed. Today the user is moved away from the
exercise before they have finished, and has to swipe back to log the extra set.

**Independent Test**: Start a workout on an exercise with 3 planned sets. Add 1 extra set. Log
sets 1 to 3 and confirm the exercise stays on screen. Log set 4 and confirm the workout moves
to the next exercise.

**Acceptance Scenarios**:

1. **Given** a strength exercise with 3 planned sets and 1 added extra set, **When** the user
   logs sets 1, 2 and 3, **Then** the current exercise stays on screen.
2. **Given** the same exercise with sets 1 to 3 logged, **When** the user logs set 4, **Then**
   the workout automatically moves to the next exercise.
3. **Given** a hybrid exercise with 2 planned sets and 2 added extra sets, **When** the user
   logs the 2 planned sets and 1 extra set, **Then** the current exercise stays on screen; once
   the last extra set is logged, the workout moves to the next exercise.

---

### User Story 2 - Unchanged behaviour when no sets are added (Priority: P2)

A user who does not add any extra sets sees the same behaviour as today: after logging the last
planned set, the workout moves to the next exercise automatically.

**Why this priority**: This is the most common workout flow, and the fix must not break it.

**Independent Test**: Start a workout on an exercise with 3 planned sets. Do not add sets. Log
all 3 sets and confirm the workout moves to the next exercise.

**Acceptance Scenarios**:

1. **Given** a strength or hybrid exercise with 3 planned sets and no extra sets, **When** the
   user logs all 3 sets, **Then** the workout automatically moves to the next exercise.
2. **Given** an exercise that is the last one in the workout, **When** the user logs all of its
   sets, **Then** the workout stays on that exercise, because there is no next exercise.

---

### Edge Cases

- **Sets logged out of order**: if the user logs the extra set before one of the planned sets,
  the workout moves on only once the last remaining set is logged, whichever set that is.
- **Extra set added after all planned sets are logged**: adding a set does not move the workout
  on by itself; the workout moves on once the new set is logged.
- **Extra set removed so every remaining set is logged**: removing a set does not move the
  workout on; auto-advance is triggered only by logging a set.
- **A logged set is un-logged**: the exercise is treated as not complete again, and the workout
  moves on only once every set is logged again.
- **Exercise with several equipment options**: completion is judged on the sets shown for the
  equipment currently selected for that exercise.
- **Cardio exercises**: these have a single entry and no extra-set option, so they are not
  affected by this fix.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The workout MUST move to the next exercise automatically only when every set shown
  for the current exercise, both planned and user-added, has been logged.
- **FR-002**: The workout MUST NOT move to the next exercise while any set shown for the current
  exercise, including a user-added extra set, is still unlogged.
- **FR-003**: The completion check MUST be triggered only when the user logs a set. Adding,
  removing or un-logging a set MUST NOT move the workout on.
- **FR-004**: The workout MUST NOT move on after the last exercise of the workout is completed.
- **FR-005**: FR-001 to FR-004 MUST apply the same way to strength and hybrid exercises.
- **FR-006**: When no extra sets are added, auto-advance MUST behave exactly as it does today.
- **FR-007**: A regression test MUST reproduce the reported scenario (3 planned sets, 1 extra
  set, 3 sets logged) and confirm the workout does not move on until the 4th set is logged.

### Key Entities

- **Workout exercise**: an exercise in the active workout. Its sets are the planned sets from
  the program plus any extra sets the user added during this session, per selected equipment.
- **Set**: a single set shown for a workout exercise, either logged or not logged.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In 100% of cases where a user has added extra sets, the workout stays on the
  current exercise until the last shown set is logged.
- **SC-002**: In 100% of cases with no extra sets, the workout moves on after the last planned
  set is logged, the same as before the fix.
- **SC-003**: Users never need to swipe back to an earlier exercise to log an extra set they
  added.

## Assumptions

- "All defined sets" means the planned sets plus any extra sets the user added during the
  current workout, for the currently selected equipment.
- Auto-advance is triggered only when a set is logged, as it is today; no new trigger is added.
- The transition to the next exercise (animation and timing) stays the same.
- Cardio exercises keep their current behaviour.
- Extra sets exist only for the current workout session, as they do today.
