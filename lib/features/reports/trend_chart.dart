import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import 'data/trend_models.dart';

/// Ustunli diagramma + tendensiya chizig'i. Ustunga bosilsa (yoki barmoq bilan surilsa) o'sha davr
/// qiymati ko'rinadi. Manfiy qiymatlar (zarar) nol chizig'idan pastga, qizil rangda chiziladi.
class TrendChart extends StatefulWidget {
  const TrendChart({
    super.key,
    required this.points,
    required this.metric,
    required this.group,
    this.height = 210,
  });

  final List<TrendPoint> points;
  final TrendMetric metric;

  /// `day`, `week` yoki `month` — o'q yozuvlari shunga qarab.
  final String group;
  final double height;

  @override
  State<TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<TrendChart> {
  int? _selected;

  @override
  void didUpdateWidget(covariant TrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points.length != widget.points.length ||
        oldWidget.metric != widget.metric) {
      _selected = null;
    }
  }

  void _select(Offset local, double width) {
    final int n = widget.points.length;
    if (n == 0) {
      return;
    }
    final double left = _TrendPainter.leftPad;
    final double slot = (width - left) / n;
    final int index = ((local.dx - left) / slot).floor().clamp(0, n - 1);
    setState(() => _selected = index);
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final List<double> values =
        widget.points.map((TrendPoint p) => p.valueOf(widget.metric)).toList();

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (TapDownDetails d) =>
                _select(d.localPosition, box.maxWidth),
            onHorizontalDragUpdate: (DragUpdateDetails d) =>
                _select(d.localPosition, box.maxWidth),
            child: TweenAnimationBuilder<double>(
              key: ValueKey<String>(
                '${widget.metric.name}:${widget.group}:${widget.points.length}:'
                '${values.fold<double>(0, (double a, double b) => a + b)}',
              ),
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double t, Widget? _) {
                return CustomPaint(
                  size: Size(box.maxWidth, widget.height),
                  painter: _TrendPainter(
                    points: widget.points,
                    values: values,
                    group: widget.group,
                    progress: t,
                    selected: _selected,
                    strings: s,
                    barColor: AppColors.primary,
                    negativeColor: AppColors.danger,
                    trendColor: AppColors.warning,
                    gridColor: AppColors.border,
                    labelColor: AppColors.textSecondary,
                    tooltipBackground: AppColors.textPrimary,
                    tooltipText: AppColors.card,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.values,
    required this.group,
    required this.progress,
    required this.selected,
    required this.strings,
    required this.barColor,
    required this.negativeColor,
    required this.trendColor,
    required this.gridColor,
    required this.labelColor,
    required this.tooltipBackground,
    required this.tooltipText,
  });

  static const double leftPad = 46;
  static const double bottomPad = 26;
  static const double topPad = 14;

  final List<TrendPoint> points;
  final List<double> values;
  final String group;
  final double progress;
  final int? selected;
  final AppStrings strings;
  final Color barColor;
  final Color negativeColor;
  final Color trendColor;
  final Color gridColor;
  final Color labelColor;
  final Color tooltipBackground;
  final Color tooltipText;

  /// 1, 2, 2.5, 5 × 10^k ko'rinishidagi "chiroyli" yuqori chegara.
  static double niceCeil(double v) {
    if (v <= 0) {
      return 1;
    }
    final double exp =
        math.pow(10, (math.log(v) / math.ln10).floor()).toDouble();
    final double f = v / exp;
    final double nice = f <= 1
        ? 1
        : f <= 2
            ? 2
            : f <= 2.5
                ? 2.5
                : f <= 5
                    ? 5
                    : 10;
    return nice * exp;
  }

  /// 1 500 000 -> "1,5 mln", 250 000 -> "250 ming".
  String compact(double v) {
    final double a = v.abs();
    String body;
    if (a >= 1000000) {
      final double m = a / 1000000;
      body =
          '${m >= 10 || m == m.roundToDouble() ? m.round() : m.toStringAsFixed(1).replaceAll('.', ',')} ${strings.moneyMillionShort}';
    } else if (a >= 1000) {
      body = '${(a / 1000).round()} ${strings.moneyThousandShort}';
    } else {
      body = a.round().toString();
    }
    return v < 0 ? '−$body' : body;
  }

  String full(double v) {
    final String digits = v.abs().round().toString();
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        out.write(' ');
      }
      out.write(digits[i]);
    }
    return '${v < 0 ? '−' : ''}$out ${strings.currencyShort}';
  }

  String two(int v) => v.toString().padLeft(2, '0');

  String axisLabel(TrendPoint p) {
    if (group == 'month') {
      return strings.dyn(_monthShort(p.date.month));
    }
    return '${two(p.date.day)}.${two(p.date.month)}';
  }

  String _monthShort(int month) {
    final List<String> names = strings.localeCode == 'ru'
        ? <String>[
            'янв',
            'фев',
            'мар',
            'апр',
            'май',
            'июн',
            'июл',
            'авг',
            'сен',
            'окт',
            'ноя',
            'дек'
          ]
        : <String>[
            'yan',
            'fev',
            'mar',
            'apr',
            'may',
            'iyn',
            'iyl',
            'avg',
            'sen',
            'okt',
            'noy',
            'dek'
          ];
    return names[month - 1];
  }

