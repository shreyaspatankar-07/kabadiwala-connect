import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Lightweight, self-contained 30-day sparkline chart widget for offline prices.
/// Zero external chart dependencies (preserves the <25 MB APK budget).
class SparklineChart extends StatelessWidget {
  const SparklineChart({
    super.key,
    required this.dataPoints,
    this.height = 110,
    this.lineColor = AppTheme.greenGoEarn,
    this.fillGradient,
    this.showMinMaxLabels = true,
  });

  final List<double> dataPoints;
  final double height;
  final Color lineColor;
  final LinearGradient? fillGradient;
  final bool showMinMaxLabels;

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('माहिती उपलब्ध नाही (No Data)'),
        ),
      );
    }

    final minVal = dataPoints.reduce(math.min);
    final maxVal = dataPoints.reduce(math.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: CustomPaint(
            painter: _SparklinePainter(
              data: dataPoints,
              lineColor: lineColor,
              fillColor: lineColor.withValues(alpha: 0.15),
            ),
          ),
        ),
        if (showMinMaxLabels) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '३० दिवस किमान: ₹ ${minVal.round()}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                ),
              ),
              Text(
                '३० दिवस कमाल: ₹ ${maxVal.round()}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
  });

  final List<double> data;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minVal = data.reduce(math.min);
    final maxVal = data.reduce(math.max);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    final fillPath = Path();

    final dx = size.width / (data.length - 1);
    const paddingTop = 8.0;
    const paddingBottom = 8.0;
    final usableHeight = size.height - paddingTop - paddingBottom;

    double getY(double val) {
      final normalized = (val - minVal) / range;
      return size.height - paddingBottom - (normalized * usableHeight);
    }

    final startY = getY(data[0]);
    path.moveTo(0, startY);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, startY);

    for (var i = 1; i < data.length; i++) {
      final x = i * dx;
      final y = getY(data[i]);
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // 1. Draw gradient fill underneath
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          fillColor,
          fillColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // 2. Draw sparkline line
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // 3. Draw latest point indicator
    final lastX = size.width;
    final lastY = getY(data.last);
    final dotPaint = Paint()..color = lineColor;
    canvas.drawCircle(Offset(lastX, lastY), 5.0, dotPaint);

    final outerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(lastX, lastY), 5.0, outerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.lineColor != lineColor;
  }
}
