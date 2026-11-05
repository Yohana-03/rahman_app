import 'dart:math' as math;

import 'package:finalrahman/core/mark_scale.dart';
import 'package:finalrahman/core/theme/app_theme.dart';
import 'package:finalrahman/features/portal/result_report.dart';
import 'package:finalrahman/ui/widgets/common.dart';
import 'package:flutter/material.dart';

class SubjectMarkChart extends StatelessWidget {
  const SubjectMarkChart({
    super.key,
    required this.subjects,
    required this.scale,
  });

  final List<SubjectScore> subjects;
  final int scale;

  @override
  Widget build(BuildContext context) {
    const axisWidth = 28.0;
    const labelHeight = 52.0;
    const plotHeight = 132.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: plotHeight + labelHeight,
          width: width,
          child: CustomPaint(
            size: Size(width, plotHeight + labelHeight),
            painter: _SubjectChartPainter(
              subjects: subjects,
              scale: scale,
              axisWidth: axisWidth,
              labelHeight: labelHeight,
              barColor: AppColors.brand,
              gridColor: portalBorder(context),
              labelColor: portalMuted(context),
            ),
          ),
        );
      },
    );
  }
}

class _SubjectChartPainter extends CustomPainter {
  const _SubjectChartPainter({
    required this.subjects,
    required this.scale,
    required this.axisWidth,
    required this.labelHeight,
    required this.barColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<SubjectScore> subjects;
  final int scale;
  final double axisWidth;
  final double labelHeight;
  final Color barColor;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    final plotTop = 10.0;
    final plotBottom = size.height - labelHeight;
    final plotLeft = axisWidth;
    final plotRight = size.width - 4;
    final plotHeight = plotBottom - plotTop;

    void grid(double fraction, String label) {
      final y = plotBottom - plotHeight * fraction;
      canvas.drawLine(
        Offset(plotLeft, y),
        Offset(plotRight, y),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1,
      );
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: labelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(plotLeft - painter.width - 6, y - painter.height / 2));
    }

    grid(1, '$scale');
    grid(0.5, '${scale ~/ 2}');
    grid(0, '0');

    if (subjects.isEmpty) return;
    final slot = (plotRight - plotLeft) / subjects.length;
    final barWidth = math.min(12.0, slot * 0.46);
    for (var index = 0; index < subjects.length; index++) {
      final subject = subjects[index];
      final fraction = markFraction(subject.score, scale);
      final x = plotLeft + slot * index + slot / 2;
      final barHeight = math.max(plotHeight * fraction, fraction == 0 ? 0.0 : 2.0);
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x - barWidth / 2, plotBottom - barHeight, barWidth, barHeight),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(rect, Paint()..color = barColor);

      final painter = TextPainter(
        text: TextSpan(
          text: subject.name,
          style: TextStyle(color: labelColor, fontSize: slot < 40 ? 8 : 9),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: math.max(slot * 1.15, 18));
      canvas.save();
      canvas.translate(x, plotBottom + 10);
      canvas.rotate(0.65);
      painter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SubjectChartPainter oldDelegate) {
    return oldDelegate.subjects != subjects ||
        oldDelegate.scale != scale ||
        oldDelegate.barColor != barColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor;
  }
}
