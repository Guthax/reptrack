import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/persistance/composites.dart';
import 'package:reptrack/persistance/database.dart';
import 'package:reptrack/utils/app_theme.dart';

class WorkoutInformationDialog extends StatelessWidget {
  final WorkoutDayWithExercises dayWithExercises;

  const WorkoutInformationDialog({super.key, required this.dayWithExercises});

  @override
  Widget build(BuildContext context) {
    final primaryMuscles = dayWithExercises.exercises
        .map((e) => (e.exercise.muscleGroup ?? '').toLowerCase().trim())
        .where((m) => m.isNotEmpty)
        .toSet();

    final exerciseIds = dayWithExercises.exercises
        .map((e) => e.exercise.id)
        .toList();

    final db = Get.find<AppDatabase>();

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: FutureBuilder<Set<String>>(
          future: db.getSecondaryMuscleGroupsForExercises(exerciseIds),
          builder: (context, snapshot) {
            // Secondary muscles that aren't already primary
            final secondaryMuscles = (snapshot.data ?? {}).difference(
              primaryMuscles,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dayWithExercises.workoutDay.dayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '${dayWithExercises.exercises.length} exercises',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 260,
                  child: Row(
                    children: [
                      Expanded(
                        child: _BodyView(
                          label: 'FRONT',
                          primaryMuscles: primaryMuscles,
                          secondaryMuscles: secondaryMuscles,
                          view: BodyView.front,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _BodyView(
                          label: 'BACK',
                          primaryMuscles: primaryMuscles,
                          secondaryMuscles: secondaryMuscles,
                          view: BodyView.back,
                        ),
                      ),
                    ],
                  ),
                ),
                if (primaryMuscles.isNotEmpty ||
                    secondaryMuscles.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final m in primaryMuscles)
                        _MuscleChip(
                          label: m[0].toUpperCase() + m.substring(1),
                          isPrimary: true,
                        ),
                      for (final m in secondaryMuscles)
                        _MuscleChip(
                          label: m[0].toUpperCase() + m.substring(1),
                          isPrimary: false,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(onPressed: Get.back, child: const Text('CLOSE')),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BodyView extends StatelessWidget {
  final String label;
  final Set<String> primaryMuscles;
  final Set<String> secondaryMuscles;
  final BodyView view;

  const _BodyView({
    required this.label,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.view,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: CustomPaint(
            painter: BodyDiagramPainter(
              primaryMuscles: primaryMuscles,
              secondaryMuscles: secondaryMuscles,
              view: view,
            ),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }
}

class _MuscleChip extends StatelessWidget {
  final String label;
  final bool isPrimary;

  const _MuscleChip({required this.label, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    // Primary: Electric Lime. Secondary: dark lime.
    const primaryColor = AppColors.primary;
    const secondaryColor = Color(0xFF8AB800); // mid-tone lime for chips
    final color = isPrimary ? primaryColor : secondaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color.fromARGB(
          isPrimary ? 38 : 26,
          color.r.round(),
          color.g.round(),
          color.b.round(),
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color.fromARGB(
            102,
            color.r.round(),
            color.g.round(),
            color.b.round(),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum BodyView { front, back }

class BodyDiagramPainter extends CustomPainter {
  final Set<String> primaryMuscles;
  final Set<String> secondaryMuscles;
  final BodyView view;

  const BodyDiagramPainter({
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.view,
  });

  bool _isPrimary(String muscle) =>
      primaryMuscles.contains(muscle.toLowerCase());

  bool _isSecondary(String muscle) =>
      secondaryMuscles.contains(muscle.toLowerCase());

  // Electric Lime for primary, darker lime for secondary, surfaceVariant for inactive
  Paint _fill(String muscle) {
    if (_isPrimary(muscle)) {
      return Paint()
        ..color =
            const Color(0xCCC6FF00) // Lime ~80%
        ..style = PaintingStyle.fill;
    }
    if (_isSecondary(muscle)) {
      return Paint()
        ..color =
            const Color(0xFF527700) // Dark lime
        ..style = PaintingStyle.fill;
    }
    return Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.fill;
  }

  Paint get _stroke => Paint()
    ..color = AppColors.outline
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7;

  Paint get _base => Paint()
    ..color = AppColors.surfaceVariant
    ..style = PaintingStyle.fill;

  Paint get _baseStroke => Paint()
    ..color = AppColors.outline
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7;

  void _oval(Canvas c, double l, double t, double r, double b, Paint p) =>
      c.drawOval(Rect.fromLTRB(l, t, r, b), p);

  void _rr(
    Canvas c,
    double l,
    double t,
    double r,
    double b,
    double radius,
    Paint p,
  ) => c.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTRB(l, t, r, b), Radius.circular(radius)),
    p,
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    const double refW = 100.0;
    const double refH = 330.0;
    final scaleX = size.width / refW;
    final scaleY = size.height / refH;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    canvas.translate(
      (size.width - refW * scale) / 2,
      (size.height - refH * scale) / 2,
    );
    canvas.scale(scale);

    if (view == BodyView.front) {
      _drawFront(canvas);
    } else {
      _drawBack(canvas);
    }
    canvas.restore();
  }

  void _drawFront(Canvas canvas) {
    // ── Base silhouette ────────────────────────────────────────────────────
    _oval(canvas, 3, 58, 31, 155, _base);
    _oval(canvas, 69, 58, 97, 155, _base);
    _rr(canvas, 28, 60, 72, 180, 10, _base);
    _rr(canvas, 22, 174, 78, 212, 8, _base);
    _rr(canvas, 22, 208, 50, 260, 7, _base);
    _rr(canvas, 50, 208, 78, 260, 7, _base);
    _rr(canvas, 24, 260, 48, 328, 7, _base);
    _rr(canvas, 52, 260, 76, 328, 7, _base);

    // ── Muscle overlays ────────────────────────────────────────────────────

    // Triceps (outer strip, partially visible from front)
    _oval(canvas, 3, 92, 16, 150, _fill('tricep'));
    _oval(canvas, 3, 92, 16, 150, _stroke);
    _oval(canvas, 84, 92, 97, 150, _fill('tricep'));
    _oval(canvas, 84, 92, 97, 150, _stroke);

    // Biceps
    _oval(canvas, 7, 92, 30, 150, _fill('bicep'));
    _oval(canvas, 7, 92, 30, 150, _stroke);
    _oval(canvas, 70, 92, 93, 150, _fill('bicep'));
    _oval(canvas, 70, 92, 93, 150, _stroke);

    // Shoulders
    _oval(canvas, 8, 58, 38, 92, _fill('shoulders'));
    _oval(canvas, 8, 58, 38, 92, _stroke);
    _oval(canvas, 62, 58, 92, 92, _fill('shoulders'));
    _oval(canvas, 62, 58, 92, 92, _stroke);

    // Chest
    _oval(canvas, 30, 62, 70, 112, _fill('chest'));
    _oval(canvas, 30, 62, 70, 112, _stroke);

    // Abs
    _rr(canvas, 34, 110, 66, 174, 8, _fill('abs'));
    _rr(canvas, 34, 110, 66, 174, 8, _stroke);

    // Hips overlay (neutral)
    _rr(canvas, 22, 174, 78, 212, 8, _base);
    _rr(canvas, 22, 174, 78, 212, 8, _baseStroke);

    // Quads
    _rr(canvas, 23, 209, 49, 262, 6, _fill('legs'));
    _rr(canvas, 23, 209, 49, 262, 6, _stroke);
    _rr(canvas, 51, 209, 77, 262, 6, _fill('legs'));
    _rr(canvas, 51, 209, 77, 262, 6, _stroke);

    // Calves
    _rr(canvas, 25, 264, 47, 326, 6, _fill('legs'));
    _rr(canvas, 25, 264, 47, 326, 6, _stroke);
    _rr(canvas, 53, 264, 75, 326, 6, _fill('legs'));
    _rr(canvas, 53, 264, 75, 326, 6, _stroke);

    // Forearms (neutral)
    _oval(canvas, 3, 150, 25, 210, _base);
    _oval(canvas, 3, 150, 25, 210, _baseStroke);
    _oval(canvas, 75, 150, 97, 210, _base);
    _oval(canvas, 75, 150, 97, 210, _baseStroke);

    // Upper arm outlines
    _oval(canvas, 3, 58, 31, 155, _baseStroke);
    _oval(canvas, 69, 58, 97, 155, _baseStroke);

    // Head
    _oval(canvas, 34, 0, 66, 48, _base);
    _oval(canvas, 34, 0, 66, 48, _baseStroke);

    // Neck
    _rr(canvas, 44, 44, 56, 64, 4, _base);
    _rr(canvas, 44, 44, 56, 64, 4, _baseStroke);
  }

  void _drawBack(Canvas canvas) {
    // ── Base silhouette ────────────────────────────────────────────────────
    _oval(canvas, 3, 58, 31, 155, _base);
    _oval(canvas, 69, 58, 97, 155, _base);
    _rr(canvas, 28, 60, 72, 180, 10, _base);
    _rr(canvas, 22, 174, 78, 212, 8, _base);
    _rr(canvas, 22, 208, 50, 260, 7, _base);
    _rr(canvas, 50, 208, 78, 260, 7, _base);
    _rr(canvas, 24, 260, 48, 328, 7, _base);
    _rr(canvas, 52, 260, 76, 328, 7, _base);

    // ── Muscle overlays ────────────────────────────────────────────────────

    // Biceps (small strip visible from back)
    _oval(canvas, 3, 92, 13, 150, _fill('bicep'));
    _oval(canvas, 3, 92, 13, 150, _stroke);
    _oval(canvas, 87, 92, 97, 150, _fill('bicep'));
    _oval(canvas, 87, 92, 97, 150, _stroke);

    // Triceps (dominant from back)
    _oval(canvas, 6, 90, 32, 152, _fill('tricep'));
    _oval(canvas, 6, 90, 32, 152, _stroke);
    _oval(canvas, 68, 90, 94, 152, _fill('tricep'));
    _oval(canvas, 68, 90, 94, 152, _stroke);

    // Shoulders (rear delt)
    _oval(canvas, 8, 56, 38, 90, _fill('shoulders'));
    _oval(canvas, 8, 56, 38, 90, _stroke);
    _oval(canvas, 62, 56, 92, 90, _fill('shoulders'));
    _oval(canvas, 62, 56, 92, 90, _stroke);

    // Trapezius
    _rr(canvas, 30, 60, 70, 96, 8, _fill('back'));
    _rr(canvas, 30, 60, 70, 96, 8, _stroke);

    // Lats
    _oval(canvas, 28, 94, 72, 178, _fill('back'));
    _oval(canvas, 28, 94, 72, 178, _stroke);

    // Glutes
    _oval(canvas, 24, 176, 76, 214, _fill('legs'));
    _oval(canvas, 24, 176, 76, 214, _stroke);

    // Hamstrings
    _rr(canvas, 23, 209, 49, 262, 6, _fill('legs'));
    _rr(canvas, 23, 209, 49, 262, 6, _stroke);
    _rr(canvas, 51, 209, 77, 262, 6, _fill('legs'));
    _rr(canvas, 51, 209, 77, 262, 6, _stroke);

    // Calves
    _rr(canvas, 25, 264, 47, 326, 6, _fill('legs'));
    _rr(canvas, 25, 264, 47, 326, 6, _stroke);
    _rr(canvas, 53, 264, 75, 326, 6, _fill('legs'));
    _rr(canvas, 53, 264, 75, 326, 6, _stroke);

    // Forearms (neutral)
    _oval(canvas, 3, 150, 25, 210, _base);
    _oval(canvas, 3, 150, 25, 210, _baseStroke);
    _oval(canvas, 75, 150, 97, 210, _base);
    _oval(canvas, 75, 150, 97, 210, _baseStroke);

    // Upper arm outlines
    _oval(canvas, 3, 58, 31, 155, _baseStroke);
    _oval(canvas, 69, 58, 97, 155, _baseStroke);

    // Head
    _oval(canvas, 34, 0, 66, 48, _base);
    _oval(canvas, 34, 0, 66, 48, _baseStroke);

    // Neck
    _rr(canvas, 44, 44, 56, 64, 4, _base);
    _rr(canvas, 44, 44, 56, 64, 4, _baseStroke);
  }

  @override
  bool shouldRepaint(covariant BodyDiagramPainter oldDelegate) =>
      oldDelegate.primaryMuscles != primaryMuscles ||
      oldDelegate.secondaryMuscles != secondaryMuscles ||
      oldDelegate.view != view;
}
