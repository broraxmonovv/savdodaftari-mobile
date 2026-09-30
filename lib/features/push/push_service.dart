import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extras/data/extras_repository.dart';
import '../extras/state/extras_providers.dart';

/// Push-bildirishnomalar (FCM). Firebase sozlanmagan bo'lsa (google-services.json /
/// GoogleService-Info.plist yo'q) hamma amal jim o'tkazib yuboriladi.
///
/// Oqim: kirgandan keyin [start] ruxsat so'raydi, FCM tokenini backendga
/// yuboradi (`POST /devices`), token yangilansa qayta yuboradi. Ilova ochiq
/// paytida xabar kelsa [onMessage] chaqiriladi (bildirishnomalar yangilanadi).
/// Chiqishda [stop] tokenni backenddan o'chiradi.
class PushService {
  PushService(this._repository);

  final ExtrasRepository _repository;

  bool _initialized = false;
  bool _available = false;
  bool _listening = false;
  String? _token;

  /// Ilova ochiq paytida push kelganda chaqiriladi.
  VoidCallback? onMessage;

  Future<bool> _ensureInitialized() async {
    if (_initialized) {
      return _available;
    }
    _initialized = true;
    try {
      await Firebase.initializeApp();
      _available = true;
    } catch (error) {
      debugPrint('Push o\'chiq (Firebase sozlanmagan): $error');
      _available = false;
    }
    return _available;
  }

  Future<void> start() async {
    if (!await _ensureInitialized()) {
      return;
    }
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      final NotificationSettings settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      final String? token = await messaging.getToken();
      if (token != null) {
        await _register(token);
      }

      // Qayta kirganda tinglovchilar ikki marta ulanmasligi uchun bir marta.
      if (!_listening) {
        _listening = true;
        messaging.onTokenRefresh.listen(_register);
        FirebaseMessaging.onMessage
            .listen((RemoteMessage _) => onMessage?.call());
      }
    } catch (error) {
      debugPrint('Push ishga tushmadi: $error');
    }
  }

  Future<void> _register(String token) async {
    _token = token;
    try {
      await _repository.registerDevice(
        token,
        Platform.isIOS ? 'ios' : 'android',
      );
    } catch (error) {
      debugPrint('Qurilma tokeni yuborilmadi: $error');
    }
  }

  /// Chiqishda: token backenddan o'chiriladi (boshqa akkaunt xabarlarini olmasligi uchun).
  Future<void> stop() async {
    final String? token = _token;
    if (!_available || token == null) {
      return;
    }
    try {
      await _repository.unregisterDevice(token);
    } catch (error) {
      debugPrint('Qurilma tokeni o\'chirilmadi: $error');
    }
    _token = null;
  }
}

final Provider<PushService> pushServiceProvider = Provider<PushService>(
  (Ref ref) => PushService(ref.watch(extrasRepositoryProvider)),
);
