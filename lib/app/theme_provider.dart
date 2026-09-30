import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/state/auth_providers.dart';

/// Ilova mavzusi: tizim / yorug' / qorong'u. Tanlov qurilmada saqlanadi.
class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._ref) : super(ThemeMode.system) {
    _restore();
  }

  final Ref _ref;

  Future<void> _restore() async {
    final String? saved = await _ref.read(tokenStorageProvider).readThemeMode();
    final ThemeMode? mode = _parse(saved);
    if (mode != null && mounted) {
      state = mode;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _ref.read(tokenStorageProvider).writeThemeMode(mode.name);
  }

  static ThemeMode? _parse(String? value) {
    for (final ThemeMode mode in ThemeMode.values) {
      if (mode.name == value) {
        return mode;
      }
    }
    return null;
  }
}

final StateNotifierProvider<ThemeModeController, ThemeMode>
    themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
