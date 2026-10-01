import 'dart:io';

import 'package:bozorpro/core/theme/app_colors.dart';
import 'package:bozorpro/core/theme/app_theme.dart';
import 'package:bozorpro/core/widgets/widgets.dart';
import 'package:bozorpro/features/calculator/calculator_overlay.dart';
import 'package:bozorpro/features/scanner/scan_beep.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('scan beep asset exists, is a short valid wav', () {
    final File file = File('assets/sounds/scan_beep.wav');
    expect(file.existsSync(), isTrue);
    final List<int> bytes = file.readAsBytesSync();
    expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
    expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
    expect(bytes.length, lessThan(40 * 1024)); // qisqa signal
  });

  test('beep asset is declared in pubspec and path matches ScanBeep', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('assets/sounds/'));
    expect(pubspec, contains('audioplayers:'));
    expect(ScanBeep.asset, 'sounds/scan_beep.wav');
    expect(File('assets/${ScanBeep.asset}').existsSync(), isTrue);
  });

  for (final Brightness b in Brightness.values) {
    testWidgets('typed text is visible against field background ($b)',
        (WidgetTester tester) async {
      AppColors.apply(b);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(),
          home: Scaffold(
            body: Column(
              children: <Widget>[
                AppTextField(label: 'L', hint: 'H', controller: TextEditingController()),
                SearchField(hint: 'S', controller: TextEditingController()),
              ],
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField).first, 'abc');
      await tester.pump();

      final EditableText field = tester.widget<EditableText>(find.byType(EditableText).first);
      final Color text = field.style.color!;
      final Color fill = AppColors.card;
      expect(text, AppColors.textPrimary);
      // Matn va fon yorqinligi orasida yetarli farq (o'qiladigan kontrast)
      expect((text.computeLuminance() - fill.computeLuminance()).abs(), greaterThan(0.5));
    });
  }

  testWidgets('calculator overlay keeps the tree stable when enabled flips',
      (WidgetTester tester) async {
    final TextEditingController controller = TextEditingController();
    Widget app({required bool enabled}) => MaterialApp(
          home: CalculatorOverlay(
            enabled: enabled,
            child: Scaffold(body: TextField(controller: controller)),
          ),
        );

    await tester.pumpWidget(app(enabled: false));
    await tester.tap(find.byType(TextField));
    await tester.pump();
    final Element before = tester.element(find.byType(TextField));

    await tester.pumpWidget(app(enabled: true));
    await tester.pump();
    final Element after = tester.element(find.byType(TextField));

    // Kiritish maydoni qayta yaratilmagan (fokus/klaviatura yo'qolmaydi)
    expect(identical(before, after), isTrue);
    expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);
  });
}
