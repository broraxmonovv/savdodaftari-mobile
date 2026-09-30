import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/widgets.dart';
import '../auth/state/auth_providers.dart';
import '../billing/pro_upsell.dart';
import '../extras/data/extras_models.dart';
import '../extras/state/extras_providers.dart';
import '../home/state/home_providers.dart';

/// Sozlamalardan: Pro bo'lsa zaxira ekrani, aks holda Pro taklifi.
Future<void> openBackups(BuildContext context, WidgetRef ref) async {
  final AppStrings s = context.s;

  if (!(ref.read(authControllerProvider).user?.isPro ?? false)) {
    await showProUpsell(
      context,
      ref,
      title: s.voiceProTitle,
      body: s.backupProBody,
      icon: Icons.cloud_upload_rounded,
    );
    return;
  }

  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (BuildContext _) => const BackupsScreen()),
  );
}

/// Bulut zaxira (TZ 2, 23): zaxira yaratish, ro'yxat, **tiklash** va o'chirish.
/// Tiklashdan oldin backend joriy holatning avtomatik zaxirasini oladi.
class BackupsScreen extends ConsumerStatefulWidget {
  const BackupsScreen({super.key});

  @override
  ConsumerState<BackupsScreen> createState() => _BackupsScreenState();
}

class _BackupsScreenState extends ConsumerState<BackupsScreen> {
  bool _busy = false;

  void _snack(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  /// Amalni bajaradi: band holat, xatoliklar snackbar'da, keyin ro'yxat yangilanadi.
  Future<void> _run(Future<void> Function() action, {String? success}) async {
    final AppStrings s = context.s;
    setState(() => _busy = true);
    try {
      await action();
      if (success != null) {
        _snack(success);
      }
      ref.invalidate(backupsProvider);
    } on ApiException catch (error) {
      _snack(apiErrorText(s, error));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _restore(BackupInfo backup) async {
    final AppStrings s = context.s;
    final bool ok = await ConfirmDialog.show(
      context,
      title: s.backupRestoreTitle,
      message: s.backupRestoreWarning,
      confirmLabel: s.backupRestore,
      destructive: true,
    );
    if (!ok || !mounted) {
      return;
    }
    await _run(
      () async {
        await ref.read(extrasRepositoryProvider).restoreBackup(backup.id);
        // Bosh sahifadagi ko'rsatkichlar yangi ma'lumotlar bilan qayta yuklanadi.
        ref.read(homeControllerProvider.notifier).load();
      },
      success: s.backupRestored,
    );
  }

  Future<void> _delete(BackupInfo backup) async {
    final AppStrings s = context.s;
    final bool ok = await ConfirmDialog.show(
      context,
      title: s.backupDeleteConfirm,
      confirmLabel: s.delete,
      destructive: true,
    );
    if (!ok || !mounted) {
      return;
    }
    await _run(() => ref.read(extrasRepositoryProvider).deleteBackup(backup.id));
  }

  static String _size(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<List<BackupInfo>> backups = ref.watch(backupsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.backupTitle)),
      body: backups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => EmptyState(
          icon: Icons.wifi_off_rounded,
          title: s.errorNetwork,
          message: apiErrorText(s, error),
          actionLabel: s.retry,
          onAction: () => ref.invalidate(backupsProvider),
        ),
        data: (List<BackupInfo> items) => ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: <Widget>[
            Text(s.backupIntro, style: textTheme.bodySmall),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: s.backupCreate,
              icon: Icons.cloud_upload_rounded,
              isLoading: _busy,
              onPressed: () => _run(
                () => ref.read(extrasRepositoryProvider).createBackup(),
                success: s.backupCreated,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  s.backupEmpty,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),
              )
            else
              for (final BackupInfo backup in items) ...<Widget>[
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            backup.source == 'auto'
                                ? Icons.autorenew_rounded
                                : Icons.cloud_done_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              backup.createdAt == null
                                  ? '—'
                                  : DateFormat('dd.MM.yyyy HH:mm')
                                      .format(backup.createdAt!.toLocal()),
                              style: textTheme.titleSmall,
                            ),
                          ),
                          Text(
                            '${backup.source == 'auto' ? s.backupAuto : s.backupManual} · ${_size(backup.size)}',
                            style: textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        s.backupCountsText(
                          backup.counts['customers'] ?? 0,
                          backup.counts['sales'] ?? 0,
                          backup.counts['products'] ?? 0,
                        ),
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton.icon(
                            onPressed: _busy ? null : () => _delete(backup),
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: Text(s.delete),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.danger,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          FilledButton.tonalIcon(
                            onPressed: _busy ? null : () => _restore(backup),
                            icon: const Icon(Icons.settings_backup_restore_rounded),
                            label: Text(s.backupRestore),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
          ],
        ),
      ),
    );
  }
}
