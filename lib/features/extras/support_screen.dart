import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/link.dart';
import '../../core/widgets/widgets.dart';
import 'data/extras_models.dart';
import 'state/extras_providers.dart';

/// Qo'llab-quvvatlash: telefon, Telegram va email (backend `/support`).
class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = context.s;
    final AsyncValue<SupportInfo> info = ref.watch(supportProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.supportTitle)),
      body: info.when(
        loading: () => const SkeletonDetail(),
        error: (Object error, StackTrace _) => EmptyState(
          icon: Icons.wifi_off_rounded,
          title: s.errorNetwork,
          message: apiErrorText(s, error),
          actionLabel: s.retry,
          onAction: () => ref.invalidate(supportProvider),
        ),
        data: (SupportInfo data) => ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: <Widget>[
            Text(s.supportBody, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            if (data.phone.isNotEmpty)
              _ContactTile(
                icon: Icons.call_rounded,
                color: AppColors.primary,
                title: s.supportCall,
                subtitle: data.phone,
                onTap: () => openLink(context, Uri.parse('tel:${data.phone}')),
              ),
            if (data.telegram.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              _ContactTile(
                icon: Icons.send_rounded,
                color: AppColors.info,
                title: s.supportTelegram,
                subtitle: telegramHandle(data.telegram),
                onTap: () => openLink(context, Uri.parse(telegramUrl(data.telegram))),
              ),
            ],
            if (data.email.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              _ContactTile(
                icon: Icons.mail_rounded,
                color: AppColors.warning,
                title: s.supportEmail,
                subtitle: data.email,
                onTap: () =>
                    openLink(context, Uri.parse('mailto:${data.email}')),
              ),
            ],
            if (data.workingHours.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Icon(Icons.schedule_rounded,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${s.supportHours}: ${data.workingHours}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            height: 44,
            width: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: AppRadius.field,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: textTheme.titleSmall),
                Text(subtitle, style: textTheme.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// `@savdoup_support_bot` yoki `https://t.me/savdoup_support_bot` -> ochiladigan havola.
String telegramUrl(String value) {
  final String v = value.trim();
  if (v.startsWith('@')) {
    return 'https://t.me/${v.substring(1)}';
  }
  if (v.startsWith('http')) {
    return v;
  }
  return 'https://t.me/$v';
}

/// Ekranda ko'rsatish uchun: `@savdoup_support_bot`.
String telegramHandle(String value) {
  final String v = value.trim();
  if (v.startsWith('@')) {
    return v;
  }
  final Uri? uri = Uri.tryParse(v);
  final String last = (uri != null && uri.pathSegments.isNotEmpty)
      ? uri.pathSegments.last
      : v;
  return '@$last';
}
