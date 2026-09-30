import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/auth_providers.dart';
import '../data/extras_models.dart';
import '../data/extras_repository.dart';

final Provider<ExtrasRepository> extrasRepositoryProvider =
    Provider<ExtrasRepository>(
  (Ref ref) => ExtrasRepository(ref.watch(apiClientProvider)),
);

final AutoDisposeFutureProvider<CurrencyRates> currencyRatesProvider =
    FutureProvider.autoDispose<CurrencyRates>(
  (Ref ref) => ref.watch(extrasRepositoryProvider).currencies(),
);

final AutoDisposeFutureProvider<SupportInfo> supportProvider =
    FutureProvider.autoDispose<SupportInfo>(
  (Ref ref) => ref.watch(extrasRepositoryProvider).support(),
);

final AutoDisposeFutureProvider<List<GuideVideo>> guidesProvider =
    FutureProvider.autoDispose<List<GuideVideo>>(
  (Ref ref) => ref.watch(extrasRepositoryProvider).guides(),
);

final AutoDisposeFutureProvider<ReferralInfo> referralProvider =
    FutureProvider.autoDispose<ReferralInfo>(
  (Ref ref) => ref.watch(extrasRepositoryProvider).referral(),
);

final AutoDisposeFutureProvider<BonusSummary> bonusesProvider =
    FutureProvider.autoDispose<BonusSummary>(
  (Ref ref) => ref.watch(extrasRepositoryProvider).bonuses(),
);

final AutoDisposeFutureProvider<WithdrawalList> withdrawalsProvider =
    FutureProvider.autoDispose<WithdrawalList>(
  (Ref ref) => ref.watch(extrasRepositoryProvider).withdrawals(),
);

/// Bildirishnomalar (bosh sahifadagi qo'ng'iroq belgisi va ro'yxat uchun).
final AutoDisposeFutureProvider<AnnouncementList> announcementsProvider =
    FutureProvider.autoDispose<AnnouncementList>(
  (Ref ref) => ref.watch(extrasRepositoryProvider).announcements(),
);
