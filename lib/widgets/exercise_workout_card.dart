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
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
     // --- LOGGING SECTION ---
Expanded(
  child: Obx(() {
    final currentEquipId = controller.selectedEquipments[item.exercise.id] ?? item.equipment?.id ?? 0;
    final totalSets = controller.getTotalSetsForExercise(item.exercise.id, item.volume.sets);

    return ListView.builder(
      itemCount: totalSets + 1,
      itemBuilder: (context, index) {
        // 1. Render the Add Button at the very end
        if (index == totalSets) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 20),
            child: OutlinedButton.icon(
              onPressed: () => controller.addExtraSet(item.exercise.id),
              icon: const Icon(Icons.add),
              label: const Text("ADD EXTRA SET"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blueGrey,
                side: BorderSide(color: Colors.blueGrey.shade200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        }

        // 2. Render the Set Rows
        final setNum = index + 1;
        final isExtraSet = setNum > item.volume.sets;
        final isSaved = controller.isSetCompleted(item.exercise.id, setNum);
        
        // NEW FIX: Is this the very last set in the entire list?
        final isLastSet = setNum == totalSets;

        // This unique key is vital for Dismissible to work
        final itemKey = Key("set_${item.exercise.id}_${currentEquipId}_$setNum");

        return Dismissible(
          key: itemKey,
          // Only allow swipe-to-delete if it's an extra set, NOT saved, AND it's the bottom-most set
          direction: (isExtraSet && !isSaved && isLastSet) 
              ? DismissDirection.startToEnd 
              : DismissDirection.none,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            controller.removeExtraSet(item.exercise.id);
          },
          child: SetLogRow(
            key: itemKey,
            setNum: setNum,
            exerciseId: item.exercise.id,
            equipmentId: currentEquipId,
            plannedReps: item.volume.reps,
            plannedWeight: item.volume.weight,
            restSeconds: item.volume.restTimer ?? 60,
          ),
        );
      },
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
    
    final lastSessionSet = controller.getLastLoggedSet(widget.exerciseId);
    final pastWorkoutSet = controller.getPastSetData(widget.exerciseId, widget.setNum, widget.equipmentId);

    String initialReps = widget.plannedReps.toString();
    String initialWeight = widget.plannedWeight.toString();

    if (lastSessionSet != null) {
      // FIX: Extraction of .value from Drift Companion Value wrapper
      initialReps = lastSessionSet.reps.value.toString();
      initialWeight = lastSessionSet.weight.value.toString();
    } else if (pastWorkoutSet != null) {
      initialReps = pastWorkoutSet.reps.toString();
      initialWeight = pastWorkoutSet.weight.toString();
    }

    repsController = TextEditingController(text: initialReps);
    weightController = TextEditingController(text: initialWeight);
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
                controller: weightController,
                enabled: !isSaved,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Kg", floatingLabelBehavior: FloatingLabelBehavior.always),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: repsController,
                enabled: !isSaved,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Reps", floatingLabelBehavior: FloatingLabelBehavior.always),
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
                        restSeconds: widget.restSeconds,
                      );
                    },
            )
          ],
        ),
      );
    });
  }
}