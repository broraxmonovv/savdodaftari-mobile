import 'package:flutter/material.dart';

/// Bitta rang sxemasi (yorug' yoki qorong'u).
class AppPalette {
  const AppPalette({
    required this.darkGreen,
    required this.lightGreen,
    required this.background,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.dangerSurface,
    required this.warningSurface,
    required this.infoSurface,
    required this.successSurface,
    required this.brightness,
  });

  final Brightness brightness;
  final Color darkGreen;
  final Color lightGreen;
  final Color background;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color dangerSurface;
  final Color warningSurface;
  final Color infoSurface;
  final Color successSurface;

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    darkGreen: Color(0xFF006B45),
    lightGreen: Color(0xFFE9F8F1),
    background: Color(0xFFF7F9FA),
    card: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF7A828A),
    border: Color(0xFFE6EAED),
    dangerSurface: Color(0xFFFDECEA),
    warningSurface: Color(0xFFFFF6E5),
    infoSurface: Color(0xFFEAF2FE),
    successSurface: Color(0xFFE9F8F1),
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    // Qorong'u fonda "to'q yashil" matn o'qilishi uchun ochroq tortadi.
    darkGreen: Color(0xFF5FD9A6),
    lightGreen: Color(0xFF16352A),
    background: Color(0xFF0F1214),
    card: Color(0xFF1A1E21),
    textPrimary: Color(0xFFECEFF1),
    textSecondary: Color(0xFF9AA3AB),
    border: Color(0xFF2A3035),
    dangerSurface: Color(0xFF3A1D1B),
    warningSurface: Color(0xFF3A2E14),
    infoSurface: Color(0xFF172B45),
    successSurface: Color(0xFF16352A),
  );
}

/// BozorPro brend ranglari — TZ v3, 0-bo'lim (Global design system).
///
/// Uslub: yashil akcent, minimalist SaaS ko'rinish. Brend/status ranglari
/// ikkala rejimda bir xil (`const`), sirt va matn ranglari esa joriy
/// [AppPalette] ga qarab o'zgaradi ([apply] orqali almashtiriladi).
abstract final class AppColors {
  static AppPalette _palette = AppPalette.light;

  /// Joriy rejim: qorong'u bo'lsa true.
  static bool get isDark => _palette.brightness == Brightness.dark;

  static AppPalette get palette => _palette;

  /// Rang sxemasini almashtiradi. Ilova ildizi tema o'zgarganda chaqiradi va
  /// butun daraxtni qayta quradi.
  static void apply(Brightness brightness) {
    _palette =
        brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
  }

  /// Asosiy tugmalar, aktiv holatlar, brend.
  static const Color primary = Color(0xFF00A86B);

  /// To'q yashil brend foni (splash, banner) — ikkala rejimda ham bir xil.
  static const Color brand = Color(0xFF006B45);

  /// Qarz, xatolik, kam qoldiq.
  static const Color danger = Color(0xFFE53935);

  /// Ogohlantirish.
  static const Color warning = Color(0xFFF5A623);

  /// Ma'lumot, Telegram/SMS.
  static const Color info = Color(0xFF2F80ED);

  /// To'lov, tasdiq.
  static const Color success = Color(0xFF00A86B);

  /// Splash fon, bosilgan holat, sarlavha aksentlari.
  static Color get darkGreen => _palette.darkGreen;

  /// Yengil fonlar, tanlangan chip, success card fon.
  static Color get lightGreen => _palette.lightGreen;

  /// Ekran foni.
  static Color get background => _palette.background;

  /// Kartalar, input fon.
  static Color get card => _palette.card;

  /// Asosiy matn.
  static Color get textPrimary => _palette.textPrimary;

  /// Ikkilamchi matn, placeholder.
  static Color get textSecondary => _palette.textSecondary;

  /// Chegara chizig'i, input border.
  static Color get border => _palette.border;

  // Status kartalari uchun yengil fonlar.
  static Color get dangerSurface => _palette.dangerSurface;
  static Color get warningSurface => _palette.warningSurface;
  static Color get infoSurface => _palette.infoSurface;
  static Color get successSurface => _palette.successSurface;
}
