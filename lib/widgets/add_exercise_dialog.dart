import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/build_program_controller.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/utils/fuzzy_search.dart';
import 'package:reptrack/widgets/create_exercise_dialog.dart';
import 'package:reptrack/widgets/distance_unit_selector.dart';
import 'package:reptrack/widgets/edit_exercise_dialog.dart';

/// Dialog for adding an exercise to a workout day.
///
/// Presents a two-step flow:
/// 1. **Select** — fuzzy-search the exercise list; optionally create or edit
///    an exercise inline.
/// 2. **Configure** — for strength: choose equipment, per-set rep targets, and
///    rest timer. For cardio: choose planned hours and minutes. For hybrid:
///    choose equipment, per-set distance targets, distance unit, and rest timer.
///
/// On confirmation, delegates to [BuildProgramController.addExerciseToDay].
class AddExerciseDialog extends StatefulWidget {
  /// The workout day ID that the selected exercise will be added to.
  final String dayId;

  const AddExerciseDialog({super.key, required this.dayId});

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController timerController = TextEditingController(
    text: "0",
  );
  final TextEditingController hoursController = TextEditingController();
  final TextEditingController minutesController = TextEditingController();
  final TextEditingController cardioDistanceController =
      TextEditingController();
  final RxString cardioDistanceUnit = 'km'.obs;
  final List<TextEditingController> setControllers = [
    TextEditingController(text: "12"),
    TextEditingController(text: "12"),
    TextEditingController(text: "12"),
  ];
  final List<TextEditingController> distanceControllers = [
    TextEditingController(text: "25"),
    TextEditingController(text: "25"),
    TextEditingController(text: "25"),
  ];
  final TextEditingController hybridTimerController = TextEditingController(
    text: "60",
  );

  final Rx<Exercise?> selectedExercise = Rx<Exercise?>(null);
  final RxList<Exercise> filteredExercises = <Exercise>[].obs;
  final RxList<Equipment> availableEquipment = <Equipment>[].obs;
  final Rx<String?> selectedEquipmentId = Rx<String?>(null);
  final RxString hybridDistanceUnit = 'm'.obs;

  List<Exercise> allExercises = [];
  bool get _isHybrid => selectedExercise.value?.exerciseTypeId == '3';

  bool get _isCardio => selectedExercise.value?.exerciseTypeId == '2';

  bool _exerciseIsHybrid(Exercise ex) => ex.exerciseTypeId == '3';

