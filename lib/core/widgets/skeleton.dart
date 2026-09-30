import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Skeleton (placeholder) yuklanish holati: ma'lumot kelguncha yoki yangilash
/// paytida sahifa shakli yaltirab ko'rinadi. Barcha skeleton bloklari bitta
/// [SkeletonShimmer] ichida animatsiya qilinadi.
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color base = AppColors.border;
    final Color highlight = AppColors.card.withOpacity(0.85);

    return Semantics(
      label: 'loading',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          child: widget.child,
          builder: (BuildContext context, Widget? child) {
            final double slide = _controller.value * 3 - 1;
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (Rect bounds) => LinearGradient(
                begin: Alignment(slide - 1, -0.3),
                end: Alignment(slide + 1, 0.3),
                colors: <Color>[base, highlight, base],
                stops: const <double>[0.25, 0.5, 0.75],
              ).createShader(bounds),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

/// Bitta kulrang blok (matn qatori, rasm, karta ...).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 8,
    this.circle = false,
  });

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

/// Ro'yxat ko'rinishidagi sahifalar uchun (mijozlar, qarzlar, savdolar ...).
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.count = 8,
    this.shrinkWrap = false,
    this.leadingSquare = false,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
  });

  final int count;
  final bool shrinkWrap;

  /// Mahsulot rasmi kabi yumaloq burchakli kvadrat (aks holda doira).
  final bool leadingSquare;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: count,
        separatorBuilder: (BuildContext _, int __) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (BuildContext _, int index) => AppCardShell(
          child: Row(
            children: <Widget>[
              SkeletonBox(
                height: 44,
                width: 44,
                circle: !leadingSquare,
                radius: 12,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SkeletonBox(width: 110.0 + (index % 3) * 34, height: 13),
                    const SizedBox(height: 9),
                    SkeletonBox(width: 70.0 + (index % 2) * 28, height: 10),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const SkeletonBox(width: 64, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

/// Statistik kartalar + ro'yxat (hisobotlar, bosh sahifa).
class SkeletonCards extends StatelessWidget {
  const SkeletonCards({super.key});

  @override
  Widget build(BuildContext context) {
    Widget stat() => const Expanded(
          child: AppCardShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonBox(height: 36, circle: true),
                SizedBox(height: AppSpacing.md),
                SkeletonBox(width: 80, height: 11),
                SizedBox(height: 10),
                SkeletonBox(width: 110, height: 20),
              ],
            ),
          ),
        );

    return SkeletonShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        children: <Widget>[
          Row(children: <Widget>[
            stat(),
            const SizedBox(width: AppSpacing.md),
            stat()
          ]),
          const SizedBox(height: AppSpacing.md),
          Row(children: <Widget>[
            stat(),
            const SizedBox(width: AppSpacing.md),
            stat()
          ]),
          const SizedBox(height: AppSpacing.md),
          const AppCardShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonBox(width: 120, height: 14),
                SizedBox(height: AppSpacing.md),
                SkeletonBox(height: 11),
                SizedBox(height: 10),
                SkeletonBox(height: 11),
                SizedBox(height: 10),
                SkeletonBox(width: 180, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bosh sahifa: sarlavha, banner karusel, statistika va tezkor tugmalar.
class SkeletonHome extends StatelessWidget {
  const SkeletonHome({super.key});

  @override
  Widget build(BuildContext context) {
    Widget stat() => const Expanded(
          child: AppCardShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonBox(height: 36, circle: true),
                SizedBox(height: AppSpacing.md),
                SkeletonBox(width: 80, height: 11),
                SizedBox(height: 10),
                SkeletonBox(width: 110, height: 20),
              ],
            ),
          ),
        );

    return SkeletonShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: <Widget>[
          const Row(
            children: <Widget>[
              SkeletonBox(height: 44, circle: true),
              SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SkeletonBox(width: 90, height: 10),
                  SizedBox(height: 8),
                  SkeletonBox(width: 140, height: 15),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonBox(height: 130, radius: 18),
          const SizedBox(height: AppSpacing.lg),
          Row(children: <Widget>[
            stat(),
            const SizedBox(width: AppSpacing.md),
            stat()
          ]),
          const SizedBox(height: AppSpacing.md),
          Row(children: <Widget>[
            stat(),
            const SizedBox(width: AppSpacing.md),
            stat()
          ]),
          const SizedBox(height: AppSpacing.xl),
          const Row(
            children: <Widget>[
              Expanded(child: SkeletonBox(height: 96, radius: 16)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: SkeletonBox(height: 96, radius: 16)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: SkeletonBox(height: 96, radius: 16)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: SkeletonBox(height: 96, radius: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Batafsil sahifalar uchun: yuqorida katta karta, pastda bir necha qator.
class SkeletonDetail extends StatelessWidget {
  const SkeletonDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: <Widget>[
          const AppCardShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonBox(width: 100, height: 11),
                SizedBox(height: 12),
                SkeletonBox(width: 160, height: 26),
                SizedBox(height: 16),
                SkeletonBox(height: 11),
                SizedBox(height: 10),
                SkeletonBox(width: 200, height: 11),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonBox(width: 130, height: 16),
          const SizedBox(height: AppSpacing.md),
          for (int i = 0; i < 4; i++) ...<Widget>[
            const AppCardShell(
              child: Row(
                children: <Widget>[
                  SkeletonBox(height: 40, circle: true),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: SkeletonBox(height: 12)),
                  SizedBox(width: AppSpacing.md),
                  SkeletonBox(width: 56, height: 12),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// Skeleton ichidagi karta qobig'i (soya va chegara bilan, bosilmaydi).
class AppCardShell extends StatelessWidget {
  const AppCardShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }
}

/// "Yangilash paytida ham skeleton ko'rsat": `RefreshIndicator.onRefresh`
/// uchun `refreshWrap(load)` ishlatiladi, [refreshing] true bo'lganda sahifa
/// skeleton ko'rsatadi.
mixin RefreshSkeletonMixin<T extends StatefulWidget> on State<T> {
  bool refreshing = false;

  Future<void> Function() refreshWrap(Future<void> Function() load) {
    return () async {
      if (mounted) {
        setState(() => refreshing = true);
      }
      try {
        await load();
      } finally {
        if (mounted) {
          setState(() => refreshing = false);
        }
      }
    };
  }
}
