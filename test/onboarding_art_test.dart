import 'package:bozorpro/features/onboarding/onboarding_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (int page = 0; page < 4; page++) {
    testWidgets('onboarding art page $page renders without overflow',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: OnboardingArt(page: page),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingArt), findsOneWidget);
    });
  }
}
