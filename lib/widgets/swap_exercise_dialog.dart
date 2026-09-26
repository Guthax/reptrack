import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/utils/fuzzy_search.dart';
import 'package:reptrack/widgets/create_exercise_dialog.dart';

/// Dialog for replacing an exercise in the active workout.
///
/// Lists every other exercise with fuzzy search, and offers a "+" button that
/// creates a new exercise and swaps it in straight away.
class SwapExerciseDialog extends StatefulWidget {
  /// Position in the active workout of the exercise being replaced.
  final int exerciseIndex;

  /// ID of the exercise being replaced; it is left out of the list.
  final String exerciseId;

  /// Name of the exercise being replaced, shown in the title.
  final String exerciseName;

  const SwapExerciseDialog({
    super.key,
    required this.exerciseIndex,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  State<SwapExerciseDialog> createState() => _SwapExerciseDialogState();
}

class _SwapExerciseDialogState extends State<SwapExerciseDialog> {
  final TextEditingController searchController = TextEditingController();
  final RxList<Exercise> filteredExercises = <Exercise>[].obs;
  List<Exercise> allExercises = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Loads every exercise except the one being replaced into the list.
  void _loadInitialData() async {
    allExercises = await Get.find<ActiveWorkoutController>().getSwapCandidates(
      widget.exerciseId,
    );
    filteredExercises.assignAll(allExercises);
  }

  /// Whether [ex] is a cardio exercise.
  bool _isCardio(Exercise ex) => ex.exerciseTypeId == '2';

  /// Whether [ex] is a timed exercise.
  bool _isTimed(Exercise ex) => ex.exerciseTypeId == '4';

  /// Swaps [exercise] into the workout slot and closes this dialog.
  Future<void> _swapTo(Exercise exercise) async {
    await Get.find<ActiveWorkoutController>().swapExercise(
      exerciseIndex: widget.exerciseIndex,
      newExercise: exercise,
    );
    if (mounted) Get.back();
  }

  /// Opens the create exercise dialog and swaps in the created exercise.
  Future<void> _createAndSwap() async {
    final created = await Get.dialog<Exercise>(const CreateExerciseDialog());
    if (created == null || !mounted) return;
    await _swapTo(created);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              "Swap ${widget.exerciseName}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
            tooltip: 'Create new exercise',
            onPressed: _createAndSwap,
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Search replacement exercise...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                filteredExercises.assignAll(
                  fuzzyFilter(allExercises, val, (e) => e.name),
                );
              },
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight:
                      (MediaQuery.sizeOf(context).height -
                          MediaQuery.viewInsetsOf(context).bottom) *
                      0.35,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(
                  () => ListView.separated(
                    shrinkWrap: true,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: filteredExercises.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final ex = filteredExercises[i];
                      final cardio = _isCardio(ex);
                      final timed = _isTimed(ex);
                      return ListTile(
                        leading: Icon(
                          cardio
                              ? Icons.directions_run
                              : timed
                              ? Icons.timer_outlined
                              : Icons.fitness_center,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        title: Text(
                          ex.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: cardio
                            ? const Text("Cardio")
                            : timed
                            ? const Text("Timed")
                            : null,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => _swapTo(ex),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
      ],
    );
  }
}
