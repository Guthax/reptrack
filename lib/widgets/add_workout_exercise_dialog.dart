import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/utils/fuzzy_search.dart';
import 'package:reptrack/widgets/create_exercise_dialog.dart';

/// Dialog for adding an exercise to the current active workout session.
///
/// Step 1 — search and select an exercise.
/// Step 2 — for strength or hybrid exercises with equipment: pick equipment.
/// On confirm, delegates to [ActiveWorkoutController.addExerciseDuringWorkout].
///
/// The "+" button on the search step creates a new exercise and adds it
/// straight away with its first compatible equipment.
class AddWorkoutExerciseDialog extends StatefulWidget {
  const AddWorkoutExerciseDialog({super.key});

  @override
  State<AddWorkoutExerciseDialog> createState() =>
      _AddWorkoutExerciseDialogState();
}

class _AddWorkoutExerciseDialogState extends State<AddWorkoutExerciseDialog> {
  final TextEditingController searchController = TextEditingController();
  final RxList<Exercise> filteredExercises = <Exercise>[].obs;
  final Rx<Exercise?> selectedExercise = Rx<Exercise?>(null);
  final RxList<Equipment> availableEquipment = <Equipment>[].obs;
  final Rx<String?> selectedEquipmentId = Rx<String?>(null);

  List<Exercise> allExercises = [];

  /// Whether [ex] is a hybrid exercise.
  bool _isHybrid(Exercise? ex) => ex?.exerciseTypeId == '3';

  /// Whether [ex] is a cardio exercise.
  bool _isCardio(Exercise? ex) => ex?.exerciseTypeId == '2';

  /// Whether [ex] is a hybrid exercise.
  bool _exerciseIsHybrid(Exercise ex) => ex.exerciseTypeId == '3';

  /// Whether [ex] is a cardio exercise.
  bool _exerciseIsCardio(Exercise ex) => ex.exerciseTypeId == '2';

  /// Whether [ex] is a timed exercise.
  bool _isTimed(Exercise? ex) => ex?.exerciseTypeId == '4';

  /// Whether [ex] is a timed exercise.
  bool _exerciseIsTimed(Exercise ex) => ex.exerciseTypeId == '4';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads every exercise into the search list.
  void _loadData() async {
    allExercises = await Get.find<AppDatabase>().getAllExercises();
    filteredExercises.assignAll(allExercises);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// Opens the create exercise dialog, adds the created exercise to the
  /// workout and closes this dialog.
  Future<void> _createAndAdd() async {
    final created = await Get.dialog<Exercise>(const CreateExerciseDialog());
    if (created == null || !mounted) return;
    await Get.find<ActiveWorkoutController>().addExerciseDuringWorkout(
      exercise: created,
    );
    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();

    return AlertDialog(
      title: Obx(
        () => Row(
          children: [
            Expanded(
              child: Text(
                selectedExercise.value == null
                    ? 'Add Exercise'
                    : 'Select Equipment',
              ),
            ),
            if (selectedExercise.value == null)
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
                tooltip: 'Create new exercise',
                onPressed: _createAndAdd,
              ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      content: SizedBox(
        width: double.maxFinite,
        child: Obx(() {
          final ex = selectedExercise.value;
          if (ex == null) return _buildSearchStep(context);

          final needsEquipment =
              !_isCardio(ex) && availableEquipment.isNotEmpty;
          if (needsEquipment) return _buildEquipmentStep(ex);

          return _buildConfirmStep(ex);
        }),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        Obx(() {
          final ex = selectedExercise.value;
          if (ex == null) return const SizedBox.shrink();
          final needsEquipment =
              !_isCardio(ex) && availableEquipment.isNotEmpty;
          final canConfirm =
              !needsEquipment || selectedEquipmentId.value != null;
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            onPressed: canConfirm
                ? () {
                    controller.addExerciseDuringWorkout(
                      exercise: ex,
                      equipmentId: selectedEquipmentId.value,
                    );
                    Get.back();
                  }
                : null,
            child: const Text('Add'),
          );
        }),
      ],
    );
  }

  /// Builds the step for searching and picking an exercise.
  Widget _buildSearchStep(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search exercise...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (val) {
            filteredExercises.assignAll(
              fuzzyFilter(allExercises, val, (e) => e.name),
            );
          },
        ),
        const SizedBox(height: 10),
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxHeight:
                  (MediaQuery.sizeOf(context).height -
                      MediaQuery.viewInsetsOf(context).bottom) *
                  0.4,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(
              () => ListView.separated(
                shrinkWrap: true,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: filteredExercises.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: AppColors.outline),
                itemBuilder: (ctx, i) {
                  final ex = filteredExercises[i];
                  final cardio = _exerciseIsCardio(ex);
                  final hybrid = _exerciseIsHybrid(ex);
                  final timed = _exerciseIsTimed(ex);
                  return ListTile(
                    leading: Icon(
                      cardio
                          ? Icons.directions_run
                          : hybrid
                          ? Icons.merge_type
                          : timed
                          ? Icons.timer_outlined
                          : Icons.fitness_center,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    title: Text(ex.name),
                    subtitle: cardio
                        ? const Text('Cardio')
                        : hybrid
                        ? const Text('Hybrid')
                        : timed
                        ? const Text('Timed')
                        : null,
                    onTap: () async {
                      selectedExercise.value = ex;
                      if (!cardio) {
                        final equips = await Get.find<AppDatabase>()
                            .getEquipmentForExercise(ex.id);
                        availableEquipment.assignAll(equips);
                        selectedEquipmentId.value = equips.length == 1
                            ? equips.first.id
                            : null;
                      }
                      if (context.mounted) FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the step for picking equipment for [ex].
  Widget _buildEquipmentStep(Exercise ex) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Chip(
          label: Text(ex.name),
          avatar: Icon(
            _isHybrid(ex)
                ? Icons.merge_type
                : _isTimed(ex)
                ? Icons.timer_outlined
                : Icons.fitness_center,
            size: 18,
          ),
          onDeleted: () {
            selectedExercise.value = null;
            availableEquipment.clear();
            selectedEquipmentId.value = null;
          },
          deleteIcon: const Icon(Icons.close),
        ),
        const SizedBox(height: 20),
        Text(
          'EQUIPMENT',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textDisabled,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableEquipment.map((e) {
              return ChoiceChip(
                label: Text(e.name),
                selected: selectedEquipmentId.value == e.id,
                showCheckmark: false,
                onSelected: (val) =>
                    selectedEquipmentId.value = val ? e.id : null,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Builds the step confirming [ex] when no equipment choice is needed.
  Widget _buildConfirmStep(Exercise ex) {
    final isCardio = _isCardio(ex);
    final isHybrid = _isHybrid(ex);
    final isTimed = _isTimed(ex);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Chip(
          label: Text(ex.name),
          avatar: Icon(
            isCardio
                ? Icons.directions_run
                : isHybrid
                ? Icons.merge_type
                : isTimed
                ? Icons.timer_outlined
                : Icons.fitness_center,
            size: 18,
          ),
          onDeleted: () {
            selectedExercise.value = null;
            availableEquipment.clear();
            selectedEquipmentId.value = null;
          },
          deleteIcon: const Icon(Icons.close),
        ),
        const SizedBox(height: 12),
        Text(
          isCardio
              ? 'Cardio exercise — tap Add to include it in your workout.'
              : isHybrid
              ? 'Hybrid exercise — tap Add to include it in your workout.'
              : isTimed
              ? 'Timed exercise — tap Add to include it in your workout.'
              : 'No equipment options — tap Add to include it in your workout.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
