# Quickstart: Validating the Timed Focus Layout

**Feature**: [spec.md](spec.md) | **Contract**: [contracts/controller.md](contracts/controller.md)

## Prerequisites

- Feature 002 is in place (the Timed type exists and Plank is Timed).
- A program day containing Plank with 3 sets of 1:00 and a 60 s rest, plus one strength
  exercise after it.

## 1. Automated checks

```bash
dart format lib test
flutter analyze      # no new issues compared with the 9 existing info-level issues
flutter test         # all tests pass
```

| File | Covers |
|------|--------|
| `test/controllers/active_workout_controller_test.dart` | The active-set table, entries and phases, Resume and Reset, rest skip on Start, discarding on equipment change, logging keeping the entry, unlog re-activating the set, weight carry-over (contract tables) |
| `test/utils/duration_format_test.dart` | The `targetProgress` table |

## 2. Timing with one button (Story 1)

1. Start the workout and open Plank. **Expect**:
   - The panel shows "Set 1 / 3", a dimmed `1:00` target, and the previous time if one exists.
   - A full-width **Start** button.
   - A compact list of 3 sets below, with set 1 highlighted.
2. Tap Start. **Expect**: the time counts up, the ring fills, and the button reads **Stop**.
   At 1:00 the ring turns to the "target reached" colour and keeps counting, with no sound.
3. Tap Stop at about 1:05. **Expect**: the button reads **Log set**; Resume and Reset are
   shown.
4. Tap Resume, wait about 5 s, then tap Stop. **Expect**: about 1:10; the pause wasn't
   counted.
5. Tap Reset briefly. **Expect**: the hint "Hold to reset", and the time is unchanged.
6. Tap Log set. **Expect**: set 1 shows as done with its time in the list, the rest
   countdown appears in the panel, and set 2 becomes active.
7. While the rest is running, tap Start. **Expect**: the rest disappears and the stopwatch
   runs.

## 3. Picker entry (Story 2)

1. Stop set 2, tap the large time, pick 0:48 and tap Done. **Expect**: `0:48` is shown and
   the button reads Log set.
2. Hold Reset for 1 s. **Expect**: back to the dimmed `1:00` target and a **Start** button.
3. Tap the time, pick 0:50, and tap Log set. **Expect**: set 2 is logged as 0:50.

## 4. Set list, weight and finishing (Stories 3 and 4)

1. Tap the weight chip, enter 10 (kg), and tap Done. **Expect**: the chip reads "10 kg".
2. Long-press set 1. **Expect**: it is unlogged and active, with its previous time filled in.
3. Log set 1 again, then time and log set 3. **Expect**: the workout moves on to the next
   exercise.
4. Go back to Plank, tap **Add extra set**, then swipe the empty set 4 away. **Expect**: it
   is removed.
5. Start the stopwatch, then switch equipment. **Expect**: the stopwatch is gone and nothing
   was entered.
6. Open a strength, a cardio and a hybrid exercise. **Expect**: they look and behave as
   before.
