import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/auth/state/app_lock_guard.dart';
import '../l10n/app_strings.dart';

/// Havolani tashqi ilovada ochadi (brauzer, telefon, Telegram, pochta).
/// Ochib bo'lmasa snackbar ko'rsatadi.
Future<void> openLink(BuildContext context, Uri uri) async {
  final AppStrings s = context.s;
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  bool opened = false;
  AppLockGuard.suspendFor(const Duration(minutes: 3));
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (!opened) {
    messenger.showSnackBar(SnackBar(content: Text(s.linkOpenFailed)));
  }
}
