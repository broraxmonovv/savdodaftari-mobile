import 'package:bozorpro/app/locale_provider.dart';
import 'package:bozorpro/core/l10n/app_strings.dart';
import 'package:bozorpro/features/language/language_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale selected = ref.watch(localeControllerProvider);
    return MaterialApp(
      locale: Locale(selected.languageCode),
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: <LocalizationsDelegate<Object>>[
        AppStringsDelegate(key: AppStrings.keyOf(selected)),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LanguageScreen(),
    );
  }
}

void main() {
  testWidgets('language screen switches the whole screen language immediately',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(380, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: _App()));
    await tester.pumpAndSettle();

    expect(find.text('Tilni tanlang'), findsOneWidget);
    expect(find.text("O'zbekcha"), findsOneWidget);
    expect(find.text('Ўзбекча'), findsOneWidget);
    expect(find.text('Русский'), findsOneWidget);

    await tester.tap(find.text('Ўзбекча'));
    await tester.pumpAndSettle();
    expect(find.text('Тилни танланг'), findsOneWidget);
    expect(find.text('Давом этиш'), findsOneWidget);

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.text('Выберите язык'), findsOneWidget);
    expect(find.text('Продолжить'), findsOneWidget);

    await tester.tap(find.text("O'zbekcha"));
    await tester.pumpAndSettle();
    expect(find.text('Tilni tanlang'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
