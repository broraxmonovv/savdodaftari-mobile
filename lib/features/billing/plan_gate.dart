import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/widgets/widgets.dart';
import '../auth/data/auth_models.dart';
import '../auth/state/auth_providers.dart';
import 'plans_screen.dart';

/// Savdo va ombor bo'limlarini himoya qiladi: Standart yoki Pro tarif
/// faol bo'lmasa, [child] o'rniga tarifni faollashtirish taklifi chiqadi.
///
/// Tarif to'lovdan keyin yangilansa ([AuthController.refreshUser]) ekran
/// o'zi [child] ga almashadi.
class PlanGate extends ConsumerWidget {
  const PlanGate({super.key, required this.title, required this.child});

  /// Yopiq holatdagi ekran sarlavhasi (masalan, "Ombor").
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthUser? user = ref.watch(authControllerProvider).user;
    if (user == null || user.hasSalesAndInventory) {
      return child;
    }

    final AppStrings s = context.s;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(
        icon: Icons.lock_outline_rounded,
        title: s.planLockedTitle,
        message: s.planLockedBody,
        actionLabel: s.planLockedAction,
        onAction: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const PlansScreen(),
          ),
        ),
      ),
    );
  }
}
