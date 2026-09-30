import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/widgets.dart';
import 'data/extras_models.dart';
import 'state/extras_providers.dart';

/// Valyuta kurslari — O'zbekiston Markaziy banki (cbu.uz) rasmiy kurslari.
/// Backend kurslarni soatiga yangilab turadi; ekran ochiq turganda ham
/// har 5 daqiqada o'zi qayta so'raydi.
class CurrenciesScreen extends ConsumerStatefulWidget {
  const CurrenciesScreen({super.key});

  @override
  ConsumerState<CurrenciesScreen> createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends ConsumerState<CurrenciesScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => ref.invalidate(currencyRatesProvider),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(currencyRatesProvider);
    await ref.read(currencyRatesProvider.future).catchError(
          (Object _) => const CurrencyRates(rates: <CurrencyRate>[]),
        );
  }

  static String _format(double value) =>
      NumberFormat('#,##0.00', 'en').format(value).replaceAll(',', Money.nbsp);

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final AsyncValue<CurrencyRates> rates = ref.watch(currencyRatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.currencyTitle)),
      body: rates.when(
        loading: () => const SkeletonList(),
        error: (Object error, StackTrace _) => EmptyState(
          icon: Icons.wifi_off_rounded,
          title: s.errorNetwork,
          message: apiErrorText(s, error),
          actionLabel: s.retry,
          onAction: () => ref.invalidate(currencyRatesProvider),
        ),
        data: (CurrencyRates data) {
          if (data.rates.isEmpty) {
            return EmptyState(
              icon: Icons.currency_exchange_rounded,
              title: s.currencyEmpty,
              actionLabel: s.retry,
              onAction: () => ref.invalidate(currencyRatesProvider),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.screen),
              children: <Widget>[
                for (final CurrencyRate rate in data.rates) ...<Widget>[
                  _RateTile(rate: rate, format: _format),
                  const SizedBox(height: AppSpacing.md),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(
                  s.currencySource,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                if (data.updatedAt != null)
                  Text(
                    s.currencyUpdatedText(
                      DateFormat('dd.MM.yyyy HH:mm')
                          .format(data.updatedAt!.toLocal()),
                    ),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RateTile extends StatelessWidget {
  const _RateTile({required this.rate, required this.format});

  final CurrencyRate rate;
  final String Function(double) format;

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool up = rate.diff > 0;
    final bool down = rate.diff < 0;
    final Color diffColor = up
        ? AppColors.success
        : (down ? AppColors.danger : AppColors.textSecondary);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          Container(
            height: 44,
            width: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: AppRadius.field,
            ),
            child: Text(
              rate.code,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.darkGreen,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  rate.localizedName(s.localeCode),
                  style: textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${rate.nominal} ${rate.code}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${format(rate.rate)}${Money.nbsp}${Money.currency}',
                style: textTheme.titleSmall,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (up || down)
                    Icon(
                      up
                          ? Icons.arrow_drop_up_rounded
                          : Icons.arrow_drop_down_rounded,
                      color: diffColor,
                      size: 20,
                    ),
                  Text(
                    rate.diff == 0
                        ? '0'
                        : (up ? '+' : '') + rate.diff.toStringAsFixed(2),
                    style: textTheme.labelSmall?.copyWith(color: diffColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
