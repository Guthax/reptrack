import 'package:flutter/material.dart';
import 'package:reptrack/utils/app_theme.dart';

/// Direction the arrow tail points from the bubble.
enum HintArrowDirection { down, up }

/// A styled coach-mark speech bubble with an arrow tail and a dismiss button.
///
/// Place it in a [Column] directly above or below the target widget, or use
/// [Positioned] inside a [Stack]. Call [onDismiss] to hide it.
class HintBubble extends StatelessWidget {
  final String message;
  final HintArrowDirection arrowDirection;
  final VoidCallback onDismiss;

  const HintBubble({
    super.key,
    required this.message,
    required this.arrowDirection,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 14),
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: onDismiss,
          ),
        ],
      ),
    );

    final arrow = CustomPaint(
      size: const Size(16, 8),
      painter: _ArrowPainter(direction: arrowDirection),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: arrowDirection == HintArrowDirection.down
          ? [
              bubble,
              Padding(padding: const EdgeInsets.only(right: 20), child: arrow),
            ]
          : [
              Padding(padding: const EdgeInsets.only(right: 20), child: arrow),
              bubble,
            ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final HintArrowDirection direction;

  const _ArrowPainter({required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    if (direction == HintArrowDirection.down) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0)
        ..close();
    } else {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..close();
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) =>
      oldDelegate.direction != direction;
}
