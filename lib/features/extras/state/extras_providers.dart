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

/// Bosh sahifadagi reklama bannerlari (xatolikda bo'sh ro'yxat — karusel yashirinadi).
final AutoDisposeFutureProvider<List<AdBanner>> bannersProvider =
    FutureProvider.autoDispose<List<AdBanner>>((Ref ref) async {
  try {
    return await ref.watch(extrasRepositoryProvider).banners();
  } catch (_) {
    return <AdBanner>[];
  }
});

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

/// Ogohlantirishlar (qarz muddati, kam qoldiq, tarif tugashi).
final AutoDisposeFutureProvider<List<AlertItem>> alertsProvider =
    FutureProvider.autoDispose<List<AlertItem>>(
  (Ref ref) => ref.watch(extrasRepositoryProvider).alerts(),
);

/// Bulut zaxira nusxalari ro'yxati (Pro).
final AutoDisposeFutureProvider<List<BackupInfo>> backupsProvider =
    FutureProvider.autoDispose<List<BackupInfo>>(
  (Ref ref) => ref.watch(extrasRepositoryProvider).backups(),
);
