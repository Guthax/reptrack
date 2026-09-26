import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reptrack/utils/app_theme.dart';

/// Per-set target duration inputs for a timed program exercise.
///
/// Each set has a minutes field and a seconds field (capped at 59). The
/// controllers are owned by the parent so it can read the values on confirm
/// with [readSeconds].
class TimedSetsEditor extends StatelessWidget {
  /// Minutes controllers, one per set.
  final List<TextEditingController> minuteControllers;

  /// Seconds controllers, one per set, parallel to [minuteControllers].
  final List<TextEditingController> secondControllers;

  /// Called when the user adds a set.
  final VoidCallback onAddSet;

  /// Called with the set index when the user removes a set.
  final ValueChanged<int> onRemoveSet;

  const TimedSetsEditor({
    super.key,
    required this.minuteControllers,
    required this.secondControllers,
    required this.onAddSet,
    required this.onRemoveSet,
  });

  /// Creates minutes/seconds controllers pre-filled from [targets] in seconds.
  static (List<TextEditingController>, List<TextEditingController>)
  controllersFor(List<int> targets) => (
    targets.map((s) => TextEditingController(text: '${s ~/ 60}')).toList(),
    targets
        .map((s) => TextEditingController(text: '${s % 60}'.padLeft(2, '0')))
        .toList(),
  );

  /// Reads the target seconds per set from the given controllers.
  static List<int> readSeconds(
    List<TextEditingController> minutes,
    List<TextEditingController> seconds,
  ) => [
    for (var i = 0; i < minutes.length; i++)
      (int.tryParse(minutes[i].text) ?? 0) * 60 +
          (int.tryParse(seconds[i].text) ?? 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < minuteControllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    "Set ${i + 1}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: minuteControllers[i],
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      const MaxValueInputFormatter(999),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Min',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: secondControllers[i],
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      const MaxValueInputFormatter(59),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Sec',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                if (minuteControllers.length > 1)
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.error,
                    ),
                    onPressed: () => onRemoveSet(i),
                  ),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: onAddSet,
          icon: const Icon(Icons.add),
          label: const Text("ADD SET"),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ],
    );
  }
}
