import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../auth/state/auth_providers.dart';
import 'plans_screen.dart';

/// Pro bo'lmagan foydalanuvchi Pro funksiyaga bosganda: qisqa tushuntirish va
/// "Pro'ga o'tish" (Tariflar ekrani). Qaytgach tarif holati yangilanadi.
Future<void> showProUpsell(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String body,
  IconData icon = Icons.workspace_premium_rounded,
}) async {
  final AppStrings s = context.s;

  final bool? upgrade = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      icon: Icon(icon, color: AppColors.primary, size: 40),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(body, textAlign: TextAlign.center),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(s.close),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(s.proUpgradeAction),
        ),
      ],
    ),
  );

  if (upgrade == true && context.mounted) {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (BuildContext _) => const PlansScreen()),
    );
    await ref.read(authControllerProvider.notifier).refreshUser();
  }
}
