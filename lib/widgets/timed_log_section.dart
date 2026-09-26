import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/controllers/settings_controller.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/utils/duration_format.dart';

/// Timed exercise logging in a focus layout: a large panel for the active
/// set and a compact list of all sets below it.
class TimedLogSection extends StatelessWidget {
  final ExerciseWithVolume item;
  final int exerciseIndex;
  final RxList<Equipment> alternatives;

  const TimedLogSection({
    super.key,
    required this.item,
    required this.exerciseIndex,
    required this.alternatives,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: alternatives.map((e) {
              final isSelected =
                  controller.selectedEquipments[exerciseIndex] == e.id;
              return ChoiceChip(
                label: Text(e.name),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (val) {
                  if (val) controller.selectEquipment(exerciseIndex, e.id);
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(() {
            controller.completedSets.length;
            controller.timedEntries.length;
            final equipmentId =
                controller.selectedEquipments[exerciseIndex] ??
                item.equipment?.id ??
                '';
            final planned = item.volume.setsSecondsList;
            final totalSets = controller.getTotalSetsForExercise(
              exerciseIndex,
              planned.length,
              equipmentId,
            );
            final active = controller.activeTimedSetNum(
              exerciseIndex,
              equipmentId,
              totalSets,
            );
            int targetFor(int setNum) => setNum <= planned.length
                ? planned[setNum - 1]
                : (planned.isNotEmpty ? planned.last : 0);

            return Column(
              children: [
                _TimedFocusPanel(
                  item: item,
                  exerciseIndex: exerciseIndex,
                  equipmentId: equipmentId,
                  setNum: active,
                  totalSets: totalSets,
                  plannedSets: planned.length,
                  targetSeconds: active == null ? 0 : targetFor(active),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _TimedSetList(
                    item: item,
                    exerciseIndex: exerciseIndex,
                    equipmentId: equipmentId,
                    totalSets: totalSets,
                    plannedSets: planned.length,
                    activeSetNum: active,
                    targetFor: targetFor,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

/// Large panel for the active timed set with the time display, progress
/// ring, the Start → Stop → Log set button, Resume/Reset, weight chip and
/// rest countdown.
class _TimedFocusPanel extends StatelessWidget {
  final ExerciseWithVolume item;
  final int exerciseIndex;
  final String equipmentId;

  /// Active set number, or null when every set is logged.
  final int? setNum;
  final int totalSets;
  final int plannedSets;

  /// Target of the active set in seconds; 0 means no target.
  final int targetSeconds;

  const _TimedFocusPanel({
    required this.item,
    required this.exerciseIndex,
    required this.equipmentId,
    required this.setNum,
    required this.totalSets,
    required this.plannedSets,
    required this.targetSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();

    return Obx(() {
      final rest = controller.remainingRestTime.value;
      final setNum = this.setNum;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rest > 0) _RestStrip(seconds: rest),
            if (setNum == null)
              _AllSetsDone(
                onAddExtraSet: () =>
                    controller.addExtraSet(exerciseIndex, equipmentId),
              )
            else
              _ActiveSetBody(
                item: item,
                exerciseIndex: exerciseIndex,
                equipmentId: equipmentId,
                setNum: setNum,
                totalSets: totalSets,
                plannedSets: plannedSets,
                targetSeconds: targetSeconds,
              ),
          ],
        ),
      );
    });
  }
}

/// Rest countdown shown at the top of the focus panel with a skip action.
class _RestStrip extends StatelessWidget {
  final int seconds;

  const _RestStrip({required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.secondary),
          const SizedBox(width: 8),
          Text(
            'Rest ${formatDuration(seconds)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: Get.find<ActiveWorkoutController>().skipRestTimer,
            child: const Text('SKIP'),
          ),
        ],
      ),
    );
  }
}

/// Focus panel content once every set of the exercise is logged.
class _AllSetsDone extends StatelessWidget {
  final VoidCallback onAddExtraSet;

  const _AllSetsDone({required this.onAddExtraSet});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        const SizedBox(height: 8),
        const Text(
          'All sets done',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onAddExtraSet,
          icon: const Icon(Icons.add),
          label: const Text('ADD EXTRA SET'),
        ),
      ],
    );
  }
}

/// Focus panel content for the active set.
class _ActiveSetBody extends StatelessWidget {
  final ExerciseWithVolume item;
  final int exerciseIndex;
  final String equipmentId;
  final int setNum;
  final int totalSets;
  final int plannedSets;
  final int targetSeconds;

  const _ActiveSetBody({
    required this.item,
    required this.exerciseIndex,
    required this.equipmentId,
    required this.setNum,
    required this.totalSets,
    required this.plannedSets,
    required this.targetSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();
    final key = "$exerciseIndex-$equipmentId-$setNum";
    return Obx(() => _buildBody(context, controller, key));
  }

  /// Builds the panel content from the current controller state of [key].
  Widget _buildBody(
    BuildContext context,
    ActiveWorkoutController controller,
    String key,
  ) {
    final phase = controller.timedPhase(key);
    final entry = controller.timedEntries[key];
    final past = controller.getPastTimedSetData(
      item.exercise.id,
      setNum,
      equipmentId,
    );

    final int shownSeconds = switch (phase) {
      TimedSetPhase.running => controller.stopwatchElapsedSeconds.value,
      TimedSetPhase.ready => entry?.seconds ?? 0,
      TimedSetPhase.idle => targetSeconds,
    };
    final progress = phase == TimedSetPhase.idle
        ? null
        : targetProgress(shownSeconds, targetSeconds);
    final reached = progress != null && progress >= 1.0;

    return Column(
      children: [
        Text(
          'SET $setNum / $totalSets',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: phase == TimedSetPhase.running
              ? null
              : () async {
                  final result = await showTimedDurationSheet(
                    context,
                    entry?.seconds ?? targetSeconds,
                  );
                  if (result != null) {
                    controller.setTimedEntrySeconds(key, result);
                  }
                },
          child: SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (targetSeconds > 0)
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress ?? 0,
                      strokeWidth: 8,
                      backgroundColor: AppColors.outline,
                      color: reached ? AppColors.success : AppColors.secondary,
                    ),
                  ),
                Text(
                  formatDuration(shownSeconds),
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: phase == TimedSetPhase.idle
                        ? AppColors.textDisabled
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          [
            targetSeconds > 0
                ? 'target ${formatDuration(targetSeconds)}'
                : 'no target',
            if (past != null) 'last ${formatDuration(past.durationSeconds)}',
          ].join(' · '),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: phase == TimedSetPhase.running
                  ? AppColors.error
                  : AppColors.primary,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            onPressed: () => _onPrimaryPressed(controller, key, phase),
            child: Text(switch (phase) {
              TimedSetPhase.idle => 'START',
              TimedSetPhase.running => 'STOP',
              TimedSetPhase.ready => 'LOG SET',
            }),
          ),
        ),
        if (phase == TimedSetPhase.ready) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.startStopwatch(key),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('RESUME'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HoldToResetButton(
                  onReset: () => controller.resetTimedEntry(key),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        _WeightChip(exerciseIndex: exerciseIndex),
      ],
    );
  }

  /// Runs the primary action for [phase]: start, stop, or log the set and
  /// move to the next exercise when this one is complete.
  Future<void> _onPrimaryPressed(
    ActiveWorkoutController controller,
    String key,
    TimedSetPhase phase,
  ) async {
    switch (phase) {
      case TimedSetPhase.idle:
        controller.startStopwatch(key);
      case TimedSetPhase.running:
        controller.stopStopwatch();
      case TimedSetPhase.ready:
        final logged = await controller.logTimedSet(
          exerciseIndex: exerciseIndex,
          exerciseId: item.exercise.id,
          equipmentId: equipmentId,
          durationSeconds: controller.timedEntries[key]?.seconds ?? 0,
          weightKg: controller.timedWeightKg[exerciseIndex],
          setNum: setNum,
          restSeconds: item.volume.restTimer ?? 60,
        );
        if (logged &&
            controller.shouldAutoAdvance(
              exerciseIndex: exerciseIndex,
              plannedSets: plannedSets,
              equipmentId: equipmentId,
            )) {
          controller.pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
    }
  }
}

/// Reset action that only fires after a one-second press-and-hold; a tap
/// shows the hint "Hold to reset".
class _HoldToResetButton extends StatelessWidget {
  final VoidCallback onReset;

  const _HoldToResetButton({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Hold to reset',
      triggerMode: TooltipTriggerMode.tap,
      child: RawGestureDetector(
        gestures: {
          LongPressGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                () => LongPressGestureRecognizer(
                  duration: const Duration(seconds: 1),
                ),
                (recognizer) => recognizer.onLongPress = onReset,
              ),
        },
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restart_alt, size: 18, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'HOLD TO RESET',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip showing the carried-over weight of the exercise; opens the weight
/// sheet.
class _WeightChip extends StatelessWidget {
  final int exerciseIndex;

  const _WeightChip({required this.exerciseIndex});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final kg = controller.timedWeightKg[exerciseIndex];
      final label = kg == null
          ? '+ weight'
          : '${_formatWeight(settings, kg)} ${settings.unitLabel}';
      return ActionChip(
        avatar: const Icon(Icons.fitness_center, size: 16),
        label: Text(label),
        onPressed: () => showTimedWeightSheet(context, exerciseIndex),
      );
    });
  }
}

/// Compact list of all sets of the timed exercise below the focus panel.
class _TimedSetList extends StatelessWidget {
  final ExerciseWithVolume item;
  final int exerciseIndex;
  final String equipmentId;
  final int totalSets;
  final int plannedSets;
  final int? activeSetNum;
  final int Function(int setNum) targetFor;

  const _TimedSetList({
    required this.item,
    required this.exerciseIndex,
    required this.equipmentId,
    required this.totalSets,
    required this.plannedSets,
    required this.activeSetNum,
    required this.targetFor,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();

    return ListView.builder(
      itemCount: totalSets + 1,
      itemBuilder: (context, index) {
        if (index == totalSets) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            child: OutlinedButton.icon(
              onPressed: () =>
                  controller.addExtraSet(exerciseIndex, equipmentId),
              icon: const Icon(Icons.add),
              label: const Text('ADD EXTRA SET'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.outline),
              ),
            ),
          );
        }

        final setNum = index + 1;
        final key = "$exerciseIndex-$equipmentId-$setNum";
        final isLogged = controller.isSetCompleted(
          exerciseIndex,
          equipmentId,
          setNum,
        );
        final isExtra = setNum > plannedSets;
        final canDismiss = isExtra && !isLogged && setNum == totalSets;

        return Dismissible(
          key: Key('timed_${key}_$totalSets'),
          direction: canDismiss
              ? DismissDirection.startToEnd
              : DismissDirection.none,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) =>
              controller.removeExtraSet(exerciseIndex, equipmentId),
          child: _TimedSetTile(
            item: item,
            exerciseIndex: exerciseIndex,
            equipmentId: equipmentId,
            setNum: setNum,
            isLogged: isLogged,
            isActive: setNum == activeSetNum,
            targetSeconds: targetFor(setNum),
          ),
        );
      },
    );
  }
}

/// One compact set row: logged time and weight, live time, or target.
///
/// Tapping an unlogged row selects it; long-pressing a logged row unlogs it.
class _TimedSetTile extends StatelessWidget {
  final ExerciseWithVolume item;
  final int exerciseIndex;
  final String equipmentId;
  final int setNum;
  final bool isLogged;
  final bool isActive;
  final int targetSeconds;

  const _TimedSetTile({
    required this.item,
    required this.exerciseIndex,
    required this.equipmentId,
    required this.setNum,
    required this.isLogged,
    required this.isActive,
    required this.targetSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();
    final settings = Get.find<SettingsController>();
    final key = "$exerciseIndex-$equipmentId-$setNum";

    return Obx(() {
      final entry = controller.timedEntries[key];
      final isRunning = controller.runningStopwatchKey.value == key;
      final String text;
      if (isLogged && entry != null) {
        text = formatTimedSet(
          entry.seconds,
          weightText: entry.weightKg == null
              ? null
              : '${_formatWeight(settings, entry.weightKg!)} ${settings.unitLabel}',
        );
      } else if (isRunning) {
        text = '${formatDuration(controller.stopwatchElapsedSeconds.value)} …';
      } else if (entry != null) {
        text = formatDuration(entry.seconds);
      } else {
        text = targetSeconds > 0
            ? 'target ${formatDuration(targetSeconds)}'
            : 'no target';
      }

      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isLogged
            ? null
            : () =>
                  controller.selectTimedSet(exerciseIndex, equipmentId, setNum),
        onLongPress: isLogged
            ? () => controller.unlogTimedSet(
                exerciseIndex: exerciseIndex,
                exerciseId: item.exercise.id,
                equipmentId: equipmentId,
                setNum: setNum,
              )
            : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isLogged
                ? AppColors.success.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? AppColors.secondary : AppColors.outline,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isLogged
                    ? Icons.check_circle
                    : isRunning
                    ? Icons.timer
                    : Icons.radio_button_unchecked,
                size: 18,
                color: isLogged
                    ? AppColors.success
                    : isRunning
                    ? AppColors.secondary
                    : AppColors.textDisabled,
              ),
              const SizedBox(width: 10),
              Text(
                'SET $setNum',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                text,
                style: TextStyle(
                  fontWeight: isLogged ? FontWeight.w700 : FontWeight.w500,
                  color: isLogged || isRunning
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Formats [kg] in the user's weight unit without trailing zeros.
String _formatWeight(SettingsController settings, double kg) {
  final d = settings.displayWeight(kg);
  return d == d.truncateToDouble()
      ? d.toInt().toString()
      : d.toStringAsFixed(1);
}

/// Shows a bottom sheet with minute and second wheels starting at
/// [initialSeconds]; returns the picked total seconds, or null when
/// cancelled.
Future<int?> showTimedDurationSheet(BuildContext context, int initialSeconds) {
  var minutes = (initialSeconds ~/ 60).clamp(0, 180);
  var seconds = initialSeconds % 60;

  return showModalBottomSheet<int>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context, minutes * 60 + seconds),
                child: const Text('Done'),
              ),
            ],
          ),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: minutes,
                    ),
                    onSelectedItemChanged: (i) => minutes = i,
                    children: [
                      for (var i = 0; i <= 180; i++)
                        Center(child: Text('$i min')),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: seconds,
                    ),
                    onSelectedItemChanged: (i) => seconds = i,
                    children: [
                      for (var i = 0; i < 60; i++)
                        Center(
                          child: Text('${i.toString().padLeft(2, '0')} s'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Shows a bottom sheet to set or remove the carried-over weight of the
/// timed exercise at [exerciseIndex], in the user's weight unit.
Future<void> showTimedWeightSheet(BuildContext context, int exerciseIndex) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TimedWeightSheet(exerciseIndex: exerciseIndex),
    );

/// Bottom sheet content for editing the carried-over timed weight.
class _TimedWeightSheet extends StatefulWidget {
  final int exerciseIndex;

  const _TimedWeightSheet({required this.exerciseIndex});

  @override
  State<_TimedWeightSheet> createState() => _TimedWeightSheetState();
}

class _TimedWeightSheetState extends State<_TimedWeightSheet> {
  final controller = Get.find<ActiveWorkoutController>();
  final settings = Get.find<SettingsController>();
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    final current = controller.timedWeightKg[widget.exerciseIndex];
    textController = TextEditingController(
      text: current == null ? '' : _formatWeight(settings, current),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  /// Saves the entered weight, or clears it when the field is empty.
  void _save() {
    final value = double.tryParse(textController.text.trim());
    controller.setTimedWeight(
      widget.exerciseIndex,
      value == null ? null : settings.toKg(value),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: textController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              MaxValueInputFormatter(100000),
            ],
            decoration: InputDecoration(
              labelText: 'Weight',
              suffixText: settings.unitLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  controller.setTimedWeight(widget.exerciseIndex, null);
                  Navigator.pop(context);
                },
                child: const Text('Remove weight'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(onPressed: _save, child: const Text('Done')),
            ],
          ),
        ],
      ),
    );
  }
}
