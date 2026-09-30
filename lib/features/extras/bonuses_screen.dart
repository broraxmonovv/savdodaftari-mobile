import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/widgets.dart';
import '../auth/data/auth_models.dart';
import '../auth/state/auth_providers.dart';
import '../billing/data/billing_models.dart';
import '../billing/plan_text.dart';
import '../billing/state/billing_providers.dart';
import 'data/extras_models.dart';
import 'state/extras_providers.dart';
import 'withdraw_screen.dart';

/// Bonuslar balansi: tarifga to'lash, kartaga yechib olish, tarix.
class BonusesScreen extends ConsumerWidget {
  const BonusesScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(bonusesProvider);
    ref.invalidate(withdrawalsProvider);
    await ref.read(bonusesProvider.future).catchError(
          (Object _) => const BonusSummary(balance: 0, entries: <BonusEntry>[]),
        );
  }

  /// Bonus balansi yetadigan tariflarni ko'rsatib, tanlanganini to'laydi.
  Future<void> _payPlan(
    BuildContext context,
    WidgetRef ref,
    double balance,
  ) async {
    final AppStrings s = context.s;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final BillingPlans plans;
    try {
      plans = await ref.read(billingPlansProvider.future);
    } on ApiException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorText(s, error))));
      return;
    }
    if (!context.mounted) {
      return;
    }

    // Faqat hozirgi tarifdan yuqori tariflar sotib olinadi.
    final List<PlanOffer> offers = plans.offers
        .where((PlanOffer o) => o.plan.index > plans.current.index)
        .toList();

    final UserPlan? chosen = await showModalBottomSheet<UserPlan>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                s.bonusPlanSheetTitle,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final PlanOffer offer in offers)
                ListTile(
                  enabled: balance >= offer.price,
                  leading: const Icon(Icons.workspace_premium_rounded),
                  title: Text(offer.plan.label(s)),
                  subtitle: Text(
                    balance >= offer.price
                        ? Money.format(offer.price)
                        : '${Money.format(offer.price)} · ${s.bonusNotEnough}',
                  ),
                  onTap: balance >= offer.price
                      ? () => Navigator.of(sheetContext).pop(offer.plan)
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
    if (chosen == null) {
      return;
    }

    try {
      await ref
          .read(extrasRepositoryProvider)
          .payPlanWithBonus(chosen.apiValue);
      await ref.read(authControllerProvider.notifier).refreshUser();
      ref.invalidate(bonusesProvider);
      ref.invalidate(billingPlansProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(s.planActivatedText(chosen.label(s)))),
      );
    } on ApiException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorText(s, error))));
    }
  }

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final WithdrawalList list = await ref.read(withdrawalsProvider.future);
    if (!context.mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => WithdrawScreen(
          balance: list.balance,
          minWithdrawal: list.minWithdrawal,
        ),
      ),
    );
    ref.invalidate(bonusesProvider);
    ref.invalidate(withdrawalsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<BonusSummary> summary = ref.watch(bonusesProvider);
    final List<WithdrawalRequest> withdrawals =
        ref.watch(withdrawalsProvider).valueOrNull?.items ??
            const <WithdrawalRequest>[];

    return Scaffold(
      appBar: AppBar(title: Text(s.bonusTitle)),
      body: summary.when(
        loading: () => const SkeletonDetail(),
        error: (Object error, StackTrace _) => EmptyState(
          icon: Icons.wifi_off_rounded,
          title: s.errorNetwork,
          message: apiErrorText(s, error),
          actionLabel: s.retry,
          onAction: () => ref.invalidate(bonusesProvider),
        ),
        data: (BonusSummary data) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _refresh(ref),
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
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppButton(
                      label: s.bonusPayPlan,
                      icon: Icons.workspace_premium_rounded,
                      size: AppButtonSize.medium,
                      onPressed: data.balance > 0
                          ? () => _payPlan(context, ref, data.balance)
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: s.bonusWithdraw,
                      icon: Icons.credit_card_rounded,
                      size: AppButtonSize.medium,
                      variant: AppButtonVariant.secondary,
                      onPressed: data.balance > 0
                          ? () => _withdraw(context, ref)
                          : null,
                    ),
                  ),
                ],
              ),
              if (withdrawals.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.xl),
                Text(s.withdrawalsHistoryTitle, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                for (final WithdrawalRequest item in withdrawals) ...<Widget>[
                  _WithdrawalTile(item: item),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
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

class _WithdrawalTile extends StatelessWidget {
  const _WithdrawalTile({required this.item});

  final WithdrawalRequest item;

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final (String label, Color color) = switch (item.status) {
      WithdrawalStatus.pending => (s.withdrawStatusPending, AppColors.warning),
      WithdrawalStatus.paid => (s.withdrawStatusPaid, AppColors.success),
      WithdrawalStatus.rejected => (s.withdrawStatusRejected, AppColors.danger),
    };

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
            child: Icon(Icons.credit_card_rounded, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(Money.format(item.amount), style: textTheme.titleSmall),
                Text(item.card, style: textTheme.bodySmall),
                if (item.adminNote != null && item.adminNote!.isNotEmpty)
                  Text(item.adminNote!, style: textTheme.labelSmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: textTheme.labelSmall?.copyWith(color: color),
            ),
          ),
        ],
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
    final Color color = entry.isNegative ? AppColors.danger : AppColors.success;

    final (String title, IconData icon) = switch (entry.type) {
      'reversal' => (s.bonusReversal, Icons.undo_rounded),
      'plan_payment' => (
          '${s.bonusPlanPayment}: ${UserPlan.fromApi(entry.plan).label(s)}',
          Icons.workspace_premium_rounded,
        ),
      'withdrawal' => (s.bonusWithdrawal, Icons.credit_card_rounded),
      'withdrawal_refund' => (s.bonusWithdrawalRefund, Icons.undo_rounded),
      _ => (s.bonusFromText(entry.from), Icons.card_giftcard_rounded),
    };

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
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: textTheme.titleSmall),
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
