import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/locale_provider.dart';
import '../../app/router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/widgets.dart';

/// Splash'dan keyin birinchi ochilishda ko'rsatiladigan til tanlash sahifasi:
/// O'zbekcha (lotin), Ўзбекча (кирилл) yoki Русский. Tanlov darhol qo'llanadi
/// (shu sahifa ham yangi tilga o'tadi) va keyingi barcha sahifalar shu tilda bo'ladi.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  static const List<_LanguageOption> _options = <_LanguageOption>[
    _LanguageOption(key: 'uz', badge: 'UZ', title: "O'zbekcha", subtitle: 'Lotin yozuvi'),
    _LanguageOption(key: 'uz_cyrl', badge: 'ЎЗ', title: 'Ўзбекча', subtitle: 'Кирилл ёзуви'),
    _LanguageOption(key: 'ru', badge: 'RU', title: 'Русский', subtitle: 'Русский язык'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String selected = AppStrings.keyOf(ref.watch(localeControllerProvider));

    return Scaffold(
      body: Column(
        children: <Widget>[
          // Yuqori gradient sarlavha
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              MediaQuery.of(context).padding.top + AppSpacing.xxl,
              AppSpacing.xxl,
              AppSpacing.xxxl,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.primary, AppColors.darkGreen],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(36),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.translate_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  s.languageChooseTitle,
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  s.languageChooseSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              children: <Widget>[
                for (final _LanguageOption option in _options) ...<Widget>[
                  _LanguageCard(
                    option: option,
                    selected: option.key == selected,
                    onTap: () => ref
                        .read(localeControllerProvider.notifier)
                        .setLocale(option.key),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                0,
                AppSpacing.screen,
                AppSpacing.screen,
              ),
              child: AppButton(
                label: s.languageContinue,
                onPressed: () => context.go(AppRoutes.onboarding),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.key,
    required this.badge,
    required this.title,
    required this.subtitle,
  });

  final String key;
  final String badge;
  final String title;
  final String subtitle;
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      selected: selected,
      label: '${option.title}, ${option.subtitle}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightGreen : AppColors.card,
          borderRadius: AppRadius.large,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? AppShadows.raised : AppShadows.soft,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.large,
          child: InkWell(
            borderRadius: AppRadius.large,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      option.badge,
                      style: textTheme.titleMedium?.copyWith(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(option.title, style: textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(option.subtitle, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: selected
                        ? Icon(
                            Icons.check_circle_rounded,
                            key: const ValueKey<bool>(true),
                            color: AppColors.primary,
                            size: 28,
                          )
                        : Icon(
                            Icons.radio_button_unchecked_rounded,
                            key: const ValueKey<bool>(false),
                            color: AppColors.border,
                            size: 28,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
