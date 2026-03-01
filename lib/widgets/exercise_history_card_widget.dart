import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reptrack/persistance/database.dart';

class ExerciseHistoryDialog extends StatelessWidget {
  final int exerciseId;
  final String exerciseName;

  const ExerciseHistoryDialog({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  Widget build(BuildContext context) {
    final db = Get.find<AppDatabase>();

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exerciseName),
          const Text("Workout Sessions",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
        ],
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: double.maxFinite,
        height: 450,
        child: FutureBuilder(
          // We wait for both the sets and the equipment list to arrive
          future: Future.wait([
            db.getSetsForExercise(exerciseId),
            db.select(db.equipments).get(),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || (snapshot.data![0] as List).isEmpty) {
              return const Center(
                  child: Text("No history recorded yet.", style: TextStyle(color: Colors.grey)));
            }

            final List<WorkoutSet> allSets = snapshot.data![0];
            final List<Equipment> allEquip = snapshot.data![1];

            // Create a map for quick equipment name lookup
            final equipMap = {for (var e in allEquip) e.id: e.name};

            // 1. Group sets by workoutId (Session)
            final Map<int, List<WorkoutSet>> sessions = {};
            for (var set in allSets) {
              sessions.putIfAbsent(set.workoutId, () => []).add(set);
            }

            final workoutIds = sessions.keys.toList();

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: workoutIds.length,
              itemBuilder: (context, index) {
                final workoutId = workoutIds[index];
                final sets = sessions[workoutId]!;
                sets.sort((a, b) => a.setNumber.compareTo(b.setNumber));

                final sessionDate = DateFormat('EEEE, dd MMM yyyy').format(sets.first.dateLogged);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
                      child: Text(
                        sessionDate.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            letterSpacing: 0.5),
                      ),
                    ),
                    Card(
                      elevation: 0,
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Column(
                          children: sets.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final set = entry.value;
                            final isLast = idx == sets.length - 1;
                            
                            // Lookup equipment name
                            final equipName = equipMap[set.equipmentId] ?? "Unknown";

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("SET ${set.setNumber}",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey.shade400)),
                                          Text(equipName,
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.blueGrey.withOpacity(0.6))),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text("${set.weight}",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const Text(" kg", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      const SizedBox(width: 20),
                                      Text("${set.reps}",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const Text(" reps", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                if (!isLast) Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}