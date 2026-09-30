import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/widgets.dart';
import '../../extras/support_screen.dart';
import '../state/auth_providers.dart';

/// Administrator hisobni bloklaganda ko'rsatiladi: sabab va qo'llab-quvvatlash
/// bilan bog'lanish (kontaktlar ochiq `/support` endpointidan olinadi).
class BlockedScreen extends ConsumerWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? reason = ref.watch(authControllerProvider).blockReason;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 84,
                  width: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.dangerSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.block_rounded,
                    size: 40,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  s.blockedTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  s.blockedBody,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                if (reason != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    color: AppColors.dangerSurface,
                    child: Text(
                      '${s.blockedReasonLabel}: $reason',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: s.supportTitle,
                  icon: Icons.support_agent_rounded,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext _) => const SupportScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: s.logout,
                  variant: AppButtonVariant.outline,
                  onPressed: () => context.go(AppRoutes.phone),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
