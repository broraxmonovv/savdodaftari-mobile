import 'package:bozorpro/core/theme/app_colors.dart';
import 'package:bozorpro/core/theme/app_theme.dart';
import 'package:bozorpro/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final Brightness b in Brightness.values) {
    testWidgets('money input leaves room for the typed amount ($b)', (WidgetTester tester) async {
      AppColors.apply(b);
      await tester.binding.setSurfaceSize(const Size(380, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final TextEditingController controller = TextEditingController();
      int? parsed;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: MoneyInput(
                label: 'Summa',
                controller: controller,
                onChanged: (int v) => parsed = v,
              ),
            ),
          ),
        ),
      );

      // Matn maydoni ichki kengligi: "so'm" butun maydonni egallab olmagan bo'lishi kerak
      final Size editable = tester.getSize(find.byType(EditableText));
      expect(editable.width, greaterThan(150), reason: 'summa yoziladigan joy juda tor');

      await tester.enterText(find.byType(TextField), '1500000');
      await tester.pump();
      expect(controller.text.replaceAll(' ', ' '), '1 500 000');
      expect(parsed, 1500000);

      // Suffix matn maydonidan o'ngda, summa bilan ustma-ust tushmaydi
      final Rect suffix = tester.getRect(find.text("so'm"));
      final Rect input = tester.getRect(find.byType(EditableText));
      expect(suffix.left, greaterThanOrEqualTo(input.right - 1));
    });
  }
}
