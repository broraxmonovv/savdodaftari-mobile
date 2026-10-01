import 'package:bozorpro/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash renders brand and animates without errors',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SplashScreen())),
    );
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.text('Savdo Up'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Bootstrap tugamaguncha vaqtni oldinga suramiz (navigatsiya router'siz xatoga olib kelmasin)
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 7));
  });
}
