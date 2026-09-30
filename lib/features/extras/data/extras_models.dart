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
    this.plan,
    this.createdAt,
  });

  factory BonusEntry.fromJson(Map<String, dynamic> json) => BonusEntry(
        type: json['type']?.toString() ?? 'referral',
        amount: _num(json['amount']).toDouble(),
        from: json['from']?.toString() ?? '',
        plan: json['plan']?.toString(),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );

  final String type;
  final double amount;
  final String from;

  /// `plan_payment` uchun tarif: standard | pro.
  final String? plan;
  final DateTime? createdAt;

  /// Backend turlari: referral, reversal, plan_payment, withdrawal,
  /// withdrawal_refund. Balansni kamaytiradigan amallar (manfiy) qizil.
  bool get isReversal => type == 'reversal';
  bool get isNegative => amount < 0;
}

/// Yechib olish so'rovi holati.
enum WithdrawalStatus {
  pending,
  paid,
  rejected;

  static WithdrawalStatus fromApi(String? value) => switch (value) {
        'paid' => WithdrawalStatus.paid,
        'rejected' => WithdrawalStatus.rejected,
        _ => WithdrawalStatus.pending,
      };
}

/// `GET /withdrawals` elementi (karta maskalangan: `8600 **** **** 1234`).
@immutable
class WithdrawalRequest {
  const WithdrawalRequest({
    required this.amount,
    required this.card,
    required this.status,
    this.adminNote,
    this.createdAt,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) =>
      WithdrawalRequest(
        amount: _num(json['amount']).toDouble(),
        card: json['card']?.toString() ?? '',
        status: WithdrawalStatus.fromApi(json['status']?.toString()),
        adminNote: json['admin_note']?.toString(),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );

  final double amount;
  final String card;
  final WithdrawalStatus status;
  final String? adminNote;
  final DateTime? createdAt;
}

@immutable
class WithdrawalList {
  const WithdrawalList({
    required this.items,
    required this.balance,
    required this.minWithdrawal,
  });

  final List<WithdrawalRequest> items;
  final double balance;
  final double minWithdrawal;
}

@immutable
class BonusSummary {
  const BonusSummary({required this.balance, required this.entries});

  final double balance;
  final List<BonusEntry> entries;
}

/// Admin yuborgan bildirishnoma (`GET /announcements`).
@immutable
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: _num(json['id']).toInt(),
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        isRead: json['is_read'] == true,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );

  final int id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;
}

@immutable
class AnnouncementList {
  const AnnouncementList({required this.items, required this.unreadCount});

  final List<Announcement> items;
  final int unreadCount;
}

/// `GET /notifications` dagi hisoblangan ogohlantirish: muddati o'tgan qarz,
/// kam qoldiq, tarif tugashi va h.k.
@immutable
class AlertItem {
  const AlertItem({
    required this.type,
    required this.name,
    this.amount,
    this.dueDate,
    this.stock,
    this.minStock,
    this.unit,
    this.daysLeft,
    this.plan,
  });

  factory AlertItem.fromJson(Map<String, dynamic> json) => AlertItem(
        type: json['type']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        amount: json['amount'] == null ? null : _num(json['amount']).toDouble(),
        dueDate: DateTime.tryParse(json['due_date']?.toString() ?? ''),
        stock: json['stock'] == null ? null : _num(json['stock']).toDouble(),
        minStock: json['min_stock'] == null
            ? null
            : _num(json['min_stock']).toDouble(),
        unit: json['unit']?.toString(),
        daysLeft:
            json['days_left'] == null ? null : _num(json['days_left']).toInt(),
        plan: json['plan']?.toString(),
      );

  /// debt_overdue | debt_due_soon | out_of_stock | low_stock | subscription_expiring
  final String type;
  final String name;
  final double? amount;
  final DateTime? dueDate;
  final double? stock;
  final double? minStock;
  final String? unit;
  final int? daysLeft;
  final String? plan;
}

/// `POST /ai/voice` javobi: ovozli buyruq tahlili (Pro).
@immutable
class VoiceResult {
  const VoiceResult({
    required this.intent,
    required this.message,
    required this.needsConfirmation,
    required this.params,
    required this.result,
  });

