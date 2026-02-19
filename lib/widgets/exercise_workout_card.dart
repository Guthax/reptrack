import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/persistance/composites.dart';

class ExerciseSwipeCard extends StatelessWidget {
  final ExerciseWithVolume item;
  const ExerciseSwipeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
              Text(item.exercise.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(item.exercise.muscleGroup ?? "General", style: TextStyle(color: Colors.grey[600])),
              const Divider(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: item.volume.sets,
                  itemBuilder: (context, index) => SetLogRow(
                    setNum: index + 1,
                    exerciseId: item.exercise.id,
                    plannedReps: item.volume.reps,
                    plannedWeight: item.volume.weight,
                  ),
                ),
              ),
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
  final int plannedReps;
  final double plannedWeight;

  const SetLogRow({
    super.key,
    required this.setNum,
    required this.exerciseId,
    required this.plannedReps,
    required this.plannedWeight,
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
    
    // Look for this specific set number from the last session
    final pastSet = controller.getPastSetData(widget.exerciseId, widget.setNum);

    // If we found a past set, use those values. Otherwise use the template (planned) values.
    repsController = TextEditingController(
      text: pastSet != null ? pastSet.reps.toString() : widget.plannedReps.toString()
    );
    weightController = TextEditingController(
      text: pastSet != null ? pastSet.weight.toString() : widget.plannedWeight.toString()
    );
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
              onPressed: isSaved ? null : () async {
                await controller.logSet(
                  exerciseId: widget.exerciseId,
                  reps: int.tryParse(repsController.text) ?? 0,
                  weight: double.tryParse(weightController.text) ?? 0,
                  setNum: widget.setNum,
                );
              },
            )
          ],
        ),
      );
    });
  }
}