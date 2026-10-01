import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../auth/state/auth_providers.dart';
import '../auth/state/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();
  late final Animation<double> _fade =
      CurvedAnimation(parent: _intro, curve: Curves.easeOut);
  late final Animation<double> _scale = Tween<double>(begin: 0.86, end: 1)
      .animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutBack));

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Status bar va navigation bar ranglari
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.darkGreen,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Splash kamida 1.5 sekund ko'rinadi
    final Future<void> minSplash = Future<void>.delayed(
      const Duration(milliseconds: 1500),
    );

    // restore 5 sekunddan ko'p kutib qolmasin
    try {
      await Future.any<void>([
        ref.read(authControllerProvider.notifier).restore(),
        Future<void>.delayed(const Duration(seconds: 5)),
      ]);
    } catch (e) {
      debugPrint('Auth restore error: $e');
    }

    // Minimal splash vaqtini kutamiz
    await minSplash;

    if (!mounted) return;

    final AuthStatus status =
        ref.read(authControllerProvider).status;

    switch (status) {
      case AuthStatus.locked:
        context.go(AppRoutes.pinUnlock);
        break;

      case AuthStatus.needsProfile:
        context.go(AppRoutes.profileSetup);
        break;

      case AuthStatus.needsPin:
        context.go(AppRoutes.pinCreate);
        break;

      case AuthStatus.authenticated:
        context.go(AppRoutes.home);
        break;

      case AuthStatus.blocked:
        context.go(AppRoutes.blocked);
        break;

      case AuthStatus.unknown:
      case AuthStatus.unauthenticated:
        final bool seen =
        await ref.read(tokenStorageProvider).isOnboardingSeen();

        if (!mounted) return;

        // Birinchi ochilishda (til hali tanlanmagan va onboarding ko'rilmagan) avval til tanlanadi.
        final String? savedLocale =
            await ref.read(tokenStorageProvider).readLocale();

        if (!mounted) return;

        context.go(
          seen
              ? AppRoutes.phone
              : (savedLocale == null
                  ? AppRoutes.language
                  : AppRoutes.onboarding),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.brand,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[AppColors.primary, AppColors.darkGreen],
          ),
        ),
        child: Stack(
          children: <Widget>[
            // Dekorativ yumshoq doiralar
            Positioned(
              top: -size.width * 0.35,
              right: -size.width * 0.3,
              child: _Circle(size: size.width * 0.9, opacity: 0.08),
            ),
            Positioned(
              bottom: -size.width * 0.4,
              left: -size.width * 0.35,
              child: _Circle(size: size.width * 1.0, opacity: 0.07),
            ),
            Positioned(
              top: size.height * 0.16,
              left: 28,
              child: _Circle(size: 14, opacity: 0.22),
            ),
            Positioned(
              bottom: size.height * 0.24,
              right: 36,
              child: _Circle(size: 22, opacity: 0.16),
            ),

            // Markaziy logo, nom va slogan
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 56),
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _Logo(pulse: _pulse),
                        const SizedBox(height: 30),
                        Text(
                          s.appName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: Text(
                            s.slogan,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.82),
                              fontSize: 16,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Pastki ingichka progress
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: FadeTransition(
                opacity: _fade,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 120,
                      height: 4,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.22),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );
}

/// Logotip: oq yumaloq kvadrat ichida o'sish strelkasi, atrofida pulsatsiya halqasi.
class _Logo extends StatelessWidget {
  const _Logo({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedBuilder(
            animation: pulse,
            builder: (BuildContext context, Widget? _) {
              final double t = pulse.value;
              return Container(
                width: 112 + 56 * t,
                height: 112 + 56 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.28 * (1 - t)),
                    width: 2,
                  ),
                ),
              );
            },
          ),
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 32,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Icon(
                  Icons.trending_up_rounded,
                  size: 62,
                  color: AppColors.primary,
                ),
                Positioned(
                  right: 20,
                  bottom: 18,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