  bool _exerciseIsCardio(Exercise ex) => ex.exerciseTypeId == '2';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    allExercises = await Get.find<BuildProgramController>()
        .getAvailableExercises();
    filteredExercises.assignAll(allExercises);
  }

  @override
  void dispose() {
    searchController.dispose();
    timerController.dispose();
    hoursController.dispose();
    minutesController.dispose();
    cardioDistanceController.dispose();
    hybridTimerController.dispose();
    for (final c in setControllers) {
      c.dispose();
    }
    for (final c in distanceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BuildProgramController>();

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Obx(
              () => Text(
                selectedExercise.value == null
                    ? "Select Exercise"
                    : "Set Volume",
              ),
            ),
          ),
          Obx(() {
            if (selectedExercise.value == null) {
              return IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
                tooltip: 'Create new exercise',
                onPressed: () async {
                  final newExercise = await Get.dialog<Exercise>(
                    const CreateExerciseDialog(),
                  );
                  if (newExercise != null) {
                    allExercises.add(newExercise);
                    filteredExercises.assignAll(allExercises);
                  }
                },
              );
            }
            if (_isCardio || _isHybrid) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.primary,
              tooltip: 'Edit exercise',
              onPressed: () async {
                final updated = await Get.dialog<Exercise>(
                  EditExerciseDialog(exercise: selectedExercise.value!),
                );
                if (updated != null) {
                  selectedExercise.value = updated;
                  final equips = await Get.find<AppDatabase>()
                      .getEquipmentForExercise(updated.id);
                  availableEquipment.assignAll(equips);
                  if (!equips.any((e) => e.id == selectedEquipmentId.value)) {
                    selectedEquipmentId.value = equips.length == 1
                        ? equips.first.id
                        : null;
                  }
                  final idx = allExercises.indexWhere(
                    (e) => e.id == updated.id,
                  );
                  if (idx != -1) allExercises[idx] = updated;
                  filteredExercises.assignAll(allExercises);
                }
              },
            );
          }),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Obx(() {
          if (selectedExercise.value == null) {
            return _buildSearchList(context);
          }
          if (_isCardio) return _buildCardioConfig();
          if (_isHybrid) return _buildHybridConfig();
          return _buildStrengthConfig();
        }),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        Obx(() {
          final bool isValid =
              selectedExercise.value != null &&
              (_isCardio ||
                  (_isHybrid && selectedEquipmentId.value != null) ||
                  (!_isCardio &&
                      !_isHybrid &&
                      selectedEquipmentId.value != null));

          return ElevatedButton(
            onPressed: !isValid
                ? null
                : () {
                    if (_isCardio) {
                      final hours = int.tryParse(hoursController.text) ?? 0;
                      final minutes = int.tryParse(minutesController.text) ?? 0;
                      final totalSecs = hours * 3600 + minutes * 60;
                      final distText = cardioDistanceController.text.trim();
                      controller.addExerciseToDay(
                        widget.dayId,
                        selectedExercise.value!,
                        null,
                        [],
                        null,
                        durationSeconds: totalSecs > 0 ? totalSecs : null,
                        distancePlannedCardio: distText.isEmpty
                            ? null
                            : double.tryParse(distText),
                        distancePlannedCardioUnit: cardioDistanceUnit.value,
                      );
                    } else if (_isHybrid) {
                      controller.addExerciseToDay(
                        widget.dayId,
                        selectedExercise.value!,
                        selectedEquipmentId.value,
                        [],
                        int.tryParse(hybridTimerController.text),
                        setsDistances: distanceControllers
                            .map((c) => double.tryParse(c.text) ?? 100.0)
                            .toList(),
                        distanceUnit: hybridDistanceUnit.value,
                      );
                    } else {
                      controller.addExerciseToDay(
                        widget.dayId,
                        selectedExercise.value!,
                        selectedEquipmentId.value!,
                        setControllers
                            .map((c) => int.tryParse(c.text) ?? 0)
                            .toList(),
                        int.tryParse(timerController.text),
                      );
                    }
                    Get.back();
                  },
            child: const Text("Confirm"),
          );
        }),
      ],
    );
  }

  Widget _buildSearchList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search e.g. Bench Press...",
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
                  0.35,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: filteredExercises.length,
              itemBuilder: (ctx, i) {
                final ex = filteredExercises[i];
                final isCardio = _exerciseIsCardio(ex);
                final isHybrid = _exerciseIsHybrid(ex);
                return ListTile(
                  leading: Icon(
                    isCardio
                        ? Icons.directions_run
                        : isHybrid
                        ? Icons.merge_type
                        : Icons.fitness_center,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  title: Text(ex.name),
                  subtitle: isCardio
                      ? const Text("Cardio")
                      : isHybrid
                      ? const Text("Hybrid")
                      : null,
                  onTap: () async {
                    if (!isCardio) {
                      final equips = await Get.find<AppDatabase>()
                          .getEquipmentForExercise(ex.id);
                      availableEquipment.assignAll(equips);
                      selectedEquipmentId.value = equips.length == 1
                          ? equips.first.id
                          : null;
                    }
                    selectedExercise.value = ex;
                    if (context.mounted) FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardioConfig() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            label: Text(selectedExercise.value!.name),
            avatar: const Icon(Icons.directions_run, size: 18),
            onDeleted: () => selectedExercise.value = null,
            deleteIcon: const Icon(Icons.close),
          ),
          const SizedBox(height: 20),
          const Text(
            'PLANNED DURATION (optional)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textDisabled,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    MaxValueInputFormatter(23),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Hours',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    MaxValueInputFormatter(59),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Minutes',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'PLANNED DISTANCE (optional)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textDisabled,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: cardioDistanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Distance',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => DistanceUnitSelector(
                  selected: cardioDistanceUnit.value,
                  onChanged: (u) => cardioDistanceUnit.value = u,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHybridConfig() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(selectedExercise.value!.name),
            avatar: const Icon(Icons.merge_type, size: 18),
            onDeleted: () {
              selectedExercise.value = null;
              selectedEquipmentId.value = null;
            },
            deleteIcon: const Icon(Icons.close),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Equipment Type",
              style: TextStyle(fontWeight: FontWeight.bold),
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
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                "Distance Unit",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Obx(
                () => Wrap(
                  spacing: 6,
                  children: ['m', 'km', 'mi'].map((unit) {
                    return ChoiceChip(
                      label: Text(unit),
                      selected: hybridDistanceUnit.value == unit,
                      showCheckmark: false,
                      onSelected: (_) => hybridDistanceUnit.value = unit,
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...distanceControllers.asMap().entries.map((entry) {
            final i = entry.key;
            final ctrl = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      "Set ${i + 1}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                        MaxValueInputFormatter(100000),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Distance',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixText: hybridDistanceUnit.value,
                      ),
                    ),
                  ),
                  if (distanceControllers.length > 1)
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () => setState(() {
                        distanceControllers[i].dispose();
                        distanceControllers.removeAt(i);
                      }),
                    ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: () => setState(() {
              distanceControllers.add(
                TextEditingController(text: distanceControllers.last.text),
              );
            }),
            icon: const Icon(Icons.add),
            label: const Text("ADD SET"),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: hybridTimerController,
            decoration: const InputDecoration(
              labelText: "Rest Timer (seconds)",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timer),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              MaxValueInputFormatter(100000),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthConfig() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(selectedExercise.value!.name),
            onDeleted: () {
              selectedExercise.value = null;
              selectedEquipmentId.value = null;
            },
            deleteIcon: const Icon(Icons.close),
          ),
          const SizedBox(height: 20),
          const Text(
            "Equipment Type",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
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
          const SizedBox(height: 25),
          ...setControllers.asMap().entries.map((entry) {
            final i = entry.key;
            final ctrl = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      "Set ${i + 1}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        MaxValueInputFormatter(100000),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Reps",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  if (setControllers.length > 1)
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () => setState(() {
                        setControllers[i].dispose();
                        setControllers.removeAt(i);
                      }),
                    ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: () => setState(() {
              setControllers.add(
                TextEditingController(text: setControllers.last.text),
              );
            }),
            icon: const Icon(Icons.add),
            label: const Text("ADD SET"),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: timerController,
            decoration: const InputDecoration(
              labelText: "Rest Timer (seconds)",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timer),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              MaxValueInputFormatter(100000),
            ],
          ),
        ],
      ),
    );
  }
}
