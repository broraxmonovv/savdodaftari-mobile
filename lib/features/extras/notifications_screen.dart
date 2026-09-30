import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/widgets.dart';
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
        title: Text(item.title),
        content: SingleChildScrollView(child: Text(item.body)),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => EmptyState(
          icon: Icons.wifi_off_rounded,
          title: s.errorNetwork,
          message: apiErrorText(s, error),
          actionLabel: s.retry,
          onAction: () => ref.invalidate(announcementsProvider),
        ),
        data: (AnnouncementList data) {
          if (data.items.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_none_rounded,
              title: s.notificationsEmptyTitle,
              message: s.notificationsEmptyBody,
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(announcementsProvider);
              await ref.read(announcementsProvider.future).catchError(
                    (Object _) => const AnnouncementList(
                      items: <Announcement>[],
                      unreadCount: 0,
                    ),
                  );
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.screen),
              itemCount: data.items.length,
              separatorBuilder: (BuildContext _, int __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (BuildContext context, int index) {
                final Announcement item = data.items[index];
                return AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  onTap: () => _open(context, ref, item),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: item.isRead
                              ? AppColors.border
                              : AppColors.lightGreen,
                          borderRadius: AppRadius.field,
                        ),
                        child: Icon(
                          Icons.campaign_rounded,
                          size: 22,
                          color: item.isRead
                              ? AppColors.textSecondary
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.title,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: item.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.body,
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
              },
            ),
          );
        },
      ),
    );
  }
}
