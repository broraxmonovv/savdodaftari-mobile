/// Savdo dinamikasi nuqtasi (`GET /reports/daily`): kun, hafta yoki oy bo'yicha yig'indi.
class TrendPoint {
  const TrendPoint({
    required this.date,
    required this.dateTo,
    required this.salesCount,
    required this.revenue,
    required this.grossProfit,
    required this.expenses,
    required this.netProfit,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    double num0(String key) =>
        double.tryParse(json[key]?.toString() ?? '') ?? 0;
    final DateTime date = DateTime.tryParse(json['date']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return TrendPoint(
      date: date,
      dateTo: DateTime.tryParse(json['date_to']?.toString() ?? '') ?? date,
      salesCount: int.tryParse(json['sales_count']?.toString() ?? '') ?? 0,
      revenue: num0('revenue'),
      grossProfit: num0('gross_profit'),
      expenses: num0('expenses'),
      netProfit: num0('net_profit'),
    );
  }

  /// Davr boshi (kunlik nuqtada kunning o'zi) va oxiri.
  final DateTime date;
  final DateTime dateTo;
  final int salesCount;
  final double revenue;
  final double grossProfit;
  final double expenses;
  final double netProfit;

  double valueOf(TrendMetric metric) => switch (metric) {
        TrendMetric.sales => revenue,
        TrendMetric.profit => netProfit,
        TrendMetric.expenses => expenses,
      };
}

/// Grafikda ko'rsatiladigan ko'rsatkich.
enum TrendMetric { sales, profit, expenses }

/// Grafik oralig'i: haftalik (7 kun), oylik (30 kun) yoki butun davr.
enum TrendRange {
  weekly('week'),
  monthly('month'),
  all('all');

  const TrendRange(this.period);

  /// Backend `period` parametri.
  final String period;

  /// 30 kun va butun davr faqat Pro tarifda.
  bool get requiresPro => this != TrendRange.weekly;
}

class TrendSeries {
  const TrendSeries({required this.group, required this.points});

  factory TrendSeries.fromJson(Map<String, dynamic> json) {
    final Object? days = json['days'];
    return TrendSeries(
      group: json['group']?.toString() ?? 'day',
      points: days is List
          ? days
              .whereType<Map<dynamic, dynamic>>()
              .map((Map<dynamic, dynamic> it) =>
                  TrendPoint.fromJson(Map<String, dynamic>.from(it)))
              .toList()
          : <TrendPoint>[],
    );
  }

  /// `day`, `week` yoki `month`.
  final String group;
  final List<TrendPoint> points;

  List<double> values(TrendMetric metric) =>
      points.map((TrendPoint p) => p.valueOf(metric)).toList();

  bool hasData(TrendMetric metric) =>
      points.any((TrendPoint p) => p.valueOf(metric) != 0);
}

/// Yig'indi, o'rtacha, eng yaxshi davr va tendensiya (ikkinchi yarim / birinchi yarim).
class TrendSummary {
  const TrendSummary({
    required this.total,
    required this.average,
    required this.best,
    required this.bestIndex,
    required this.changePercent,
  });

  factory TrendSummary.of(List<double> values) {
    if (values.isEmpty) {
      return const TrendSummary(
        total: 0,
        average: 0,
        best: 0,
        bestIndex: -1,
        changePercent: null,
      );
    }
    final double total = values.fold(0, (double a, double b) => a + b);
    int bestIndex = 0;
    for (int i = 1; i < values.length; i++) {
      if (values[i] > values[bestIndex]) {
        bestIndex = i;
      }
    }

    double? change;
    if (values.length >= 2) {
      final int mid = values.length ~/ 2;
      final double first =
          values.sublist(0, mid).fold(0, (double a, double b) => a + b);
      final double second = values
          .sublist(values.length - mid)
          .fold(0, (double a, double b) => a + b);
      if (first.abs() > 0.0001) {
        change = (second - first) / first.abs() * 100;
      } else if (second > 0) {
        change = 100;
      }
    }

    return TrendSummary(
      total: total,
      average: total / values.length,
      best: values[bestIndex],
      bestIndex: bestIndex,
      changePercent: change,
    );
  }

  final double total;
  final double average;
  final double best;
  final int bestIndex;

  /// Davrning ikkinchi yarmi birinchisiga nisbatan o'zgarishi (%); hisoblab bo'lmasa null.
  final double? changePercent;

  /// Eng kichik kvadratlar usulida to'g'ri chiziq (tendensiya) uchun: y = a + b*x.
  static (double, double) regression(List<double> values) {
    final int n = values.length;
    if (n < 2) {
      return (values.isEmpty ? 0 : values.first, 0);
    }
    double sx = 0, sy = 0, sxy = 0, sxx = 0;
    for (int i = 0; i < n; i++) {
      sx += i;
      sy += values[i];
      sxy += i * values[i];
      sxx += i * i;
    }
    final double denom = n * sxx - sx * sx;
    final double b = denom == 0 ? 0 : (n * sxy - sx * sy) / denom;
    final double a = (sy - b * sx) / n;
    return (a, b);
  }
}
