import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/auth_providers.dart';
import '../data/trend_models.dart';
import '../data/trend_repository.dart';

final Provider<TrendRepository> trendRepositoryProvider =
    Provider<TrendRepository>(
  (Ref ref) => TrendRepository(ref.watch(apiClientProvider)),
);

/// Savdo dinamikasi (haftalik / oylik / butun davr). Yangilash: `ref.invalidate(trendProvider)`.
final AutoDisposeFutureProviderFamily<TrendSeries, TrendRange> trendProvider =
    FutureProvider.autoDispose.family<TrendSeries, TrendRange>(
  (Ref ref, TrendRange range) => ref.watch(trendRepositoryProvider).fetch(range),
);
