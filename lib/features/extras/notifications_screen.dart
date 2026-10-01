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
import '../billing/plan_text.dart';
import 'data/extras_models.dart';
import 'state/extras_providers.dart';

/// Bildirishnomalar: admin panelidan yuborilgan xabarlar. Bosilganda o'qilgan
/// deb belgilanadi; "Hammasini o'qilgan deb belgilash" tugmasi bor.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    Announcement item,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.s.dyn(item.title)),
        content: SingleChildScrollView(child: Text(context.s.dyn(item.body))),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.s.close),
          ),
        ],
      ),
    );
    if (!item.isRead) {
      try {
        await ref.read(extrasRepositoryProvider).markAnnouncementRead(item.id);
      } on ApiException {
        // Keyingi yangilashda qayta urinadi.
      }
      ref.invalidate(announcementsProvider);
    }
  }

  Future<void> _readAll(WidgetRef ref) async {
    try {
      await ref.read(extrasRepositoryProvider).markAllAnnouncementsRead();
    } on ApiException {
      // Xatolikda ro'yxat o'zgarmaydi.
    }
    ref.invalidate(announcementsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<AnnouncementList> list = ref.watch(announcementsProvider);
    final int unread = list.valueOrNull?.unreadCount ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.notifications),
        actions: <Widget>[
          if (unread > 0)
            IconButton(
              tooltip: s.markAllRead,
              onPressed: () => _readAll(ref),
              icon: const Icon(Icons.done_all_rounded),
            ),
        ],
      ),
      body: list.when(
        loading: () => const SkeletonList(),
        error: (Object error, StackTrace _) => EmptyState(
          icon: Icons.wifi_off_rounded,
          title: s.errorNetwork,
          message: apiErrorText(s, error),
          actionLabel: s.retry,
          onAction: () => ref.invalidate(announcementsProvider),
        ),
        data: (AnnouncementList data) {
          final List<AlertItem> alerts =
              ref.watch(alertsProvider).valueOrNull ?? const <AlertItem>[];

          if (data.items.isEmpty && alerts.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_none_rounded,
              title: s.notificationsEmptyTitle,
              message: s.notificationsEmptyBody,
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(alertsProvider);
              ref.invalidate(announcementsProvider);
              await ref.read(announcementsProvider.future).catchError(
                    (Object _) => const AnnouncementList(
                      items: <Announcement>[],
                      unreadCount: 0,
                    ),
                  );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.screen),
              children: <Widget>[
                if (alerts.isNotEmpty) ...<Widget>[
                  Text(s.alertsTitle, style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  for (final AlertItem alert in alerts) ...<Widget>[
                    _AlertTile(alert: alert),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  const SizedBox(height: AppSpacing.md),
                ],
                if (data.items.isNotEmpty) ...<Widget>[
                  Text(s.announcementsTitle, style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  for (final Announcement item in data.items) ...<Widget>[
                    _AnnouncementTile(
                      item: item,
                      onTap: () => _open(context, ref, item),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({required this.item, required this.onTap});

  final Announcement item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.isRead ? AppColors.border : AppColors.lightGreen,
              borderRadius: AppRadius.field,
            ),
            child: Icon(
              Icons.campaign_rounded,
              size: 22,
              color: item.isRead ? AppColors.textSecondary : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.s.dyn(item.title),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.s.dyn(item.body),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
                if (item.createdAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('dd.MM.yyyy HH:mm')
                          .format(item.createdAt!.toLocal()),
                      style: textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
          ),
          if (!item.isRead)
            Container(
              margin: const EdgeInsets.only(top: 6, left: 8),
              height: 10,
              width: 10,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

/// Hisoblangan ogohlantirish (qarz, qoldiq, tarif) — faqat ko'rsatiladi.
class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final AlertItem alert;

  static String _qty(double? value) {
    if (value == null) {
      return '';
    }
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String amount =
        alert.amount == null ? '' : Money.format(alert.amount!);
    final String date = alert.dueDate == null
        ? ''
        : DateFormat('dd.MM.yyyy').format(alert.dueDate!);

    final (String text, IconData icon, Color color) = switch (alert.type) {
      'debt_overdue' => (
          s.alertText(s.alertDebtOverdueTemplate,
              name: alert.name, amount: amount),
          Icons.account_balance_wallet_rounded,
          AppColors.danger,
        ),
      'debt_due_soon' => (
          s.alertText(s.alertDebtDueSoonTemplate,
              name: alert.name, amount: amount, date: date),
          Icons.schedule_rounded,
          AppColors.warning,
        ),
      'out_of_stock' => (
          s.alertText(s.alertOutOfStockTemplate, name: alert.name),
          Icons.inventory_2_rounded,
          AppColors.danger,
        ),
      'low_stock' => (
          s.alertText(
            s.alertLowStockTemplate,
            name: alert.name,
            stock: _qty(alert.stock),
            unit: alert.unit ?? '',
            min: _qty(alert.minStock),
          ),
          Icons.inventory_2_rounded,
          AppColors.warning,
        ),
      'subscription_expiring' => (
          s.alertText(
            s.alertSubscriptionTemplate,
            plan: UserPlan.fromApi(alert.plan).label(s),
            days: (alert.daysLeft ?? 0).toString(),
          ),
          Icons.workspace_premium_rounded,
          AppColors.info,
        ),
      _ => (alert.name, Icons.info_outline_rounded, AppColors.info),
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
          Expanded(child: Text(text, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
