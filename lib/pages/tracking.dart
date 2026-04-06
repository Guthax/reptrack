import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reptrack/controllers/settings_controller.dart';
import 'package:reptrack/controllers/tracking_controller.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/pages/settings.dart';
import 'package:reptrack/utils/app_theme.dart';

/// Page for viewing historical weight-progress charts per exercise and
/// bodyweight over time.
///
/// A [SegmentedButton] below the title switches between the exercises tab
/// (search list + progress chart) and the bodyweight tab (chart + log button).
class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrackingController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Get.to(() => const SettingsPage()),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Obx(
              () => SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Exercises')),
                  ButtonSegment(value: 1, label: Text('Bodyweight')),
                ],
                selected: {controller.selectedTab.value},
                onSelectionChanged: (s) {
                  controller.selectedTab.value = s.first;
                  if (s.first == 0) controller.clearSelection();
                },
                showSelectedIcon: false,
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.selectedTab.value == 1) {
          return _BodyweightView(controller: controller);
        }
        if (controller.selectedExercise.value == null) {
          return _ExerciseSearchView(controller: controller);
        }
        return _ExerciseProgressView(controller: controller);
      }),
    );
  }
}

/// Displays a search field and a list of [Exercise]s filtered by the query.
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

/// A single row in the exercise search list.
class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final TrackingController controller;

  const _ExerciseTile({required this.exercise, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(exercise.name),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => controller.selectExercise(exercise),
    );
  }
}

/// Shows the progress chart and filter chips for the currently selected exercise.
/// Adapts chart types based on exercise type (strength / cardio / hybrid).
class _ExerciseProgressView extends StatelessWidget {
  final TrackingController controller;

  const _ExerciseProgressView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final exercise = controller.selectedExercise.value!;
      final typeId = controller.selectedExerciseTypeId.value;
      final chartType = controller.selectedChartType.value;

