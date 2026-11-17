import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Small dependency-free line chart. Tap or drag to select a point.
class RateChart extends StatelessWidget {
  const RateChart({
    super.key,
    required this.values,
    required this.minLabel,
    required this.maxLabel,
    this.selectedIndex,
    this.onSelect,
  });

  /// Oldest first; at least two values are needed to draw something.
  final List<double> values;
  final String minLabel;
  final String maxLabel;
  final int? selectedIndex;
  final ValueChanged<int>? onSelect;

  int _indexAt(double dx, double width) {
    if (values.length < 2 || width <= 0) return 0;
    final index = (dx / width * (values.length - 1)).round();
    return index.clamp(0, values.length - 1).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => onSelect?.call(_indexAt(d.localPosition.dx, width)),
          onHorizontalDragUpdate: (d) =>
              onSelect?.call(_indexAt(d.localPosition.dx, width)),
          child: CustomPaint(
            size: Size(width, constraints.maxHeight),
            painter: _ChartPainter(
              values: values,
              minLabel: minLabel,
              maxLabel: maxLabel,
              selectedIndex: selectedIndex,
              lineColor: theme.colorScheme.primary,
              gridColor: theme.colorScheme.outlineVariant,
              labelStyle: (theme.textTheme.labelSmall ?? const TextStyle())
                  .copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.values,
    required this.minLabel,
    required this.maxLabel,
    required this.selectedIndex,
    required this.lineColor,
    required this.gridColor,
    required this.labelStyle,
  });

  final List<double> values;
  final String minLabel;
  final String maxLabel;
  final int? selectedIndex;
  final Color lineColor;
  final Color gridColor;
  final TextStyle labelStyle;

  static const _labelBand = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0 || size.height <= 0) return;

    var low = values.first;
    var high = values.first;
    for (final v in values) {
      if (v < low) low = v;
      if (v > high) high = v;
    }
    var span = high - low;
    if (span <= 0) {
      // Flat line: give it some room so it sits in the middle.
      span = high.abs() > 0 ? high.abs() * 0.02 : 1;
      low -= span / 2;
      high += span / 2;
      span = high - low;
    }

    const top = _labelBand;
    final bottom = size.height - _labelBand;
    final plotHeight = bottom - top;
    if (plotHeight <= 0) return;

    double x(int i) => i / (values.length - 1) * size.width;
    double y(double v) => top + (1 - (v - low) / span) * plotHeight;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, top), Offset(size.width, top), gridPaint);
    canvas.drawLine(Offset(0, bottom), Offset(size.width, bottom), gridPaint);

    final line = Path()..moveTo(x(0), y(values[0]));
    for (var i = 1; i < values.length; i++) {
      line.lineTo(x(i), y(values[i]));
    }

    final area = Path.from(line)
      ..lineTo(size.width, bottom)
      ..lineTo(0, bottom)
      ..close();
    canvas.drawPath(area, Paint()..color = lineColor.withAlpha(36));

    canvas.drawPath(
      line,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    final selected = selectedIndex;
    if (selected != null && selected >= 0 && selected < values.length) {
      final point = Offset(x(selected), y(values[selected]));
      canvas.drawLine(
        Offset(point.dx, top),
        Offset(point.dx, bottom),
        Paint()
          ..color = lineColor.withAlpha(120)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(point, 4.5, Paint()..color = lineColor);
    }

    _paintLabel(canvas, maxLabel, const Offset(0, 0));
    _paintLabel(canvas, minLabel, Offset(0, bottom + 3));
  }

  void _paintLabel(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.values != values ||
      old.selectedIndex != selectedIndex ||
      old.minLabel != minLabel ||
      old.maxLabel != maxLabel ||
      old.lineColor != lineColor ||
      old.gridColor != gridColor ||
      old.labelStyle != labelStyle;
}
