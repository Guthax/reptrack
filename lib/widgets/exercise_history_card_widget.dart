import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reptrack/controllers/settings_controller.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';

class ExerciseHistoryDialog extends StatelessWidget {
  final String exerciseId;
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
          const Text(
            "Workout Sessions",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: double.maxFinite,
        height: 450,
        child: FutureBuilder(
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
                child: Text(
                  "No history recorded yet.",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            final List<WorkoutSet> allSets = snapshot.data![0];
            final List<Equipment> allEquip = snapshot.data![1];

            final equipMap = {for (var e in allEquip) e.id: e.name};

            final Map<String, List<WorkoutSet>> sessions = {};
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

                final sessionDate = DateFormat(
                  'EEEE, dd MMM yyyy',
                ).format(sets.first.dateLogged);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        bottom: 8,
                        top: 12,
                      ),
                      child: Text(
                        sessionDate.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 0,
                      color: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.outline),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Column(
                          children: sets.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final set = entry.value;
                            final isLast = idx == sets.length - 1;

                            final equipName =
                                equipMap[set.equipmentId] ?? "Unknown";

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "SET ${set.setNumber}",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textDisabled,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          Text(
                                            equipName,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: AppColors.textDisabled,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Builder(
                                        builder: (context) {
                                          final settings =
                                              Get.find<SettingsController>();
                                          final display = settings
                                              .displayWeight(set.weight);
                                          return Text(
                                            display.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                      Builder(
                                        builder: (context) {
                                          final settings =
                                              Get.find<SettingsController>();
                                          return Text(
                                            ' ${settings.unitLabel}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 20),
                                      Text(
                                        "${set.reps}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        " reps",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isLast)
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: AppColors.outline,
                                  ),
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
          child: const Text(
            "Close",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