      // Resolve chart data + display config based on current type and selection.
      final _ChartConfig cfg = _resolveConfig(typeId, chartType, controller);

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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (controller.availableEquipment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final equipment in controller.availableEquipment)
                    Obx(() {
                      final isSelected =
                          controller.selectedEquipment.value?.id ==
                          equipment.id;
                      return FilterChip(
                        label: Text(
                          equipment.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.black : null,
                            fontWeight: isSelected ? FontWeight.w600 : null,
                          ),
                        ),
                        selected: isSelected,
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.surfaceVariant,
                        selectedColor: AppColors.primary,
                        onSelected: (_) {
                          controller.selectedEquipment.value = equipment;
                        },
                      );
                    }),
                ],
              ),
            ),
          if (cfg.data.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No workout data for this exercise yet.'),
              ),
            )
          else
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 24, 64),
                    child: _WeightChart(
                      data: cfg.data,
                      convertWeight: cfg.convertWeight,
                      yUnit: cfg.yUnit,
                      tooltipFormatter: cfg.tooltipFormatter,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<ChartType>(
                        style: ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                        segments: _segmentsFor(typeId),
                        selected: {chartType},
                        onSelectionChanged: (s) =>
                            controller.selectedChartType.value = s.first,
                        showSelectedIcon: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  List<ButtonSegment<ChartType>> _segmentsFor(String typeId) {
    if (typeId == '2') {
      return const [
        ButtonSegment(
          value: ChartType.duration,
          icon: Icon(Icons.timer_outlined, size: 16),
          label: Text('Duration'),
        ),
        ButtonSegment(
          value: ChartType.distance,
          icon: Icon(Icons.straighten, size: 16),
          label: Text('Distance'),
        ),
        ButtonSegment(
          value: ChartType.pace,
          icon: Icon(Icons.speed, size: 16),
          label: Text('Pace'),
        ),
      ];
    }
    if (typeId == '3') {
      return const [
        ButtonSegment(
          value: ChartType.hybridMaxWeight,
          icon: Icon(Icons.trending_up, size: 16),
          label: Text('Max Weight'),
        ),
        ButtonSegment(
          value: ChartType.hybridTotalDistance,
          icon: Icon(Icons.straighten, size: 16),
          label: Text('Distance'),
        ),
        ButtonSegment(
          value: ChartType.hybridVolume,
          icon: Icon(Icons.bar_chart, size: 16),
          label: Text('Volume'),
        ),
      ];
    }
    // Strength
    return const [
      ButtonSegment(
        value: ChartType.maxWeight,
        icon: Icon(Icons.trending_up, size: 16),
        label: Text('Max Weight'),
      ),
      ButtonSegment(
        value: ChartType.totalVolume,
        icon: Icon(Icons.bar_chart, size: 16),
        label: Text('Volume'),
      ),
    ];
  }

  _ChartConfig _resolveConfig(
    String typeId,
    ChartType chartType,
    TrackingController c,
  ) {
    if (typeId == '2') {
      switch (chartType) {
        case ChartType.distance:
          return _ChartConfig(
            data: c.cardioDistanceData,
            convertWeight: false,
            yUnit: 'km',
            tooltipFormatter: (y, u) => '${y.toStringAsFixed(2)} $u',
          );
        case ChartType.pace:
          return _ChartConfig(
            data: c.cardioPaceData,
            convertWeight: false,
            yUnit: 'min/km',
            tooltipFormatter: (y, _) {
              final mins = y.floor();
              final secs = ((y - mins) * 60).round();
              return '${mins}:${secs.toString().padLeft(2, '0')} min/km';
            },
          );
        default:
          return _ChartConfig(
            data: c.cardioDurationData,
            convertWeight: false,
            yUnit: 'min',
            tooltipFormatter: (y, _) {
              final h = (y ~/ 60);
              final m = (y % 60).floor();
              final s = ((y % 1) * 60).round();
              if (h > 0) return '${h}h ${m}m';
              if (s > 0) return '${m}m ${s}s';
              return '${m}m';
            },
          );
      }
    }
    if (typeId == '3') {
      switch (chartType) {
        case ChartType.hybridTotalDistance:
          return _ChartConfig(
            data: c.hybridTotalDistanceData,
            convertWeight: false,
            yUnit: 'm',
            tooltipFormatter: (y, _) {
              if (y >= 1000) {
                return '${(y / 1000).toStringAsFixed(2)} km';
              }
              return '${y.toStringAsFixed(0)} m';
            },
          );
        case ChartType.hybridVolume:
          return _ChartConfig(
            data: c.hybridVolumeData,
            convertWeight: false,
            yUnit: 'kg·m',
            tooltipFormatter: (y, u) => '${y.toStringAsFixed(0)} $u',
          );
        default:
          return _ChartConfig(
            data: c.hybridMaxWeightData,
            convertWeight: true,
            yUnit: '',
          );
      }
    }
    // Strength
    final data = chartType == ChartType.totalVolume
        ? c.volumeProgressData
        : c.weightProgressData;
    return _ChartConfig(data: data, convertWeight: true, yUnit: '');
  }
}

/// Resolved chart configuration for the current exercise type + chart type.
class _ChartConfig {
  final List<MapEntry<DateTime, double>> data;
  final bool convertWeight;
  final String yUnit;
  final String Function(double, String)? tooltipFormatter;

  const _ChartConfig({
    required this.data,
    required this.convertWeight,
    required this.yUnit,
    this.tooltipFormatter,
  });
}

/// Bodyweight tab: a line chart of logged bodyweight entries plus a log button.
class _BodyweightView extends StatelessWidget {
  final TrackingController controller;

  const _BodyweightView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entries = controller.bodyweightEntries;

      return Column(
        children: [
          if (entries.isEmpty)
            const Expanded(
              child: Center(child: Text('No bodyweight entries yet.')),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Bodyweight over time — tap a point to delete',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 24, 16),
                child: _WeightChart(
                  data: entries.map((e) => MapEntry(e.date, e.weight)).toList(),
                  onTapIndex: (idx) => _confirmDelete(entries[idx]),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Log Bodyweight'),
                onPressed: _showLogDialog,
              ),
            ),
          ),
        ],
      );
    });
  }

  void _showLogDialog() {
    final settings = Get.find<SettingsController>();
    controller.logDate.value = DateTime.now();
    final textController = TextEditingController();
    Get.dialog(
      Builder(
        builder: (context) => AlertDialog(
          title: const Text('Log Bodyweight'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => TextField(
                  controller: textController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*')),
                    MaxValueInputFormatter(100000),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Weight in ${settings.unitLabel}',
                    suffixText: settings.unitLabel,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final now = DateTime.now();
                final d = controller.logDate.value;
                final isToday =
                    d.year == now.year &&
                    d.month == now.month &&
                    d.day == now.day;
                return OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    isToday ? 'Today' : DateFormat('d MMM yyyy').format(d),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.logDate.value,
                      firstDate: DateTime(2000),
                      lastDate: now,
                    );
                    if (picked != null) {
                      controller.logDate.value = picked;
                    }
                  },
                );
              }),
            ],
          ),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(
                  textController.text.replaceAll(',', '.'),
                );
                if (value != null && value > 0) {
                  controller.logBodyweight(
                    settings.toKg(value),
                    date: controller.logDate.value,
                  );
                  Get.back();
                }
              },
              child: const Text('LOG'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BodyweightEntry entry) {
    final settings = Get.find<SettingsController>();
    final date = DateFormat('d MMM yyyy').format(entry.date);
    final displayWeight = settings.displayWeight(entry.weight);
    Get.dialog(
      AlertDialog(
        title: const Text('Delete entry?'),
        content: Text(
          '${displayWeight.toStringAsFixed(1)} ${settings.unitLabel} on $date will be removed.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              controller.deleteBodyweight(entry.id);
              Get.back();
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}

/// Renders a generic [LineChart] over time.
///
/// When [convertWeight] is true, values are treated as kg and converted via
/// [SettingsController] to the active display unit. Otherwise [yUnit] is shown
/// as-is. [onTapIndex] is called with the tapped spot index when provided.
class _WeightChart extends StatelessWidget {
  final List<MapEntry<DateTime, double>> data;
  final void Function(int index)? onTapIndex;

  /// If true (default), values are weight in kg and are converted/labelled
  /// using [SettingsController]. If false, [yUnit] is used directly.
  final bool convertWeight;

  /// Unit label shown on the y-axis when [convertWeight] is false.
  final String yUnit;

  /// Optional custom tooltip formatter. Receives the raw [y] value and the
  /// [yUnit] string; returns the label string.
  final String Function(double y, String unit)? tooltipFormatter;

  const _WeightChart({
    required this.data,
    this.onTapIndex,
    this.convertWeight = true,
    this.yUnit = '',
    this.tooltipFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final dateFormat = DateFormat('d MMM');
    final labelInterval = (data.length / 5).ceilToDouble().clamp(
      1.0,
      double.infinity,
    );

    return Obx(() {
      // Always read useImperial so Obx has a reactive dependency even when
      // convertWeight is false (otherwise GetX throws an improper-use error).
      final isImperial = settings.useImperial.value;

      // Resolve display values and unit label.
      final List<double> displayValues;
      final String unit;
      if (convertWeight) {
        displayValues = data
            .map((e) => isImperial ? e.value * 2.20462 : e.value)
            .toList();
        unit = isImperial ? 'lbs' : 'kg';
      } else {
        displayValues = data.map((e) => e.value).toList();
        unit = yUnit;
      }

      final spots = data
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), displayValues[e.key]))
          .toList();

      final maxY = displayValues.reduce((a, b) => a > b ? a : b);
      final minY = displayValues.reduce((a, b) => a < b ? a : b);
      final yPad = ((maxY - minY) * 0.2).clamp(2.0, double.infinity);

      String defaultTooltip(double y, String u) => '${y.toStringAsFixed(2)} $u';
      final fmtTooltip = tooltipFormatter ?? defaultTooltip;

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
                reservedSize: 56,
                getTitlesWidget: (val, meta) => Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      '${val.toStringAsFixed(convertWeight ? 2 : 1)} $unit',
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
              isCurved: false,
              color: primaryColor,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
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
            touchCallback: onTapIndex == null
                ? null
                : (event, response) {
                    if (event is FlTapUpEvent &&
                        response?.lineBarSpots != null &&
                        response!.lineBarSpots!.isNotEmpty) {
                      final idx = response.lineBarSpots!.first.spotIndex;
                      if (idx >= 0 && idx < data.length) {
                        onTapIndex!(idx);
                      }
                    }
                  },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceVariant,
              getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                final idx = s.x.toInt();
                if (idx < 0 || idx >= data.length) return null;
                return LineTooltipItem(
                  '${dateFormat.format(data[idx].key)}\n${fmtTooltip(s.y, unit)}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.5,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    });
  }
}