  String rangeLabel(TrendPoint p) {
    if (group == 'month') {
      return '${strings.dyn(_monthShort(p.date.month))} ${p.date.year}';
    }
    if (group == 'week' && p.dateTo != p.date) {
      return '${two(p.date.day)}.${two(p.date.month)} – ${two(p.dateTo.day)}.${two(p.dateTo.month)}';
    }
    return '${two(p.date.day)}.${two(p.date.month)}.${p.date.year}';
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double chartW = size.width - leftPad;
    final double chartH = size.height - bottomPad - topPad;
    if (points.isEmpty || chartW <= 0 || chartH <= 0) {
      return;
    }

    final double maxV = values.fold<double>(0, math.max);
    final double minV = values.fold<double>(0, math.min);
    final double top = niceCeil(maxV);
    final double bottom = minV < 0 ? -niceCeil(-minV) : 0;
    final double range = top - bottom;

    double yOf(double v) => topPad + chartH * (1 - (v - bottom) / range);
    final double zeroY = yOf(0);

    // Gorizontal setka va chap o'q yozuvlari
    final Paint grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final List<double> ticks = <double>[
      bottom,
      if (bottom < 0) 0,
      top / 2,
      top,
    ];
    for (final double tick in ticks.toSet()) {
      final double y = yOf(tick);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), grid);
      _text(canvas, compact(tick), Offset(0, y - 7), 10.5, labelColor,
          maxWidth: leftPad - 6, align: TextAlign.right);
    }

    final int n = points.length;
    final double slot = chartW / n;
    final double barW = math.min(26, math.max(3, slot * 0.64));

    // Ustunlar
    for (int i = 0; i < n; i++) {
      final double v = values[i] * progress;
      final double cx = leftPad + slot * i + slot / 2;
      final double y = yOf(v);
      final bool negative = v < 0;
      final Rect rect = Rect.fromLTRB(
          cx - barW / 2, math.min(y, zeroY), cx + barW / 2, math.max(y, zeroY));
      final bool isSel = selected == i;
      final Paint paint = Paint()
        ..color = (negative ? negativeColor : barColor)
            .withOpacity(selected == null || isSel ? 1 : 0.45);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect.height < 1
              ? Rect.fromLTRB(rect.left, zeroY - 1, rect.right, zeroY)
              : rect,
          topLeft: Radius.circular(math.min(6, barW / 2)),
          topRight: Radius.circular(math.min(6, barW / 2)),
        ),
        paint,
      );
    }

    // Tendensiya chizig'i (eng kichik kvadratlar)
    if (n >= 3) {
      final (double a, double b) = TrendSummary.regression(values);
      final Paint line = Paint()
        ..color = trendColor
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final Path path = Path();
      for (int i = 0; i < n; i++) {
        final double cx = leftPad + slot * i + slot / 2;
        final double y = yOf((a + b * i).clamp(bottom, top) * progress);
        if (i == 0) {
          path.moveTo(cx, y);
        } else {
          path.lineTo(cx, y);
        }
      }
      canvas.drawPath(path, line);
    }

    // Pastki (sana) yozuvlari: boshi, o'rtasi, oxiri (sig'sa ko'proq)
    final int labelCount = math.max(2, math.min(n, (chartW / 62).floor()));
    final Set<int> labelIdx = <int>{
      for (int k = 0; k < labelCount; k++)
        ((n - 1) * k / (labelCount - 1)).round(),
    };
    for (final int i in labelIdx) {
      final double cx = leftPad + slot * i + slot / 2;
      _text(canvas, axisLabel(points[i]),
          Offset(cx - 28, size.height - bottomPad + 7), 10.5, labelColor,
          maxWidth: 56, align: TextAlign.center);
    }

    // Tanlangan ustun tooltip'i
    final int? sel = selected;
    if (sel != null && sel >= 0 && sel < n) {
      final double cx = leftPad + slot * sel + slot / 2;
      final String line1 = rangeLabel(points[sel]);
      final String line2 = full(values[sel]);
      final TextPainter p1 =
          _painter(line1, 11, tooltipText.withOpacity(0.75), FontWeight.w500);
      final TextPainter p2 = _painter(line2, 13, tooltipText, FontWeight.w700);
      final double w = math.max(p1.width, p2.width) + 20;
      final double h = p1.height + p2.height + 14;
      final double barTop = yOf(math.max(values[sel], 0));
      final double x = (cx - w / 2).clamp(leftPad - 8, size.width - w);
      final double y = math.max(0, barTop - h - 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, h), const Radius.circular(10)),
        Paint()..color = tooltipBackground,
      );
      p1.paint(canvas, Offset(x + 10, y + 6));
      p2.paint(canvas, Offset(x + 10, y + 8 + p1.height));
    }
  }

  TextPainter _painter(String text, double size, Color color,
      [FontWeight weight = FontWeight.w400,
      double maxWidth = double.infinity,
      TextAlign align = TextAlign.left]) {
    return TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(fontSize: size, color: color, fontWeight: weight)),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);
  }

  void _text(Canvas canvas, String text, Offset at, double size, Color color,
      {double maxWidth = double.infinity, TextAlign align = TextAlign.left}) {
    final TextPainter p =
        _painter(text, size, color, FontWeight.w400, maxWidth, align);
    final double dx = align == TextAlign.right
        ? at.dx + maxWidth - p.width
        : (align == TextAlign.center
            ? at.dx + (maxWidth - p.width) / 2
            : at.dx);
    p.paint(canvas, Offset(dx, at.dy));
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.progress != progress ||
      old.selected != selected ||
      old.values != values ||
      old.group != group ||
      old.barColor != barColor;
}
