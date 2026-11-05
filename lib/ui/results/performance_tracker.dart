import 'package:finalrahman/features/portal/result_report.dart';
import 'package:finalrahman/ui/widgets/common.dart';
import 'package:flutter/material.dart';

class TrackerPoint {
  const TrackerPoint({
    required this.month,
    required this.average,
    required this.published,
  });

  final int month;
  final double average;
  final DateTime published;
}

List<TrackerPoint> trackerPoints(List<ExaminationResult> exams) {
  final byMonth = <int, TrackerPoint>{};
  for (final exam in exams) {
    final published = DateTime.tryParse(exam.publishedAt ?? '')?.toLocal();
    if (published == null) continue;
    final current = byMonth[published.month];
    if (current != null && !published.isAfter(current.published)) continue;
    byMonth[published.month] = TrackerPoint(
      month: published.month,
      average: exam.average,
      published: published,
    );
  }
  final points = byMonth.values.toList()
    ..sort((a, b) => a.month.compareTo(b.month));
  return points;
}

class PerformanceTracker extends StatelessWidget {
  const PerformanceTracker({
    super.key,
    required this.points,
    required this.scale,
  });

  final List<TrackerPoint> points;
  final int scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
      decoration: portalCard(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _trackerPurple,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Student average',
                style: TextStyle(fontSize: 11, color: portalMuted(context)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 188,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrackerPainter(
                points: points,
                scale: scale,
                gridColor: portalBorder(context),
                labelColor: portalMuted(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _trackerPurple = Color(0xFF7C3AED);

class _TrackerPainter extends CustomPainter {
  const _TrackerPainter({
    required this.points,
    required this.scale,
    required this.gridColor,
    required this.labelColor,
  });

  final List<TrackerPoint> points;
  final int scale;
  final Color gridColor;
  final Color labelColor;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const axisWidth = 28.0;
    const labelHeight = 22.0;
    final plotLeft = axisWidth;
    final plotRight = size.width;
    final plotTop = 8.0;
    final plotBottom = size.height - labelHeight;
    final plotHeight = plotBottom - plotTop;
    final step = scale <= 50 ? 10 : 20;

    for (var mark = 0; mark <= scale; mark += step) {
      final fraction = mark / scale;
      final y = plotBottom - plotHeight * fraction;
      _dashedLine(
        canvas,
        Offset(plotLeft, y),
        Offset(plotRight, y),
        gridColor,
      );
      final painter = TextPainter(
        text: TextSpan(
          text: '$mark',
          style: TextStyle(color: labelColor, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(plotLeft - painter.width - 4, y - painter.height / 2),
      );
    }

    final slot = (plotRight - plotLeft) / _months.length;
    for (var index = 0; index < _months.length; index++) {
      final painter = TextPainter(
        text: TextSpan(
          text: _months[index],
          style: TextStyle(color: labelColor, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(
          plotLeft + slot * index + (slot - painter.width) / 2,
          plotBottom + 6,
        ),
      );
    }

    final offsets = <Offset>[];
    for (final point in points) {
      final monthIndex = point.month - 1;
      if (monthIndex < 0 || monthIndex > 11) continue;
      final x = plotLeft + slot * monthIndex + slot / 2;
      final fraction = (point.average / scale).clamp(0.0, 1.0);
      final y = plotBottom - plotHeight * fraction;
      offsets.add(Offset(x, y));
      canvas.drawLine(
        Offset(x, plotBottom),
        Offset(x, y),
        Paint()
          ..color = _trackerPurple
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    if (offsets.length > 1) {
      final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (final offset in offsets.skip(1)) {
        path.lineTo(offset.dx, offset.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = _trackerPurple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final offset in offsets) {
      canvas.drawCircle(offset, 3.5, Paint()..color = _trackerPurple);
    }
  }

  void _dashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    const dash = 3.0;
    const gap = 3.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final length = (end - start).distance;
    final direction = (end - start) / length;
    var traveled = 0.0;
    while (traveled < length) {
      final next = (traveled + dash).clamp(0.0, length);
      canvas.drawLine(start + direction * traveled, start + direction * next, paint);
      traveled += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _TrackerPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.scale != scale ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor;
  }
}
