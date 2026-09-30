import 'package:bozorpro/features/printing/receipt_printer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('printable converts NBSP, curly apostrophes and Cyrillic to ASCII', () {
    expect(ReceiptPrinter.printable('150 000 so’m'), "150 000 so'm");
    expect(ReceiptPrinter.printable('Футболка'), 'Futbolka');
    expect(ReceiptPrinter.printable('Итого: 1−'), 'Itogo: 1-');
    expect(ReceiptPrinter.printable('★'), '?');
  });

  test('PrinterConfig encode/decode round trip', () {
    const PrinterConfig config =
        PrinterConfig(mac: '00:11:22:33:44:55', name: 'XP-58', paper: 80);
    final PrinterConfig? back = PrinterConfig.decode(config.encode());
    expect(back?.mac, config.mac);
    expect(back?.name, 'XP-58');
    expect(back?.paper, 80);
    expect(PrinterConfig.decode(null), isNull);
    expect(PrinterConfig.decode('bad'), isNull);
  });
}
