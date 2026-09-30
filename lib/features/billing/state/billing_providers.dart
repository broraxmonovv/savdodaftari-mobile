import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/auth_providers.dart';
import '../data/billing_models.dart';
import '../data/billing_repository.dart';

final Provider<BillingRepository> billingRepositoryProvider =
    Provider<BillingRepository>(
  (Ref ref) => BillingRepository(ref.watch(apiClientProvider)),
);

/// Joriy tarif va Standart/Pro takliflari (tarif ekrani ochilganda yuklanadi).
final AutoDisposeFutureProvider<BillingPlans> billingPlansProvider =
    FutureProvider.autoDispose<BillingPlans>(
  (Ref ref) => ref.watch(billingRepositoryProvider).plans(),
);
