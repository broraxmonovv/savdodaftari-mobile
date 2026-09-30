import 'package:bozorpro/core/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Map<String, Widget> variants = <String, Widget>{
    'list': const SkeletonList(),
    'square list': const SkeletonList(leadingSquare: true, count: 3),
    'cards': const SkeletonCards(),
    'home': const SkeletonHome(),
    'detail': const SkeletonDetail(),
  };

  variants.forEach((String name, Widget widget) {
    testWidgets('skeleton $name renders and animates without errors',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      await tester.pump(const Duration(milliseconds: 700));

      expect(tester.takeException(), isNull);
      expect(find.byType(SkeletonShimmer), findsOneWidget);
    });
  });
}
