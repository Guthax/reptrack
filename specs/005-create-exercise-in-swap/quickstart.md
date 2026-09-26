# Quickstart: Create Exercise From Swap Dialog

## Automated checks

```bash
dart format lib test
flutter analyze        # expect: No issues found
flutter test           # expect: all pass, including the new swapExercise tests (research R6)
```

## Manual checks in the app

Before you start, have a program with at least one strength exercise, and start a workout for that day.

| # | Steps | Expected |
|---|---|---|
| 1 | Tap the swap icon on a strength exercise | The swap dialog shows "Swap {name}" with a "+" icon in the top right. With a long name, the text is cut off and the icon stays visible. |
| 2 | Tap "+", enter "Test Row" with type Strength and one piece of equipment, then tap Create | Both dialogs close. The workout shows "Test Row" in the same place with the same sets × reps and rest timer, and its equipment is selected. |
| 3 | Open the swap dialog on any exercise and search "Test Row" | The new exercise is in the list (it's in the exercise library). |
| 4 | Open the swap dialog, tap "+", then Cancel | You're back in the swap dialog and the workout is unchanged. |
| 5 | Tap "+" again | The create form is empty, with Strength selected by default. |
| 6 | Tap "+", enter an existing name or leave the name empty, tap Create | The existing error snackbar appears, the create dialog stays open, and the workout is unchanged. |
| 7 | Swap a strength exercise with 3 sets for a new **Timed** exercise | The slot becomes timed with 3 sets, each with a 0-second target, and the rest timer is kept (existing rules). |
| 8 | Log a set, then swap it for a new exercise | Logged sets for that slot are cleared, the same as with any swap. |
| 9 | Finish the workout and open the program | The program still lists the original exercise. The swap only affected this workout. |
