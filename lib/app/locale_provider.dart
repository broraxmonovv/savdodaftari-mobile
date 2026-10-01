import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_strings.dart';
import '../features/auth/state/auth_providers.dart';

/// Ilova tilini boshqaradi: o'zbek (lotin), o'zbek (kirill) va rus tili.
///
/// Tanlangan til qurilmada saqlanadi va API klientga `Accept-Language`
/// sifatida uzatiladi — backend xabarlari ham shu tilda keladi.
class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._ref) : super(const Locale('uz')) {
    _restore();
  }

  final Ref _ref;

  Future<void> _restore() async {
    try {
      final String? code = await _ref.read(tokenStorageProvider).readLocale();
      if (code != null && AppStrings.isSupportedKey(code)) {
        _apply(code);
      }
    } catch (_) {
      // Saqlangan til o'qilmasa standart til (o'zbek lotin) qoladi.
    }
  }

  /// [code]: `uz` (lotin), `uz_cyrl` (kirill) yoki `ru`.
  Future<void> setLocale(String code) async {
    if (!AppStrings.isSupportedKey(code)) {
      return;
    }
    _apply(code);
    try {
      await _ref.read(tokenStorageProvider).writeLocale(code);
    } catch (_) {}
  }

  void _apply(String code) {
    _ref.read(apiClientProvider).setLanguage(AppStrings.apiLanguage(code));
    if (mounted) {
      state = AppStrings.localeOf(code);
    }
  }
}

final StateNotifierProvider<LocaleController, Locale> localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>(LocaleController.new);
