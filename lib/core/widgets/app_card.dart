import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Ilovadagi barcha kartalar uchun asos: oq fon, rounded corners,
/// juda yengil shadow. Card-based layout'ning yagona manbasi.
class AppCard extends StatelessWidget {
  AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.borderColor,
    this.borderRadius = AppRadius.card,
    this.shadows = AppShadows.soft,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  /// Berilmasa joriy rejimdagi karta rangi.
  final Color? color;
  final Color? borderColor;
  final BorderRadius borderRadius;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius: borderRadius,
        boxShadow: shadows,
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
