import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/network/api_exception.dart';
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

/// API xatosini ko'rsatadi. Mijoz/mahsulot limiti (`limit_reached`) bo'lsa — tarifga
/// o'tish taklifi (backend xabari bilan), aks holda oddiy snackbar.
Future<void> showApiErrorOrUpsell(
  BuildContext context,
  WidgetRef ref,
  ApiException error,
) async {
  final AppStrings s = context.s;

  if (error.code == 'limit_reached') {
    await showProUpsell(
      context,
      ref,
      title: s.limitReachedTitle,
      body: error.message,
      icon: Icons.lock_outline_rounded,
    );
    return;
  }

  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(apiErrorText(s, error))));
}
