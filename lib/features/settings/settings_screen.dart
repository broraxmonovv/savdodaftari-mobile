import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/locale_provider.dart';
import '../../app/router.dart';
import '../../app/theme_provider.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/phone.dart';
import '../../core/widgets/widgets.dart';
import '../auth/data/auth_models.dart';
import '../auth/state/auth_controller.dart';
import '../auth/state/auth_providers.dart';
import '../billing/plan_text.dart';
import '../billing/plans_screen.dart';
import '../extras/bonuses_screen.dart';
import '../extras/currencies_screen.dart';
import '../extras/guides_screen.dart';
import '../extras/referral_screen.dart';
import '../assistant/assistant_screen.dart';
import '../backup/backups_screen.dart';
import '../ocr/ocr_import_screen.dart';
import '../printing/printer_screen.dart';
import '../push/push_service.dart';
import '../extras/support_screen.dart';
import '../expenses/expenses_screen.dart';
import '../reports/reports_screen.dart';
import 'pin_change_screen.dart';

/// TZ 26, 31, 35: Sozlamalar — profil, Pro tarif, hisobot, xarajatlar,
/// til, PIN almashtirish va chiqish.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _push(BuildContext context, Widget screen) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext context) => screen),
    );
  }

  Future<void> _setSmsReminders(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final AppStrings s = context.s;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authControllerProvider.notifier).setSmsReminders(value);
    } on ApiException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorText(s, error))));
    }
  }

  /// Profil rasmi: galereya / kamera / o'chirish.
  Future<void> _changePhoto(BuildContext context, WidgetRef ref) async {
    final AppStrings s = context.s;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool hasPhoto =
        (ref.read(authControllerProvider).user?.avatarUrl ?? '').isNotEmpty;

    final String? action = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(s.photoFromGallery),
              onTap: () => Navigator.of(sheet).pop('gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(s.photoFromCamera),
              onTap: () => Navigator.of(sheet).pop('camera'),
            ),
            if (hasPhoto)
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                title: Text(
                  s.photoRemove,
                  style: TextStyle(color: AppColors.danger),
                ),
                onTap: () => Navigator.of(sheet).pop('remove'),
              ),
          ],
        ),
      ),
    );
    if (action == null) {
      return;
    }

    final AuthController auth = ref.read(authControllerProvider.notifier);
    try {
      if (action == 'remove') {
        await auth.deleteAvatar();
        return;
      }
      final XFile? file = await ImagePicker().pickImage(
        source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (file == null) {
        return;
      }
      await auth.uploadAvatar(file.path);
      messenger.showSnackBar(SnackBar(content: Text(s.photoSaved)));
    } on ApiException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorText(s, error))));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.errorUnknown)));
    }
  }

  /// Til tanlash — tanlov qurilmada saqlanadi va API'ga uzatiladi.
  Future<void> _chooseLanguage(BuildContext context, WidgetRef ref) async {
    final AppStrings s = context.s;
    final String current = ref.read(localeControllerProvider).languageCode;

    final String? code = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final (String value, String label)
                    in <(String, String)>[
                  ('uz', s.languageUz),
                  ('ru', s.languageRu),
                ])
                  ListTile(
                    title: Text(label),
                    trailing: value == current
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(value),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (code != null && code != current) {
      await ref.read(localeControllerProvider.notifier).setLocale(code);

      // Tanlangan til backend profilida ham saqlanadi — SMS va API
      // xabarlari shu tilda keladi (TZ 4).
      final AuthUser? user = ref.read(authControllerProvider).user;
      if (user != null && user.name.trim().isNotEmpty) {
        await ref.read(authControllerProvider.notifier).saveProfile(
              name: user.name,
              shopName: user.shopName,
              businessType: user.businessType,
              locale: code,
            );
      }
    }
  }

  /// Mavzu tanlash: tizim / yorug' / qorong'u.
  Future<void> _chooseTheme(BuildContext context, WidgetRef ref) async {
    final AppStrings s = context.s;
    final ThemeMode current = ref.read(themeModeProvider);

    final ThemeMode? mode = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final (ThemeMode value, String label, IconData icon)
                    in <(ThemeMode, String, IconData)>[
                  (ThemeMode.system, s.themeSystem, Icons.brightness_auto_rounded),
                  (ThemeMode.light, s.themeLight, Icons.light_mode_rounded),
                  (ThemeMode.dark, s.themeDark, Icons.dark_mode_rounded),
                ])
                  ListTile(
                    leading: Icon(icon),
                    title: Text(label),
                    trailing: value == current
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(value),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (mode != null && mode != current) {
      await ref.read(themeModeProvider.notifier).setMode(mode);
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final AppStrings s = context.s;
    final bool confirmed = await ConfirmDialog.show(
      context,
      title: s.logout,
      message: s.logoutConfirmBody,
      confirmLabel: s.logout,
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    await ref.read(pushServiceProvider).stop();
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) {
      context.go(AppRoutes.phone);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AuthUser? user = ref.watch(authControllerProvider).user;
    final Locale locale = ref.watch(localeControllerProvider);
    final String languageName =
        locale.languageCode == 'ru' ? s.languageRu : s.languageUz;
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final String themeName = switch (themeMode) {
      ThemeMode.system => s.themeSystem,
      ThemeMode.light => s.themeLight,
      ThemeMode.dark => s.themeDark,
    };

    return Scaffold(
      appBar: AppBar(title: Text(s.navSettings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: <Widget>[
          // —— Profil: ism + telefon + do'kon nomi (TZ 5)
          if (user != null) ...<Widget>[
            AppCard(
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => _changePhoto(context, ref),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        UserAvatar(
                          name: user.name,
                          imageUrl: user.avatarUrl,
                          size: 60,
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.card,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.photo_camera_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(user.name, style: textTheme.titleMedium),
                        if (user.phone.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            Phone.formatFull(user.phone),
                            style: textTheme.bodySmall,
                          ),
                        ],
                        if (user.shopName != null &&
                            user.shopName!.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(user.shopName!, style: textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // —— Qarzdorlarga SMS eslatma yoqish/o'chirish
          if (user != null) ...<Widget>[
            AppCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: user.smsReminders,
                activeColor: AppColors.primary,
                title: Text(s.smsRemindersTitle, style: textTheme.titleSmall),
                subtitle: Text(s.smsRemindersBody, style: textTheme.bodySmall),
                onChanged: (bool value) => _setSmsReminders(context, ref, value),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // —— Tarif qatori: joriy tarif holati bilan (TZ 35.3)
          _MenuItem(
            icon: Icons.auto_awesome_rounded,
            iconColor: AppColors.darkGreen,
            iconBackground: AppColors.lightGreen,
            label: s.planScreenTitle,
            trailingText: (user?.isTrial ?? false)
                ? '${UserPlan.standard.label(s)} · ${s.trialBadge}'
                : (user?.plan ?? UserPlan.free).label(s),
            onTap: () async {
              await _push(context, const PlansScreen());
              await ref.read(authControllerProvider.notifier).refreshUser();
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.bar_chart_rounded,
            iconColor: AppColors.info,
            iconBackground: AppColors.infoSurface,
            label: s.navReports,
            onTap: () => _push(context, const ReportsScreen()),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.receipt_long_rounded,
            iconColor: AppColors.warning,
            iconBackground: AppColors.warningSurface,
            label: s.navExpenses,
            onTap: () => _push(context, const ExpensesScreen()),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.language_rounded,
            iconColor: AppColors.primary,
            iconBackground: AppColors.successSurface,
            label: s.languageLabel,
            trailingText: languageName,
            onTap: () => _chooseLanguage(context, ref),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.cloud_upload_rounded,
            iconColor: AppColors.info,
            iconBackground: AppColors.infoSurface,
            label: s.backupTitle,
            trailingText: 'Pro',
            onTap: () => openBackups(context, ref),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.auto_awesome_rounded,
            iconColor: AppColors.darkGreen,
            iconBackground: AppColors.lightGreen,
            label: s.assistantTitle,
            trailingText: 'Pro',
            onTap: () => openAssistant(context, ref),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.document_scanner_rounded,
            iconColor: AppColors.darkGreen,
            iconBackground: AppColors.lightGreen,
            label: s.ocrTitle,
            trailingText: 'Pro',
            onTap: () => openOcrImport(context, ref),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.print_rounded,
            iconColor: AppColors.info,
            iconBackground: AppColors.infoSurface,
            label: s.printerTitle,
            onTap: () => _push(context, const PrinterScreen()),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.dark_mode_rounded,
            iconColor: AppColors.textPrimary,
            iconBackground: AppColors.border,
            label: s.darkModeTitle,
            trailingText: themeName,
            onTap: () => _chooseTheme(context, ref),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.currency_exchange_rounded,
            iconColor: AppColors.success,
            iconBackground: AppColors.successSurface,
            label: s.currencyTitle,
            onTap: () => _push(context, const CurrenciesScreen()),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.card_giftcard_rounded,
            iconColor: AppColors.warning,
            iconBackground: AppColors.warningSurface,
            label: s.referralTitle,
            onTap: () => _push(context, const ReferralScreen()),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppColors.darkGreen,
            iconBackground: AppColors.lightGreen,
            label: s.bonusTitle,
            onTap: () => _push(context, const BonusesScreen()),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.ondemand_video_rounded,
            iconColor: AppColors.danger,
            iconBackground: AppColors.dangerSurface,
            label: s.guidesTitle,
            onTap: () => _push(context, const GuidesScreen()),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.support_agent_rounded,
            iconColor: AppColors.info,
            iconBackground: AppColors.infoSurface,
            label: s.supportTitle,
            onTap: () => _push(context, const SupportScreen()),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.pin_rounded,
            iconColor: AppColors.info,
            iconBackground: AppColors.infoSurface,
            label: s.changePinTitle,
            onTap: () => _push(context, const PinChangeScreen()),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: Icons.logout_rounded,
            iconColor: AppColors.danger,
            iconBackground: AppColors.dangerSurface,
            label: s.logout,
            onTap: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }
}

/// Sozlamalar bo'limi qatori — ikon + nom + (ixtiyoriy matn) + chevron.
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: AppRadius.field,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: textTheme.titleSmall)),
          if (trailingText != null) ...<Widget>[
            Text(
              trailingText!,
              style: textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