  factory VoiceResult.fromJson(Map<String, dynamic> json) {
    final Object? params = json['params'];
    final Object? result = json['result'];
    return VoiceResult(
      intent: json['intent']?.toString() ?? 'unknown',
      message: json['message']?.toString() ?? '',
      needsConfirmation: json['needs_confirmation'] == true,
      params: params is Map ? params.cast<String, dynamic>() : const <String, dynamic>{},
      result: result is Map ? result.cast<String, dynamic>() : null,
    );
  }

  /// debt_add | debt_payment | stock_in | show_sales | show_profit |
  /// show_debts | show_low_stock | unknown
  final String intent;
  final String message;

  /// true — amal tayyor, foydalanuvchi tasdiqlashi kerak.
  final bool needsConfirmation;
  final Map<String, dynamic> params;

  /// O'qish so'rovlari uchun ma'lumot (savdo, qarzdorlar, kam qoldiq).
  final Map<String, dynamic>? result;

  bool get isWrite =>
      intent == 'debt_add' || intent == 'debt_payment' || intent == 'stock_in';

  List<Map<String, dynamic>> paramList(String key) {
    final Object? value = params[key];
    return value is List
        ? value
            .whereType<Map<Object?, Object?>>()
            .map((Map<Object?, Object?> e) => e.cast<String, dynamic>())
            .toList()
        : const <Map<String, dynamic>>[];
  }
}

/// Eski daftar OCR natijasidagi bitta qator (`POST /ai/ocr-import`).
@immutable
class OcrItem {
  const OcrItem({
    required this.name,
    required this.amount,
    this.phone,
    this.note,
    this.uncertain = false,
    this.existingCustomerName,
  });

  factory OcrItem.fromJson(Map<String, dynamic> json) {
    final Object? existing = json['existing_customer'];
    return OcrItem(
      name: json['name']?.toString() ?? '',
      amount: _num(json['amount']).toDouble(),
      phone: json['phone']?.toString(),
      note: json['note']?.toString(),
      uncertain: json['uncertain'] == true,
      existingCustomerName: existing is Map ? existing['name']?.toString() : null,
    );
  }

  final String name;
  final double amount;
  final String? phone;
  final String? note;

  /// Qo'l yozuvi noaniq — "Tekshirish kerak" belgisi (TZ 15).
  final bool uncertain;

  /// Bazada shu ismli/telefonli mijoz bor bo'lsa uning nomi.
  final String? existingCustomerName;
}

@immutable
class OcrImportSummary {
  const OcrImportSummary({
    required this.customersCreated,
    required this.debtsCreated,
    required this.total,
  });

  factory OcrImportSummary.fromJson(Map<String, dynamic> json) =>
      OcrImportSummary(
        customersCreated: _num(json['customers_created']).toInt(),
        debtsCreated: _num(json['debts_created']).toInt(),
        total: _num(json['total']).toDouble(),
      );

  final int customersCreated;
  final int debtsCreated;
  final double total;
}

/// AI yordamchi suhbatidagi xabar (`role`: user | assistant).
@immutable
class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  final String role;
  final String content;

  bool get isUser => role == 'user';
}

/// Bulut zaxira nusxasi (`GET /backups`).
@immutable
class BackupInfo {
  const BackupInfo({
    required this.id,
    required this.size,
    required this.source,
    required this.counts,
    this.createdAt,
  });

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    final Object? counts = json['counts'];
    return BackupInfo(
      id: _num(json['id']).toInt(),
      size: _num(json['size']).toInt(),
      source: json['source']?.toString() ?? 'manual',
      counts: counts is Map
          ? counts.map((Object? k, Object? v) =>
              MapEntry<String, int>(k.toString(), _num(v).toInt()))
          : const <String, int>{},
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  final int id;

  /// Fayl hajmi, bayt.
  final int size;

  /// manual | auto (tiklashdan oldingi avtomatik zaxira ham `auto`).
  final String source;
  final Map<String, int> counts;
  final DateTime? createdAt;
}
