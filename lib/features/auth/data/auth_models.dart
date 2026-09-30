import 'package:flutter/foundation.dart';

/// OTP so'rovining maqsadi — backend `purpose` parametri.
enum OtpPurpose { login, resetPin }

extension OtpPurposeApi on OtpPurpose {
  String get value => switch (this) {
        OtpPurpose.login => 'login',
        OtpPurpose.resetPin => 'reset_pin',
      };
}

/// Foydalanuvchi tarifi: Bepul, Standart (savdo + ombor 12 000 so'm) yoki Pro.
enum UserPlan {
  free,
  standard,
  pro;

  static UserPlan fromApi(String? value) => switch (value) {
        'standard' => UserPlan.standard,
        'pro' => UserPlan.pro,
        _ => UserPlan.free,
      };

  /// Backend `plan` qiymati (checkout so'rovi uchun).
  String get apiValue => name;
}

@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    this.shopName,
    this.businessType,
    this.locale,
    this.hasPin = false,
    this.plan = UserPlan.free,
    this.planExpiresAt,
    this.isTrial = false,
    this.avatarUrl,
    this.smsReminders = true,
    bool? isProfileComplete,
  }) : _isProfileComplete = isProfileComplete;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final Object? profileComplete = json['is_profile_complete'];
    return AuthUser(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      shopName: json['shop_name']?.toString(),
      businessType: json['business_type']?.toString(),
      locale: json['locale']?.toString(),
      hasPin: json['has_pin'] == true,
      plan: UserPlan.fromApi(json['plan']?.toString()),
      planExpiresAt: DateTime.tryParse(
        json['plan_expires_at']?.toString() ?? '',
      ),
      isTrial: json['plan_is_trial'] == true,
      avatarUrl: json['avatar_url']?.toString(),
      smsReminders: json['sms_reminders'] != false,
      isProfileComplete: profileComplete is bool ? profileComplete : null,
    );
  }

  final int id;
  final String name;
  final String phone;
  final String? shopName;
  final String? businessType;
  final String? locale;
  final bool hasPin;

  /// Joriy tarif (backend `plan`: free | standard | pro).
  final UserPlan plan;

  /// Pullik tarif amal qilish muddati (free uchun null).
  final DateTime? planExpiresAt;

  /// Hozirgi tarif — bepul sinov Standarti (yangi foydalanuvchilarga 14 kun).
  final bool isTrial;

  /// Profil rasmi (yuklanmagan bo'lsa null).
  final String? avatarUrl;

  /// Qarzdor mijozlarga avtomatik SMS eslatma yuborilsinmi.
  final bool smsReminders;
  final bool? _isProfileComplete;

  /// Savdo va ombor bo'limlari ochiqmi (Standart yoki Pro).
  bool get hasSalesAndInventory => plan != UserPlan.free;

  bool get isPro => plan == UserPlan.pro;

  /// Backend `is_profile_complete` bergan bo'lsa — o'sha qiymat,
  /// aks holda ism kiritilganligi bo'yicha aniqlanadi.
  bool get isProfileComplete =>
      _isProfileComplete ?? name.trim().isNotEmpty;

  AuthUser copyWith({
    String? name,
    String? shopName,
    String? businessType,
    String? locale,
    bool? hasPin,
    UserPlan? plan,
    DateTime? planExpiresAt,
    bool? isTrial,
    bool? smsReminders,
  }) {
    return AuthUser(
      id: id,
      name: name ?? this.name,
      phone: phone,
      shopName: shopName ?? this.shopName,
      businessType: businessType ?? this.businessType,
      locale: locale ?? this.locale,
      hasPin: hasPin ?? this.hasPin,
      plan: plan ?? this.plan,
      planExpiresAt: planExpiresAt ?? this.planExpiresAt,
      isTrial: isTrial ?? this.isTrial,
      avatarUrl: avatarUrl,
      smsReminders: smsReminders ?? this.smsReminders,
      isProfileComplete: _isProfileComplete,
    );
  }
}

/// `POST /auth/otp/send` javobi.
@immutable
class OtpSendResult {
  const OtpSendResult({
    required this.expiresIn,
    required this.resendAfter,
    this.debugCode,
  });

  factory OtpSendResult.fromJson(Map<String, dynamic> json, {int fallbackResend = 45}) {
    return OtpSendResult(
      expiresIn: int.tryParse(json['expires_in']?.toString() ?? '') ?? 120,
      resendAfter:
          int.tryParse(json['resend_after']?.toString() ?? '') ?? fallbackResend,
      debugCode: json['debug_code']?.toString(),
    );
  }

  /// Kod amal qilish muddati (soniya) — TZ 37.2: 60–120 s.
  final int expiresIn;

  /// Qayta yuborish tugmasi faollashadigan vaqt (soniya).
  final int resendAfter;

  /// Faqat dev muhitda (`OTP_DEBUG_CODE`) keladi.
  final String? debugCode;
}

/// `POST /auth/otp/verify` javobi.
@immutable
class OtpVerifyResult {
  const OtpVerifyResult({
    required this.token,
    required this.isNew,
    required this.user,
  });

  factory OtpVerifyResult.fromJson(Map<String, dynamic> json) {
    final dynamic user = json['user'];
    return OtpVerifyResult(
      token: json['token']?.toString() ?? '',
      isNew: json['is_new'] == true,
      user: AuthUser.fromJson(
        user is Map ? user.cast<String, dynamic>() : <String, dynamic>{},
      ),
    );
  }

  final String token;

  /// true — foydalanuvchi shu OTP bilan birinchi marta ro'yxatdan o'tdi.
  final bool isNew;

  final AuthUser user;
}

@immutable
class OtpArgs {
  const OtpArgs({
    required this.phone,
    required this.resendAfter,
    required this.expiresIn,
    required this.purpose,
  });

  final String phone;
  final int resendAfter;
  final int expiresIn;
  final OtpPurpose purpose;
}