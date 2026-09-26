import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reptrack/controllers/active_workout_controller.dart';
import 'package:reptrack/controllers/settings_controller.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:reptrack/utils/duration_format.dart';

class ExerciseHistoryDialog extends StatelessWidget {
  final String exerciseId;
  final String exerciseName;
  final bool isCardio;
  final bool isHybrid;

  /// Whether the exercise is timed; shows durations and optional weights.
  final bool isTimed;

  const ExerciseHistoryDialog({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    this.isCardio = false,
    this.isHybrid = false,
    this.isTimed = false,
  });

  String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return s > 0 ? '${m}m ${s}s' : '${m}m';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exerciseName),
          Text(
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
        child: isCardio
            ? _CardioHistoryList(
                exerciseId: exerciseId,
                formatDuration: _formatDuration,
              )
            : isHybrid
            ? _HybridHistoryList(exerciseId: exerciseId)
            : isTimed
            ? _TimedHistoryLoader(exerciseId: exerciseId)
            : _StrengthHistoryList(exerciseId: exerciseId),
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

class _StrengthHistoryList extends StatelessWidget {
  final String exerciseId;

  const _StrengthHistoryList({required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    final db = Get.find<AppDatabase>();

    return FutureBuilder(
      future: Future.wait<List<dynamic>>([
        db.getStrengthSetsForExercise(exerciseId),
        db.select(db.equipments).get(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || (snapshot.data![0] as List).isEmpty) {
          return Center(
            child: Text(
              "No history recorded yet.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        final List<WorkoutStrengthSet> allSets =
            snapshot.data![0] as List<WorkoutStrengthSet>;
        final List<Equipment> allEquip = snapshot.data![1] as List<Equipment>;
        final equipMap = {for (var e in allEquip) e.id: e.name};

        final Map<String, List<WorkoutStrengthSet>> sessions = {};
        for (var set in allSets) {
          sessions.putIfAbsent(set.workoutId, () => []).add(set);
        }
        final workoutIds = sessions.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: workoutIds.length,
          itemBuilder: (context, index) {
            final sets = sessions[workoutIds[index]]!
              ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
            final sessionDate = DateFormat(
              'EEEE, dd MMM yyyy',
            ).format(sets.first.dateLogged);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
                  child: Text(
                    sessionDate.toUpperCase(),
                    style: TextStyle(
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
                    side: BorderSide(color: AppColors.outline),
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "SET ${set.setNumber}",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDisabled,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        equipName,
                                        style: TextStyle(
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
                                      final display = settings.displayWeight(
                                        set.weight,
                                      );
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
                                        style: TextStyle(
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
                                  Text(
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
                              Divider(
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
    );
  }
}

class _CardioHistoryList extends StatelessWidget {
  final String exerciseId;
  final String Function(int) formatDuration;

  const _CardioHistoryList({
    required this.exerciseId,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final db = Get.find<AppDatabase>();

    return FutureBuilder(
      future: db.getCardioSetsForExercise(exerciseId),
      builder: (context, AsyncSnapshot<List<WorkoutCardioSet>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No history recorded yet.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        final entries = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final sessionDate = DateFormat(
              'EEEE, dd MMM yyyy',
            ).format(entry.dateLogged);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
                  child: Text(
                    sessionDate.toUpperCase(),
                    style: TextStyle(
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
                    side: BorderSide(color: AppColors.outline),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatDuration(entry.durationSeconds),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (entry.distanceMeters != null) ...[
                          const SizedBox(width: 24),
                          Icon(
                            Icons.straighten,
                            size: 16,
                            color: AppColors.textDisabled,
                          ),
                          const SizedBox(width: 8),
                          Builder(
                            builder: (context) {
                              final unit = entry.distanceUnit;
                              final meters = entry.distanceMeters!;
                              final dist = unit == 'km'
                                  ? meters / 1000
                                  : unit == 'mi'
                                  ? meters / 1609.344
                                  : unit == 'ft'
                                  ? meters / 0.3048
                                  : meters;
                              final formatted = dist < 10
                                  ? dist.toStringAsFixed(2)
                                  : dist.toStringAsFixed(1);
                              return Text(
                                '$formatted $unit',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _HybridHistoryList extends StatelessWidget {
  final String exerciseId;

  const _HybridHistoryList({required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    final db = Get.find<AppDatabase>();

    return FutureBuilder(
      future: Future.wait<List<dynamic>>([
        db.getHybridSetsForExercise(exerciseId),
        db.select(db.equipments).get(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || (snapshot.data![0] as List).isEmpty) {
          return Center(
            child: Text(
              "No history recorded yet.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        final List<WorkoutHybridSet> allSets =
            snapshot.data![0] as List<WorkoutHybridSet>;
        final List<Equipment> allEquip = snapshot.data![1] as List<Equipment>;
        final equipMap = {for (var e in allEquip) e.id: e.name};

        final Map<String, List<WorkoutHybridSet>> sessions = {};
        for (var set in allSets) {
          sessions.putIfAbsent(set.workoutId, () => []).add(set);
        }
        final workoutIds = sessions.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: workoutIds.length,
          itemBuilder: (context, index) {
            final sets = sessions[workoutIds[index]]!
              ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
            final sessionDate = DateFormat(
              'EEEE, dd MMM yyyy',
            ).format(sets.first.dateLogged);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
                  child: Text(
                    sessionDate.toUpperCase(),
                    style: TextStyle(
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
                    side: BorderSide(color: AppColors.outline),
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
                            equipMap[set.equipmentId] ?? 'Unknown';

                        String fmt(double d) => d == d.truncateToDouble()
                            ? d.toInt().toString()
                            : d.toStringAsFixed(1);

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "SET ${set.setNumber}",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDisabled,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        equipName,
                                        style: TextStyle(
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
                                      final display = settings.displayWeight(
                                        set.weight,
                                      );
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
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    fmt(set.distance),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' ${set.distanceUnit}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Divider(
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
    );
  }
}

/// Loads the timed history of [exerciseId] through
/// [ActiveWorkoutController.loadTimedHistory] and shows it as a
/// [TimedHistoryList].
class _TimedHistoryLoader extends StatelessWidget {
  final String exerciseId;

  const _TimedHistoryLoader({required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActiveWorkoutController>();

    return FutureBuilder<List<WorkoutTimedSet>>(
      future: controller.loadTimedHistory(exerciseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return TimedHistoryList(sets: snapshot.data ?? []);
      },
    );
  }
}

/// Timed set history grouped per workout session, newest session first.
///
/// Each set shows its duration and weight, or "no time recorded" for sets
/// converted from strength history.
class TimedHistoryList extends StatelessWidget {
  /// The completed timed sets to show, newest first.
  final List<WorkoutTimedSet> sets;

  const TimedHistoryList({super.key, required this.sets});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final allSets = sets;

    return Builder(
      builder: (context) {
        if (allSets.isEmpty) {
          return Center(
            child: Text(
              "No history recorded yet.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        final Map<String, List<WorkoutTimedSet>> sessions = {};
        for (final set in allSets) {
          sessions.putIfAbsent(set.workoutId, () => []).add(set);
        }
        final workoutIds = sessions.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: workoutIds.length,
          itemBuilder: (context, index) {
            final sessionSets = [...sessions[workoutIds[index]]!]
              ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
            final sessionDate = DateFormat(
              'EEEE, dd MMM yyyy',
            ).format(sessionSets.first.dateLogged);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
                  child: Text(
                    sessionDate.toUpperCase(),
                    style: TextStyle(
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
                    side: BorderSide(color: AppColors.outline),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        for (final set in sessionSets)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Text(
                                  "SET ${set.setNumber}",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDisabled,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  formatTimedSet(
                                    set.durationSeconds,
                                    weightText: set.weight == null
                                        ? null
                                        : '${settings.displayWeight(set.weight!).toStringAsFixed(1)} ${settings.unitLabel}',
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: set.durationSeconds == 0
                                        ? AppColors.textSecondary
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
