import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class ScoreRing extends StatelessWidget {
  final double score;       // 0-100
  final double size;
  final String label;
  final String? subLabel;

  const ScoreRing({
    super.key,
    required this.score,
    this.size = 220,
    this.label = 'OVERALL',
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(score);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(score: score.clamp(0, 100) / 100, color: color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: size * 0.055,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                score.round().toString(),
                style: TextStyle(
                  fontSize: size * 0.34,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.0,
                ),
              ),
              if (subLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  subLabel!,
                  style: TextStyle(
                    fontSize: size * 0.06,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double score; // 0..1
  final Color color;
  _RingPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = size.width * 0.09;
    final rect = Rect.fromCircle(
      center: center, radius: size.width / 2 - stroke / 2);

    final bg = Paint()
      ..color = AppColors.border
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, size.width / 2 - stroke / 2, bg);

    final fg = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [color.withValues(alpha: 0.75), color],
      ).createShader(rect)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * score, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.score != score || old.color != color;
}
