import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Shtrix-kod muvaffaqiyatli o'qilganda qisqa "tit" signali (do'kon skanerlari kabi) va yengil tebranish.
///
/// Skaner ekrani kod topilishi bilan yopiladi, shuning uchun pleyer ekrandan mustaqil, umumiy
/// obyekt sifatida saqlanadi. Ovoz chiqmasa (qurilma ovozi o'chiq yoki plagin yo'q) ilova ishlashda davom etadi.
abstract final class ScanBeep {
  static const String asset = 'sounds/scan_beep.wav';

  static AudioPlayer? _player;

  /// Ilova ishga tushganda yoki skaner ochilganda chaqirilsa, birinchi "tit" kechikmaydi.
  static Future<void> warmUp() async {
    try {
      final AudioPlayer player = _player ??= AudioPlayer()
        ..setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setSource(AssetSource(asset));
    } catch (e) {
      debugPrint('ScanBeep.warmUp: $e');
    }
  }

  /// "Tit" + tebranish. Kutish shart emas.
  static Future<void> play() async {
    HapticFeedback.mediumImpact();
    try {
      final AudioPlayer player = _player ??= AudioPlayer()
        ..setPlayerMode(PlayerMode.lowLatency);
      await player.stop();
      await player.play(AssetSource(asset), volume: 1.0);
    } catch (e) {
      // Ovoz chiqmasa ham skanerlash davom etadi; tizim signali zaxira sifatida.
      debugPrint('ScanBeep.play: $e');
      SystemSound.play(SystemSoundType.click);
    }
  }
}
