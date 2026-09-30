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

/// Bonuslar balansi va tarixi (referal ulushlari).
class BonusesScreen extends ConsumerWidget {
  const BonusesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<BonusSummary> summary = ref.watch(bonusesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.bonusTitle)),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => EmptyState(
          icon: Icons.wifi_off_rounded,
          title: s.errorNetwork,
          message: apiErrorText(s, error),
          actionLabel: s.retry,
          onAction: () => ref.invalidate(bonusesProvider),
        ),
        data: (BonusSummary data) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(bonusesProvider);
            await ref.read(bonusesProvider.future).catchError(
                  (Object _) => const BonusSummary(
                    balance: 0,
                    entries: <BonusEntry>[],
                  ),
                );
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: <Widget>[
              AppCard(
                color: AppColors.brand,
                shadows: AppShadows.raised,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      s.bonusBalanceLabel,
                      style: textTheme.bodySmall
                          ?.copyWith(color: Colors.white.withOpacity(0.8)),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      Money.format(data.balance),
                      style: textTheme.headlineSmall
                          ?.copyWith(color: Colors.white, fontSize: 28),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(s.bonusHistoryTitle, style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              if (data.entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Text(
                    s.bonusEmpty,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
                  ),
                )
              else
                for (final BonusEntry entry in data.entries) ...<Widget>[
                  _EntryTile(entry: entry),
                  const SizedBox(height: AppSpacing.md),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final BonusEntry entry;

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color color = entry.isReversal ? AppColors.danger : AppColors.success;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: AppRadius.field,
            ),
            child: Icon(
              entry.isReversal
                  ? Icons.undo_rounded
                  : Icons.card_giftcard_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.isReversal
                      ? s.bonusReversal
                      : s.bonusFromText(entry.from),
                  style: textTheme.titleSmall,
                ),
                if (entry.createdAt != null)
                  Text(
                    DateFormat('dd.MM.yyyy HH:mm')
                        .format(entry.createdAt!.toLocal()),
                    style: textTheme.labelSmall,
                  ),
              ],
            ),
          ),
          Text(
            Money.format(entry.amount, signed: true),
            style: textTheme.titleSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
