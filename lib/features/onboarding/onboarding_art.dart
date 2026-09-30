import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// Onboarding sahifalari uchun zamonaviy illyustratsiyalar (kodda chizilgan:
/// yumshoq fon shakllari, kartalar va suzib turuvchi belgilar).
class OnboardingArt extends StatefulWidget {
  const OnboardingArt({super.key, required this.page});

  /// 0 — qarz daftari, 1 — savdo va ombor, 2 — ovoz, 3 — hisobot.
  final int page;

  @override
  State<OnboardingArt> createState() => _OnboardingArtState();
}

class _OnboardingArtState extends State<OnboardingArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.05,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: <Widget>[
          const _Backdrop(),
          AnimatedBuilder(
            animation: _float,
            builder: (BuildContext context, Widget? _) {
              final double t = Curves.easeInOut.transform(_float.value);
              return switch (widget.page) {
                0 => _DebtArt(t: t),
                1 => _SalesArt(t: t),
                2 => _VoiceArt(t: t),
                _ => _ReportArt(t: t),
              };
            },
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: <Color>[
                AppColors.lightGreen,
                AppColors.lightGreen.withOpacity(0.25),
              ],
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 24,
          child: _Blob(size: 26, color: AppColors.primary.withOpacity(0.18)),
        ),
        Positioned(
          bottom: 18,
          left: 12,
          child: _Blob(size: 38, color: AppColors.info.withOpacity(0.14)),
        ),
        Positioned(
          bottom: 44,
          right: 4,
          child: _Blob(size: 16, color: AppColors.warning.withOpacity(0.30)),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// Suzib turuvchi element: [t] (0..1) bo'yicha yuqoriga-pastga siljiydi.
class _Floating extends StatelessWidget {
  const _Floating({
    required this.t,
    required this.child,
    this.amplitude = 8,
    this.phase = 0,
  });

  final double t;
  final double amplitude;
  final double phase;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double dy = math.sin((t + phase) * math.pi) * amplitude;
    return Transform.translate(offset: Offset(0, dy), child: child);
  }
}

BoxDecoration _cardDecoration({Color? color}) => BoxDecoration(
      color: color ?? AppColors.card,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x1A101828),
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ],
    );

class _Avatar extends StatelessWidget {
  const _Avatar(this.letter, this.color);

  final String letter;
  final Color color;

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: 16,
        backgroundColor: color.withOpacity(0.15),
        child: Text(
          letter,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      );
}

class _Line extends StatelessWidget {
  const _Line(this.width, {this.height = 8});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(8),
        ),
      );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.color, this.size = 46});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size / 3),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.52),
      );
}

// ——— 1: Qarz daftari ———————————————————————————————————————————————
class _DebtArt extends StatelessWidget {
  const _DebtArt({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    Widget row(String letter, Color color, double name, String amount) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: <Widget>[
              _Avatar(letter, color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _Line(name, height: 9),
                    const SizedBox(height: 6),
                    const _Line(46, height: 6),
                  ],
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: <Widget>[
        _Floating(
          t: t,
          amplitude: 5,
          child: Container(
            width: 236,
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                row('A', AppColors.danger, 84, '250 000'),
                row('V', AppColors.warning, 64, '120 000'),
                row('S', AppColors.info, 96, '75 000'),
                row('D', AppColors.primary, 70, '0'),
              ],
            ),
          ),
        ),
        Positioned(
          top: 18,
          right: 8,
          child: _Floating(
            t: t,
            phase: 0.5,
            child: _Badge(
              icon: Icons.notifications_active_rounded,
              color: AppColors.warning,
            ),
          ),
        ),
        Positioned(
          bottom: 22,
          left: 6,
          child: _Floating(
            t: t,
            phase: 0.25,
            amplitude: 10,
            child: _Badge(
              icon: Icons.menu_book_rounded,
              color: AppColors.primary,
              size: 54,
            ),
          ),
        ),
      ],
    );
  }
}

// ——— 2: Savdo, ombor, skaner ——————————————————————————————————————————
class _SalesArt extends StatelessWidget {
  const _SalesArt({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    Widget tile(IconData icon, Color color) => Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 30),
        );

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: <Widget>[
        _Floating(
          t: t,
          amplitude: 5,
          child: Container(
            width: 236,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    tile(Icons.checkroom_rounded, AppColors.info),
                    tile(Icons.local_drink_rounded, AppColors.primary),
                    tile(Icons.cookie_rounded, AppColors.warning),
                  ],
                ),
                const SizedBox(height: 14),
                // Shtrix-kod chiziqlari
                SizedBox(
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      for (int i = 0; i < 26; i++)
                        Container(
                          width: i % 3 == 0 ? 4 : 2,
                          color: AppColors.textPrimary,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    '1 250 000',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 4,
          child: _Floating(
            t: t,
            phase: 0.4,
            child: _Badge(
              icon: Icons.qr_code_scanner_rounded,
              color: AppColors.info,
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 4,
          child: _Floating(
            t: t,
            phase: 0.1,
            amplitude: 10,
            child: _Badge(
              icon: Icons.print_rounded,
              color: AppColors.danger,
              size: 52,
            ),
          ),
        ),
      ],
    );
  }
}

// ——— 3: Ovozli boshqaruv ———————————————————————————————————————————
class _VoiceArt extends StatelessWidget {
  const _VoiceArt({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: <Widget>[
        // Ovoz to'lqinlari
        for (int i = 0; i < 3; i++)
          Container(
            width: 120.0 + i * 46 + t * 10,
            height: 120.0 + i * 46 + t * 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.22 - i * 0.06),
                width: 2,
              ),
            ),
          ),
        _Floating(
          t: t,
          amplitude: 4,
          child: Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.primary, AppColors.darkGreen],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 52),
          ),
        ),
        Positioned(
          top: 6,
          left: 0,
          right: 0,
          child: _Floating(
            t: t,
            phase: 0.5,
            amplitude: 5,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 250),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: _cardDecoration(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.format_quote_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        s.onboardingVoiceExample,
                        style: textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          child: _Floating(
            t: t,
            phase: 0.2,
            amplitude: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.pill,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Ali aka · 150 000',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ——— 4: Hisobot ———————————————————————————————————————————————————
class _ReportArt extends StatelessWidget {
  const _ReportArt({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    const List<double> bars = <double>[0.35, 0.55, 0.42, 0.7, 0.6, 0.88, 0.75];

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: <Widget>[
        _Floating(
          t: t,
          amplitude: 5,
          child: Container(
            width: 240,
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '+ 2 450 000',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                const _Line(70, height: 7),
                const SizedBox(height: 16),
                SizedBox(
                  height: 96,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      for (int i = 0; i < bars.length; i++)
                        Container(
                          width: 22,
                          height: 96 * bars[i],
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: <Color>[
                                AppColors.primary.withOpacity(0.55),
                                i == bars.length - 2
                                    ? AppColors.primary
                                    : AppColors.primary.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 14,
          right: 4,
          child: _Floating(
            t: t,
            phase: 0.3,
            child: _Badge(
              icon: Icons.trending_up_rounded,
              color: AppColors.primary,
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 2,
          child: _Floating(
            t: t,
            phase: 0.7,
            amplitude: 10,
            child: _Badge(
              icon: Icons.cloud_done_rounded,
              color: AppColors.info,
              size: 52,
            ),
          ),
        ),
      ],
    );
  }
}
