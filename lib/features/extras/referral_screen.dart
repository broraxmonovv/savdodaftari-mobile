import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/link.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/widgets.dart';
import 'bonuses_screen.dart';
import 'data/extras_models.dart';
import 'state/extras_providers.dart';

/// Referal dasturi: kod/havola olish va ulashish. Taklif qilingan foydalanuvchi
/// qilgan har bir to'lovdan [ReferralInfo.percent] foiz bonus balansiga tushadi.
class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  Future<void> _copy(BuildContext context, String text) async {
    final AppStrings s = context.s;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(s.referralCopied)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<ReferralInfo> info = ref.watch(referralProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.referralTitle)),
      body: info.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => EmptyState(
          icon: Icons.wifi_off_rounded,
          title: s.errorNetwork,
          message: apiErrorText(s, error),
          actionLabel: s.retry,
          onAction: () => ref.invalidate(referralProvider),
        ),
        data: (ReferralInfo data) {
          final String percent = data.percent == data.percent.roundToDouble()
              ? data.percent.toInt().toString()
              : data.percent.toString();
          final String shareText = s.referralShareText(data.link, data.code);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: <Widget>[
              AppCard(
                color: AppColors.brand,
                shadows: AppShadows.raised,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      s.referralBodyText(percent),
                      style: textTheme.bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(s.referralCodeLabel, style: textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            data.code,
                            style: textTheme.headlineSmall?.copyWith(
                              letterSpacing: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: s.referralCopy,
                          onPressed: () => _copy(context, data.code),
                          icon: const Icon(Icons.copy_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      data.link,
                      style: textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: s.referralCopy,
                      icon: Icons.link_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => _copy(context, data.link),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: s.referralShare,
                      icon: Icons.send_rounded,
                      onPressed: () => openLink(
                        context,
                        Uri.https('t.me', '/share/url', <String, String>{
                          'url': data.link,
                          'text': shareText,
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _Stat(
                      label: s.referralInvited,
                      value: data.invitedCount.toString(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _Stat(
                      label: s.referralPaying,
                      value: data.payingCount.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _Stat(
                label: s.referralEarned,
                value: Money.format(data.earnedTotal),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext _) => const BonusesScreen(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: textTheme.titleMedium),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
