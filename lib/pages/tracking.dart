import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reptrack/controllers/tracking_controller.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrackingController());
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
      body: Obx(() {
        if (controller.selectedExercise.value == null) {
          return _ExerciseSearchView(controller: controller);
        }
        return _ExerciseProgressView(controller: controller);
      }),
    );
  }
}

class _ExerciseSearchView extends StatelessWidget {
  final TrackingController controller;
  const _ExerciseSearchView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search exercise...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: controller.filterExercises,
          ),
        ),
        Expanded(
          child: Obx(
            () => ListView.builder(
              itemCount: controller.filteredExercises.length,
              itemBuilder: (ctx, i) {
                final ex = controller.filteredExercises[i];
                return _ExerciseTile(exercise: ex, controller: controller);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final TrackingController controller;

  const _ExerciseTile({required this.exercise, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(exercise.name),
      subtitle: exercise.muscleGroup != null
          ? Text(exercise.muscleGroup!)
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => controller.selectExercise(exercise),
    );
  }
}

class _ExerciseProgressView extends StatelessWidget {
  final TrackingController controller;
  const _ExerciseProgressView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final exercise = controller.selectedExercise.value!;
      final data = controller.weightProgressData;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: controller.clearSelection,
                ),
                Expanded(
                  child: Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
          if (data.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No workout data for this exercise yet.'),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                'Max weight per session',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 24, 24),
                child: _WeightChart(data: data),
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _WeightChart extends StatelessWidget {
  final List<MapEntry<DateTime, double>> data;
  const _WeightChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minY = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final yPad = ((maxY - minY) * 0.2).clamp(2.0, double.infinity);
    final dateFormat = DateFormat('d MMM');
    final labelInterval = (data.length / 5).ceilToDouble().clamp(
      1.0,
      double.infinity,
    );

    return LineChart(
      LineChartData(
        minY: (minY - yPad).clamp(0.0, double.infinity),
        maxY: maxY + yPad,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (val, meta) => Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    '${val.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: labelInterval,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx < 0 || idx >= data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    dateFormat.format(data[idx].key),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (val) =>
              const FlLine(color: AppColors.outline, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: AppColors.outline),
            left: BorderSide(color: AppColors.outline),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: primaryColor,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: primaryColor,
                strokeWidth: 1.5,
                strokeColor: AppColors.background,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withValues(alpha: 0.08),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceVariant,
            getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
              final idx = s.x.toInt();
              if (idx < 0 || idx >= data.length) return null;
              return LineTooltipItem(
                '${dateFormat.format(data[idx].key)}\n${s.y.toStringAsFixed(1)} kg',
                const TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
