import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A minimal Sunday-first 7-bar chart, hand-painted so no charting
/// dependency is needed for one simple weekly view.
class WeeklyBarChart extends StatelessWidget {
  final List<double> values;
  final Color barColor;
  final double height;

  const WeeklyBarChart({
    super.key,
    required this.values,
    this.barColor = AppColors.purpleMid,
    this.height = 140,
  }) : assert(values.length == 7);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _BarChartPainter(values: values, barColor: barColor),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  static const _labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  final List<double> values;
  final Color barColor;
  _BarChartPainter({required this.values, required this.barColor});

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = values.fold<double>(0, (m, v) => v > m ? v : m);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    const labelAreaHeight = 18.0;
    final chartHeight = size.height - labelAreaHeight;
    const gap = 8.0;
    final barWidth = (size.width - gap * (values.length - 1)) / values.length;

    final labelPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      // Clamp first, then derive top from the *clamped* height — deriving
      // top from the unclamped value here would let the minimum-height
      // "nub" for zero-value days poke below the chart's own baseline.
      final barHeight =
          (chartHeight * (value / safeMax)).clamp(3.0, chartHeight);
      final top = chartHeight - barHeight;
      final left = i * (barWidth + gap);

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = value > 0 ? barColor : barColor.withOpacity(0.15),
      );

      labelPainter.text = TextSpan(
        text: _labels[i],
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(left + (barWidth - labelPainter.width) / 2, chartHeight + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.barColor != barColor;
}
