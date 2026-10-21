import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/widgets.dart';
import '../auth/state/auth_providers.dart';
import '../billing/pro_upsell.dart';
import 'data/trend_models.dart';
import 'state/trend_providers.dart';
import 'trend_chart.dart';

/// Hisobotdagi "Savdo dinamikasi" kartasi: haftalik / oylik / butun davr diagrammasi, ko'rsatkich
/// tanlovi (savdo, sof foyda, xarajat), yig'indi, o'rtacha, eng yaxshi davr va tendensiya.
class TrendSection extends ConsumerStatefulWidget {
  const TrendSection({super.key});

  @override
  ConsumerState<TrendSection> createState() => _TrendSectionState();
}

class _TrendSectionState extends ConsumerState<TrendSection> {
  TrendRange _range = TrendRange.weekly;
  TrendMetric _metric = TrendMetric.sales;

  void _selectRange(TrendRange range) {
    final bool isPro = ref.read(authControllerProvider).user?.isPro ?? false;
    if (range.requiresPro && !isPro) {
      final AppStrings s = context.s;
      showProUpsell(
        context,
        ref,
        title: s.voiceProTitle,
        body: s.reportsProRequired,
        icon: Icons.show_chart_rounded,
      );
      return;
    }
    setState(() => _range = range);
  }

  String _metricLabel(AppStrings s, TrendMetric m) => switch (m) {
        TrendMetric.sales => s.trendMetricSales,
        TrendMetric.profit => s.trendMetricProfit,
        TrendMetric.expenses => s.trendMetricExpenses,
      };

  String _rangeLabel(AppStrings s, TrendRange r) => switch (r) {
        TrendRange.weekly => s.trendWeekly,
        TrendRange.monthly => s.trendMonthly,
        TrendRange.all => s.trendAll,
      };

  String _groupLabel(AppStrings s, String group) => switch (group) {
        'week' => s.trendGroupWeek,
        'month' => s.trendGroupMonth,
        _ => s.trendGroupDay,
      };

  String _money(AppStrings s, double v) {
    final String digits = v.abs().round().toString();
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        out.write(' ');
      }
      out.write(digits[i]);
    }
    return '${v < 0 ? '−' : ''}$out';
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isPro = ref.watch(authControllerProvider).user?.isPro ?? false;
    final AsyncValue<TrendSeries> series = ref.watch(trendProvider(_range));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.show_chart_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(s.trendTitle, style: textTheme.titleSmall)),
              series.maybeWhen(
                data: (TrendSeries d) => Text(
                  _groupLabel(s, d.group),
                  style: textTheme.labelSmall,
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Oraliq: haftalik / oylik / butun davr (oxirgi ikkisi Pro)
          Row(
            children: <Widget>[
              for (final TrendRange r in TrendRange.values) ...<Widget>[
                Expanded(
                  child: _Pill(
                    label: _rangeLabel(s, r),
                    selected: r == _range,
                    locked: r.requiresPro && !isPro,
                    onTap: () => _selectRange(r),
                  ),
                ),
                if (r != TrendRange.values.last)
                  const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Ko'rsatkich
          Wrap(
            spacing: AppSpacing.sm,
            children: <Widget>[
              for (final TrendMetric m in TrendMetric.values)
                ChoiceChip(
                  label: Text(_metricLabel(s, m)),
                  selected: m == _metric,
                  onSelected: (_) => setState(() => _metric = m),
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                  selectedColor: AppColors.lightGreen,
                  labelStyle: textTheme.labelMedium?.copyWith(
                    color: m == _metric
                        ? AppColors.darkGreen
                        : AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          series.when(
            loading: () => const SkeletonShimmer(
              child: Column(
                children: <Widget>[
                  SkeletonBox(height: 52, radius: 12),
                  SizedBox(height: AppSpacing.md),
                  SkeletonBox(height: 190, radius: 12),
                ],
              ),
            ),
            error: (Object error, StackTrace _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                children: <Widget>[
                  Text(
                    error is ApiException
                        ? apiErrorText(s, error)
                        : s.errorUnknown,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(trendProvider(_range)),
                    child: Text(s.retry),
                  ),
                ],
              ),
            ),
            data: (TrendSeries d) {
              if (!d.hasData(_metric)) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.insert_chart_outlined_rounded,
                            size: 36, color: AppColors.border),
                        const SizedBox(height: AppSpacing.sm),
                        Text(s.trendEmpty, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                );
              }

              final List<double> values = d.values(_metric);
              final TrendSummary sum = TrendSummary.of(values);
              final double? change = sum.changePercent;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _Stat(label: s.trendTotal, value: _money(s, sum.total)),
                      _Stat(
                          label: s.trendAverage, value: _money(s, sum.average)),
                      _Stat(label: s.trendBest, value: _money(s, sum.best)),
                    ],
                  ),
                  if (change != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.sm),
                    _ChangeBadge(
                        percent: change, up: s.trendUp, down: s.trendDown),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  TrendChart(points: d.points, metric: _metric, group: d.group),
                  const SizedBox(height: AppSpacing.sm),
                  Text(s.trendHint, style: textTheme.labelSmall),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Material(
      color: selected ? AppColors.primary : AppColors.background,
      borderRadius: AppRadius.pill,
      child: InkWell(
        borderRadius: AppRadius.pill,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
              if (locked) ...<Widget>[
                const SizedBox(width: 4),
                Icon(Icons.lock_rounded,
                    size: 13, color: AppColors.textSecondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: textTheme.labelSmall),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge(
      {required this.percent, required this.up, required this.down});

  final double percent;
  final String up;
  final String down;

  @override
  Widget build(BuildContext context) {
    final bool positive = percent >= 0;
    final Color color = positive ? AppColors.primary : AppColors.danger;
    final String value = percent.abs() >= 1000
        ? '999+'
        : percent.abs().toStringAsFixed(percent.abs() < 10 ? 1 : 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            '${positive ? '+' : '−'}$value% · ${positive ? up : down}',
            style:
                Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
