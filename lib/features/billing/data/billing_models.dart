import 'package:flutter/foundation.dart';

import '../../auth/data/auth_models.dart';

/// To'lov provayderi (backend `provider`).
enum PaymentProvider {
  payme,
  click;

  String get apiValue => name;
}

/// `GET /billing/plan` javobidagi bitta pullik tarif.
@immutable
class PlanOffer {
  const PlanOffer({
    required this.plan,
    required this.price,
    required this.days,
    this.features = const <String>[],
    this.maxCustomers,
    this.maxProducts,
  });

  factory PlanOffer.fromJson(Map<String, dynamic> json) {
    final Object? features = json['features'];
    return PlanOffer(
      plan: UserPlan.fromApi(json['id']?.toString()),
      price: num.tryParse(json['price']?.toString() ?? '')?.toInt() ?? 0,
      days: int.tryParse(json['days']?.toString() ?? '') ?? 30,
      features: features is List
          ? features.map((Object? e) => e.toString()).toList()
          : const <String>[],
      maxCustomers: _limit(json['limits'], 'customers'),
      maxProducts: _limit(json['limits'], 'products'),
    );
  }

  final UserPlan plan;

  /// Narx (so'm).
  final int price;

  /// Obuna muddati (kun).
  final int days;

  /// Backend kalitlari: sales, inventory, voice, ai_assistant, ...
  final List<String> features;

  /// Mijoz va mahsulot limiti (null — cheksiz).
  final int? maxCustomers;
  final int? maxProducts;

  static int? _limit(Object? limits, String key) {
    if (limits is Map && limits[key] != null) {
      return int.tryParse(limits[key].toString());
    }
    return null;
  }
}

/// `GET /billing/plan` javobi: joriy tarif va taklif qilinadigan tariflar.
@immutable
class BillingPlans {
  const BillingPlans({
    required this.current,
    required this.offers,
    this.expiresAt,
    this.isTrial = false,
    this.trialDays = 14,
    this.trialUsed = false,
    this.freeMaxCustomers = 30,
    this.providers = const <PaymentProvider>[
      PaymentProvider.payme,
      PaymentProvider.click,
    ],
  });

  factory BillingPlans.fromJson(Map<String, dynamic> json) {
    final Object? offers = json['plans'];
    final Object? providers = json['providers'];
    return BillingPlans(
      current: UserPlan.fromApi(json['plan']?.toString()),
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
      isTrial: json['is_trial'] == true,
      trialDays: int.tryParse('${(json['trial'] as Map?)?['days'] ?? ''}') ?? 14,
      trialUsed: (json['trial'] as Map?)?['used'] == true,
      freeMaxCustomers: int.tryParse(
            '${((json['free'] as Map?)?['limits'] as Map?)?['customers'] ?? ''}',
          ) ??
          30,
      offers: offers is List
          ? offers
              .whereType<Map<Object?, Object?>>()
              .map((Map<Object?, Object?> e) =>
                  PlanOffer.fromJson(e.cast<String, dynamic>()))
              .toList()
          : const <PlanOffer>[],
      providers: providers is List
          ? PaymentProvider.values
              .where((PaymentProvider p) => providers.contains(p.apiValue))
              .toList()
          : const <PaymentProvider>[
              PaymentProvider.payme,
              PaymentProvider.click,
            ],
    );
  }

  final UserPlan current;
  final DateTime? expiresAt;

  /// Hozir bepul sinov (Standart) davrida.
  final bool isTrial;
  final int trialDays;

  /// Sinov allaqachon berilgan (tugagan bo'lishi mumkin).
  final bool trialUsed;
  final int freeMaxCustomers;
  final List<PlanOffer> offers;
  final List<PaymentProvider> providers;

  PlanOffer? offerFor(UserPlan plan) {
    for (final PlanOffer offer in offers) {
      if (offer.plan == plan) {
        return offer;
      }
    }
    return null;
  }
}

/// To'lov holati (backend `payments.status`).
enum PaymentStatus {
  pending,
  paid,
  failed,
  canceled;

  static PaymentStatus fromApi(String? value) => switch (value) {
        'paid' => PaymentStatus.paid,
        'failed' => PaymentStatus.failed,
        'canceled' => PaymentStatus.canceled,
        _ => PaymentStatus.pending,
      };
}

/// `POST /billing/checkout` javobi: buyurtma va provayder sahifasi manzili.
@immutable
class CheckoutResult {
  const CheckoutResult({
    required this.orderId,
    required this.status,
    this.checkoutUrl,
  });

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    final Object? payment = json['payment'];
    final Map<String, dynamic> map = payment is Map
        ? payment.cast<String, dynamic>()
        : <String, dynamic>{};
    return CheckoutResult(
      orderId: map['order_id']?.toString() ?? '',
      status: PaymentStatus.fromApi(map['status']?.toString()),
      checkoutUrl: json['checkout_url']?.toString(),
    );
  }

  final String orderId;
  final PaymentStatus status;

  /// Payme/Click checkout sahifasi; provayder sozlanmagan bo'lsa null.
  final String? checkoutUrl;
}
