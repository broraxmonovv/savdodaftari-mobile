import 'package:flutter/foundation.dart';

num _num(Object? v) => num.tryParse(v?.toString() ?? '') ?? 0;

/// Bitta valyuta kursi (`GET /currencies`): 1 [nominal] [code] = [rate] so'm.
@immutable
class CurrencyRate {
  const CurrencyRate({
    required this.code,
    required this.name,
    required this.nameRu,
    required this.nominal,
    required this.rate,
    required this.diff,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) => CurrencyRate(
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        nameRu: json['name_ru']?.toString() ?? '',
        nominal: _num(json['nominal']).toInt(),
        rate: _num(json['rate']).toDouble(),
        diff: _num(json['diff']).toDouble(),
      );

  final String code;
  final String name;
  final String nameRu;
  final int nominal;
  final double rate;

  /// Kechagi kursga nisbatan o'zgarish.
  final double diff;

  String localizedName(String languageCode) =>
      languageCode == 'ru' && nameRu.isNotEmpty ? nameRu : name;
}

@immutable
class CurrencyRates {
  const CurrencyRates({required this.rates, this.updatedAt});

  factory CurrencyRates.fromJson(Map<String, dynamic> json) {
    final Object? rates = json['rates'];
    return CurrencyRates(
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      rates: rates is List
          ? rates
              .whereType<Map<Object?, Object?>>()
              .map((Map<Object?, Object?> e) =>
                  CurrencyRate.fromJson(e.cast<String, dynamic>()))
              .toList()
          : const <CurrencyRate>[],
    );
  }

  final List<CurrencyRate> rates;
  final DateTime? updatedAt;
}

/// `GET /support`
@immutable
class SupportInfo {
  const SupportInfo({
    required this.phone,
    required this.telegram,
    required this.email,
    required this.workingHours,
  });

  factory SupportInfo.fromJson(Map<String, dynamic> json) => SupportInfo(
        phone: json['phone']?.toString() ?? '',
        telegram: json['telegram']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        workingHours: json['working_hours']?.toString() ?? '',
      );

  final String phone;
  final String telegram;
  final String email;
  final String workingHours;
}

/// `GET /guides` elementi.
@immutable
class GuideVideo {
  const GuideVideo({required this.id, required this.title, required this.url});

  factory GuideVideo.fromJson(Map<String, dynamic> json) => GuideVideo(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
      );

  final String id;
  final String title;
  final String url;
}

/// `GET /referral`
@immutable
class ReferralInfo {
  const ReferralInfo({
    required this.code,
    required this.link,
    required this.percent,
    required this.invitedCount,
    required this.payingCount,
    required this.earnedTotal,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) => ReferralInfo(
        code: json['code']?.toString() ?? '',
        link: json['link']?.toString() ?? '',
        percent: _num(json['percent']).toDouble(),
        invitedCount: _num(json['invited_count']).toInt(),
        payingCount: _num(json['paying_count']).toInt(),
        earnedTotal: _num(json['earned_total']).toDouble(),
      );

  final String code;
  final String link;
  final double percent;
  final int invitedCount;
  final int payingCount;
  final double earnedTotal;
}

/// `GET /bonuses` elementi.
@immutable
class BonusEntry {
  const BonusEntry({
    required this.type,
    required this.amount,
    required this.from,
    this.createdAt,
  });

  factory BonusEntry.fromJson(Map<String, dynamic> json) => BonusEntry(
        type: json['type']?.toString() ?? 'referral',
        amount: _num(json['amount']).toDouble(),
        from: json['from']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );

  final String type;
  final double amount;
  final String from;
  final DateTime? createdAt;

  bool get isReversal => type == 'reversal';
}

@immutable
class BonusSummary {
  const BonusSummary({required this.balance, required this.entries});

  final double balance;
  final List<BonusEntry> entries;
}
