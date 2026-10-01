import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/state/auth_providers.dart';
import '../features/auth/state/auth_state.dart';
import '../features/calculator/calculator_overlay.dart';
import 'locale_provider.dart';
import 'router.dart';
import 'theme_provider.dart';

class SavdoUpApp extends ConsumerStatefulWidget {
  const SavdoUpApp({super.key});

  @override
  ConsumerState<SavdoUpApp> createState() => _SavdoUpAppState();
}

class _SavdoUpAppState extends ConsumerState<SavdoUpApp>
    with WidgetsBindingObserver {
  Brightness? _applied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// "Tizim bo'yicha" rejimida qurilma mavzusi o'zgarsa ilova ham o'zgaradi.
  @override
  void didChangePlatformBrightness() {
    if (ref.read(themeModeProvider) == ThemeMode.system && mounted) {
      setState(() {});
    }
  }

  Brightness _effectiveBrightness(ThemeMode mode) => switch (mode) {
        ThemeMode.light => Brightness.light,
        ThemeMode.dark => Brightness.dark,
        ThemeMode.system =>
          WidgetsBinding.instance.platformDispatcher.platformBrightness,
      };

  /// `AppColors` statik ranglar ishlatiladi, shuning uchun rejim almashganda
  /// butun element daraxti qayta quriladi (navigatsiya holati saqlanadi).
  void _rebuildAll() {
    void visit(Element element) {
      element.markNeedsBuild();
      element.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeMode mode = ref.watch(themeModeProvider);
    final Brightness brightness = _effectiveBrightness(mode);

    if (_applied != brightness) {
      final bool first = _applied == null;
      AppColors.apply(brightness);
      _applied = brightness;
      if (!first) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildAll());
      }
    }

    // Kalkulyator faqat telefon orqali ro'yxatdan o'tib (kirib) bo'lingach,
    // ya'ni ilovaning hamma ichki sahifalarida ko'rinadi.
    final bool showCalculator =
        ref.watch(authControllerProvider).status == AuthStatus.authenticated;

    final Locale selected = ref.watch(localeControllerProvider);
    final String localeKey = AppStrings.keyOf(selected);

    return MaterialApp.router(
      title: 'Savdo Up',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      routerConfig: appRouter,
      // Til sozlamalardan almashtiriladi va qurilmada saqlanadi.
      // Material vidjetlari uchun oddiy `uz`/`ru` locale; kirill matnlari AppStringsDelegate(key) orqali.
      locale: Locale(selected.languageCode),
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: <LocalizationsDelegate<Object>>[
        AppStringsDelegate(key: localeKey),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Hamma sahifada ekran chetida turuvchi kalkulyator.
      builder: (BuildContext context, Widget? child) => CalculatorOverlay(
        enabled: showCalculator,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
