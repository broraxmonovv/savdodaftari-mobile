import 'package:bozorpro/core/l10n/app_strings.dart';
import 'package:bozorpro/core/theme/app_colors.dart';
import 'package:bozorpro/core/theme/app_theme.dart';
import 'package:bozorpro/features/reports/data/trend_models.dart';
import 'package:bozorpro/features/reports/state/trend_providers.dart';
import 'package:bozorpro/features/reports/trend_chart.dart';
import 'package:bozorpro/features/reports/trend_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

TrendSeries _series(String group, List<double> revenue) => TrendSeries(
      group: group,
      points: <TrendPoint>[
        for (int i = 0; i < revenue.length; i++)
          TrendPoint(
            date: DateTime(2026, 10, 1).add(Duration(days: i)),
            dateTo: DateTime(2026, 10, 1).add(Duration(days: i)),
            salesCount: 1,
            revenue: revenue[i],
            grossProfit: revenue[i] * 0.3,
            expenses: revenue[i] * 0.1,
            netProfit: revenue[i] * 0.2,
          ),
      ],
    );

Widget _app(Widget child, {List<Override> overrides = const <Override>[], String key = 'uz'}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('uz'),
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: <LocalizationsDelegate<Object>>[
        AppStringsDelegate(key: key),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.build(),
      home: Scaffold(body: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(16), child: child))),
    ),
  );
}

void main() {
  test('trend summary: total, average, best and change', () {
    final TrendSummary s = TrendSummary.of(<double>[100, 100, 200, 300]);
    expect(s.total, 700);
    expect(s.average, 175);
    expect(s.best, 300);
    expect(s.bestIndex, 3);
    expect(s.changePercent, closeTo(150, 0.01)); // (200+300) vs (100+100)

    expect(TrendSummary.of(<double>[]).changePercent, isNull);
    expect(TrendSummary.of(<double>[0, 0, 50, 50]).changePercent, 100);
    expect(TrendSummary.of(<double>[300, 300, 100, 100]).changePercent, closeTo(-66.67, 0.01));
  });

  test('regression gives the slope of a rising series', () {
    final (double a, double b) = TrendSummary.regression(<double>[10, 20, 30, 40]);
    expect(b, closeTo(10, 1e-9));
    expect(a, closeTo(10, 1e-9));
    expect(TrendSummary.regression(<double>[5]).$2, 0);
  });

  test('TrendSeries parses backend json with grouping', () {
    final TrendSeries t = TrendSeries.fromJson(<String, dynamic>{
      'group': 'week',
      'days': <Map<String, dynamic>>[
        <String, dynamic>{'date': '2026-10-05', 'date_to': '2026-10-11', 'sales_count': 3, 'revenue': 150000, 'gross_profit': 40000, 'expenses': 10000, 'net_profit': 30000},
      ],
    });
    expect(t.group, 'week');
    expect(t.points.single.valueOf(TrendMetric.sales), 150000);
    expect(t.points.single.valueOf(TrendMetric.profit), 30000);
    expect(t.points.single.dateTo.day, 11);
    expect(t.hasData(TrendMetric.expenses), isTrue);
  });

  testWidgets('chart paints bars, supports tap selection and negative values', (WidgetTester tester) async {
    AppColors.apply(Brightness.light);
    await tester.binding.setSurfaceSize(const Size(380, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final TrendSeries data = _series('day', <double>[120000, 0, 340000, -50000, 210000, 90000, 400000]);
    await tester.pumpWidget(_app(TrendChart(points: data.points, metric: TrendMetric.sales, group: 'day')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tapAt(tester.getCenter(find.byType(TrendChart)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('section shows chart, switches metric and offers Pro for month/all', (WidgetTester tester) async {
    AppColors.apply(Brightness.light);
    await tester.binding.setSurfaceSize(const Size(380, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app(
      const TrendSection(),
      overrides: <Override>[
        trendProvider.overrideWith((Ref ref, TrendRange r) async =>
            _series('day', <double>[100000, 150000, 120000, 300000, 280000, 350000, 400000])),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Savdo dinamikasi'), findsOneWidget);
    expect(find.text('Haftalik'), findsOneWidget);
    expect(find.text('Oylik'), findsOneWidget);
    expect(find.text('Butun davr'), findsOneWidget);
    expect(find.byType(TrendChart), findsOneWidget);
    expect(find.textContaining('tendensiya'), findsWidgets); // izoh yoki o'sish belgisi

    await tester.tap(find.text('Sof foyda'));
    await tester.pumpAndSettle();
    expect(find.byType(TrendChart), findsOneWidget);

    // Pro bo'lmagan foydalanuvchi uchun Oylik — Pro taklifi oynasi
    await tester.tap(find.text('Oylik'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('section is available in Cyrillic and Russian', (WidgetTester tester) async {
    AppColors.apply(Brightness.light);
    await tester.binding.setSurfaceSize(const Size(380, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final (String key, String title) in <(String, String)>[('uz_cyrl', 'Савдо динамикаси'), ('ru', 'Динамика продаж')]) {
      await tester.pumpWidget(_app(
        const TrendSection(),
        key: key,
        overrides: <Override>[
          trendProvider.overrideWith((Ref ref, TrendRange r) async => _series('week', <double>[1, 2, 3, 4])),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget, reason: key);
    }
  });
}
