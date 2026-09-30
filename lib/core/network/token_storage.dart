import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Sanctum tokenini qurilmada xavfsiz saqlaydi (Keystore / Keychain).
class TokenStorage {
  const TokenStorage([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_token';
  static const String _onboardingKey = 'onboarding_seen';
  static const String _localeKey = 'locale';
  static const String _themeKey = 'theme_mode';
  static const String _printerKey = 'printer';

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<bool> isOnboardingSeen() async {
    return await _storage.read(key: _onboardingKey) == 'true';
  }

  Future<void> markOnboardingSeen() =>
      _storage.write(key: _onboardingKey, value: 'true');

  Future<String?> readLocale() => _storage.read(key: _localeKey);

  Future<void> writeLocale(String code) =>
      _storage.write(key: _localeKey, value: code);

  /// `system` | `light` | `dark`
  Future<String?> readThemeMode() => _storage.read(key: _themeKey);

  Future<void> writeThemeMode(String mode) =>
      _storage.write(key: _themeKey, value: mode);

  /// Tanlangan Bluetooth printer: `mac|name|paper` (paper: 58 yoki 80).
  Future<String?> readPrinter() => _storage.read(key: _printerKey);

  Future<void> writePrinter(String value) =>
      _storage.write(key: _printerKey, value: value);

  Future<void> clearPrinter() => _storage.delete(key: _printerKey);
}
