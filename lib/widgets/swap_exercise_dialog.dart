import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/utils/fuzzy_search.dart';

class SwapExerciseDialog extends StatefulWidget {
  final int exerciseIndex;
  final int exerciseId;
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
    final db = Get.find<AppDatabase>();
    allExercises = await db.getAllExercises();
    // Remove the exercise currently in the slot
    allExercises.removeWhere((e) => e.id == widget.exerciseId);
    filteredExercises.assignAll(allExercises);
  }

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
                      return ListTile(
                        title: Text(
                          ex.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () async {
                          // 1. Get available equipment for the new exercise
                          final equips = await db.getEquipmentForExercise(
                            ex.id,
                          );

                          // 2. Default to the first equipment found (or 0 if none)
                          final defaultEquipId = equips.isNotEmpty
                              ? equips.first.id
                              : 0;

                          // 3. Perform the swap in the controller
                          activeController.swapExercise(
                            exerciseIndex: widget.exerciseIndex,
                            newExercise: ex,
                            newEquipmentId: defaultEquipId,
                          );

                          Get.back(); // Close dialog
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
