import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../core/network/token_storage.dart';
import '../auth/state/auth_providers.dart';

/// Saqlangan printer sozlamasi.
@immutable
class PrinterConfig {
  const PrinterConfig({required this.mac, required this.name, this.paper = 58});

  final String mac;
  final String name;

  /// Qog'oz kengligi, mm: 58 (XPrinter XP-58) yoki 80.
  final int paper;

  String encode() => '$mac|$name|$paper';

  static PrinterConfig? decode(String? raw) {
    if (raw == null) {
      return null;
    }
    final List<String> parts = raw.split('|');
    if (parts.length < 2 || parts[0].isEmpty) {
      return null;
    }
    return PrinterConfig(
      mac: parts[0],
      name: parts[1],
      paper: parts.length > 2 && parts[2] == '80' ? 80 : 58,
    );
  }

  PrinterConfig copyWith({int? paper}) =>
      PrinterConfig(mac: mac, name: name, paper: paper ?? this.paper);
}

/// Natija: muvaffaqiyat yoki xato sababi.
enum PrintResult { ok, noPermission, bluetoothOff, connectFailed, writeFailed }

/// Bluetooth ESC/POS (XPrinter va shunga o'xshash termoprinterlar) orqali chek chop etish.
///
/// Matn satrlari backend `/sales/{id}/receipt` dagi `lines` dan olinadi (32 belgi —
/// 58 mm). Arzon printerlar faqat ASCII ni ishonchli chop etadi, shuning uchun
/// kirill va maxsus belgilar lotinga o'giriladi ([printable]).
class ReceiptPrinter {
  ReceiptPrinter(this._storage);

  final TokenStorage _storage;

  Future<PrinterConfig?> savedPrinter() async =>
      PrinterConfig.decode(await _storage.readPrinter());

  Future<void> save(PrinterConfig config) =>
      _storage.writePrinter(config.encode());

  Future<void> forget() => _storage.clearPrinter();

  /// Android 12+ uchun Bluetooth ruxsatlarini so'raydi.
  Future<bool> ensurePermissions() async {
    final Map<Permission, PermissionStatus> result = await <Permission>[
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
    return result.values.every(
      (PermissionStatus s) => s.isGranted || s.isLimited,
    );
  }

  Future<bool> bluetoothEnabled() => PrintBluetoothThermal.bluetoothEnabled;

  /// Telefonga juftlangan (paired) Bluetooth qurilmalar.
  Future<List<BluetoothInfo>> pairedDevices() =>
      PrintBluetoothThermal.pairedBluetooths;

  Future<PrintResult> printLines(
    PrinterConfig config,
    List<String> lines,
  ) async {
    if (!await ensurePermissions()) {
      return PrintResult.noPermission;
    }
    if (!await bluetoothEnabled()) {
      return PrintResult.bluetoothOff;
    }

    try {
      final bool connected = await PrintBluetoothThermal.connectionStatus ||
          await PrintBluetoothThermal.connect(macPrinterAddress: config.mac);
      if (!connected) {
        return PrintResult.connectFailed;
      }

      final List<int> bytes = await buildReceipt(lines, paper: config.paper);
      final bool written = await PrintBluetoothThermal.writeBytes(bytes);
      return written ? PrintResult.ok : PrintResult.writeFailed;
    } catch (error) {
      debugPrint('Chop etish xatosi: $error');
      return PrintResult.connectFailed;
    } finally {
      // Keyingi chop etish uchun aloqa yangidan ochiladi (printer band qolmasin).
      try {
        await PrintBluetoothThermal.disconnect;
      } catch (_) {}
    }
  }

  /// ESC/POS baytlari: sarlavha markazda qalin, qolgani chapda, oxirida bo'sh joy va kesish.
  static Future<List<int>> buildReceipt(
    List<String> lines, {
    int paper = 58,
  }) async {
    final CapabilityProfile profile = await CapabilityProfile.load();
    final Generator generator =
        Generator(paper == 80 ? PaperSize.mm80 : PaperSize.mm58, profile);

    final List<int> bytes = <int>[];
    bytes.addAll(generator.reset());

    for (int i = 0; i < lines.length; i++) {
      final String text = printable(lines[i]);
      if (i == 0) {
        bytes.addAll(generator.text(
          text,
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
          ),
        ));
      } else {
        bytes.addAll(generator.text(text));
      }
    }

    bytes.addAll(generator.feed(3));
    bytes.addAll(generator.cut());
    return bytes;
  }

  static const Map<String, String> _cyrillic = <String, String>{
    'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'yo',
    'ж': 'zh', 'з': 'z', 'и': 'i', 'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm',
    'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u',
    'ф': 'f', 'х': 'kh', 'ц': 'ts', 'ч': 'ch', 'ш': 'sh', 'щ': 'sch',
    'ъ': '', 'ы': 'y', 'ь': '', 'э': 'e', 'ю': 'yu', 'я': 'ya', 'ў': "o'",
    'қ': 'q', 'ғ': "g'", 'ҳ': 'h',
  };

  /// Printer uchun xavfsiz ASCII matn (NBSP -> bo'sh joy, kirill -> lotin).
  @visibleForTesting
  static String printable(String input) {
    final StringBuffer out = StringBuffer();
    for (final int rune in input.runes) {
      final String ch = String.fromCharCode(rune);
      if (rune == 0x00A0 || rune == 0x202F || rune == 0x2009) {
        out.write(' ');
      } else if (<int>{0x2019, 0x02BB, 0x02BC, 0x2018, 0x0060, 0x00B4}
          .contains(rune)) {
        out.write("'");
      } else if (rune == 0x2212 || rune == 0x2013 || rune == 0x2014) {
        out.write('-');
      } else if (rune < 128) {
        out.write(ch);
      } else {
        final String lower = ch.toLowerCase();
        final String? mapped = _cyrillic[lower];
        if (mapped == null) {
          out.write('?');
        } else {
          out.write(lower == ch ? mapped : _capitalize(mapped));
        }
      }
    }
    return out.toString();
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}

final Provider<ReceiptPrinter> receiptPrinterProvider =
    Provider<ReceiptPrinter>(
  (Ref ref) => ReceiptPrinter(ref.watch(tokenStorageProvider)),
);
