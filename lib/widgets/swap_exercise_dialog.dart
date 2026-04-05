import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/utils/fuzzy_search.dart';

class SwapExerciseDialog extends StatefulWidget {
  final int exerciseIndex;
  final String exerciseId;
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

  void _loadInitialData() async {
    allExercises = await Get.find<AppDatabase>().getAllExercises();
    allExercises.removeWhere((e) => e.id == widget.exerciseId);
    filteredExercises.assignAll(allExercises);
  }

  bool _isCardio(Exercise ex) => ex.exerciseTypeId == '2';

  @override
  Widget build(BuildContext context) {
    final activeController = Get.find<ActiveWorkoutController>();
    final db = Get.find<AppDatabase>();

    return AlertDialog(
      title: Text("Swap ${widget.exerciseName}"),
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
                      return ListTile(
                        leading: Icon(
                          cardio ? Icons.directions_run : Icons.fitness_center,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        title: Text(
                          ex.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: cardio ? const Text("Cardio") : null,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () async {
                          String defaultEquipId = '';
                          if (!cardio) {
                            final equips = await db.getEquipmentForExercise(
                              ex.id,
                            );
                            defaultEquipId = equips.isNotEmpty
                                ? equips.first.id
                                : '';
                          }
                          activeController.swapExercise(
                            exerciseIndex: widget.exerciseIndex,
                            newExercise: ex,
                            newEquipmentId: defaultEquipId,
                          );
                          Get.back();
                        },
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
