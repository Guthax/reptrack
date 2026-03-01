import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/widgets/exercise_history_card_widget.dart';
import 'package:reptrack/widgets/swap_exercise_dialog.dart';

class ExerciseSwipeCard extends StatelessWidget {
  final ExerciseWithVolume item;
  ExerciseSwipeCard({super.key, required this.item});

  final RxList<Equipment> alternatives = <Equipment>[].obs;

  void _loadAlternatives() async {
    final db = Get.find<AppDatabase>();
    final list = await db.getEquipmentForExercise(item.exercise.id);
    alternatives.assignAll(list);
  }

  @override
  Widget build(BuildContext context) {
    _loadAlternatives();
    final controller = Get.find<ActiveWorkoutController>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER WITH HISTORY/SWAP BUTTONS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.exercise.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          item.exercise.muscleGroup ?? "General",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.find_replace, color: Colors.blueAccent),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => SwapExerciseDialog(
                        exerciseId: item.exercise.id,
                        exerciseName: item.exercise.name,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.blueAccent),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => ExerciseHistoryDialog(
                        exerciseId: item.exercise.id,
                        exerciseName: item.exercise.name,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text("SWITCH EQUIPMENT",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 8),

              Obx(() => Wrap(
                    spacing: 8,
                    children: alternatives.map((e) {
                      final isSelected = controller.selectedEquipments[item.exercise.id] == e.id;
                      return ChoiceChip(
                        label: Text(e.name),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) controller.selectedEquipments[item.exercise.id] = e.id;
                        },
                      );
                    }).toList(),
                  )),

              const Divider(height: 30),

              // --- LOGGING SECTION ---
              Expanded(
                child: Obx(() {
                  final currentEquipId = controller.selectedEquipments[item.exercise.id] ?? item.equipment?.id ?? 0;
                  return ListView.builder(
                    itemCount: item.volume.sets,
                    itemBuilder: (context, index) => SetLogRow(
                      key: ValueKey("${item.exercise.id}-$currentEquipId-${index + 1}"),
                      setNum: index + 1,
                      exerciseId: item.exercise.id,
                      equipmentId: currentEquipId,
                      plannedReps: item.volume.reps,
                      plannedWeight: item.volume.weight,
                      restSeconds: item.volume.restTimer ?? 60, // Passed from volume
                    ),
                  );
                }),
              ),

              // --- TIMER FOOTER ---
              Obx(() {
                final timeLeft = controller.remainingRestTime.value;
                if (timeLeft <= 0) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Rest Timer: ${timeLeft}s",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => controller.skipRestTimer(),
                        child: const Text("SKIP"),
                      )
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class SetLogRow extends StatefulWidget {
  final int setNum;
  final int exerciseId;
  final int equipmentId;
  final int plannedReps;
  final double plannedWeight;
  final int restSeconds;

  const SetLogRow({
    super.key,
    required this.setNum,
    required this.exerciseId,
    required this.equipmentId,
    required this.plannedReps,
    required this.plannedWeight,
    required this.restSeconds,
  });

  @override
  State<SetLogRow> createState() => _SetLogRowState();
}

class _SetLogRowState extends State<SetLogRow> {
  late TextEditingController repsController;
  late TextEditingController weightController;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<ActiveWorkoutController>();
    final pastSet = controller.getPastSetData(widget.exerciseId, widget.setNum, widget.equipmentId);

    repsController = TextEditingController(text: pastSet != null ? pastSet.reps.toString() : widget.plannedReps.toString());
    weightController = TextEditingController(text: pastSet != null ? pastSet.weight.toString() : widget.plannedWeight.toString());
  }

  @override
  void dispose() {
    repsController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();

    return Obx(() {
      final bool isSaved = controller.isSetCompleted(widget.exerciseId, widget.setNum);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSaved ? Colors.green.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSaved ? Colors.green : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isSaved ? Colors.green : Colors.grey.shade300,
              child: Text("${widget.setNum}", style: const TextStyle(fontSize: 12, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: repsController,
                enabled: !isSaved,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Reps", floatingLabelBehavior: FloatingLabelBehavior.always),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: weightController,
                enabled: !isSaved,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Kg", floatingLabelBehavior: FloatingLabelBehavior.always),
              ),
            ),
            IconButton(
              icon: Icon(isSaved ? Icons.check_circle : Icons.check_circle_outline),
              color: isSaved ? Colors.green : Colors.grey,
              onPressed: isSaved
                  ? null
                  : () async {
                      await controller.logSet(
                        exerciseId: widget.exerciseId,
                        equipmentId: widget.equipmentId,
                        reps: int.tryParse(repsController.text) ?? 0,
                        weight: double.tryParse(weightController.text) ?? 0,
                        setNum: widget.setNum,
                        restSeconds: widget.restSeconds, // Trigger timer on save
                      );
                    },
            )
          ],
        ),
      );
    });
  }
}