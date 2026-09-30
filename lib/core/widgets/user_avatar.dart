import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Foydalanuvchi profil rasmi; rasm yo'q yoki yuklanmasa — ism bosh harfi.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 44,
  });

  final String name;
  final String? imageUrl;
  final double size;

  String get _initial {
    final String trimmed = name.trim();
    return trimmed.isEmpty ? '—' : trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final Widget fallback = Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initial,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.darkGreen,
              fontSize: size * 0.4,
            ),
      ),
    );

    final String? url = imageUrl;
    if (url == null || url.isEmpty) {
      return fallback;
    }

    return ClipOval(
      child: Image.network(
        url,
        height: size,
        width: size,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext _, Object __, StackTrace? ___) => fallback,
        loadingBuilder:
            (BuildContext _, Widget child, ImageChunkEvent? progress) =>
                progress == null ? child : fallback,
      ),
    );
  }
}
