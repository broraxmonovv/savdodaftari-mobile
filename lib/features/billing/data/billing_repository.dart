import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../auth/data/auth_models.dart';
import 'billing_models.dart';

/// `/api/v1/billing` endpointlari bilan ishlaydi (sotuvdaftar-backend).
class BillingRepository {
  const BillingRepository(this._client);

  final ApiClient _client;

  /// GET /billing/plan — joriy tarif va Standart/Pro takliflari.
  Future<BillingPlans> plans() async {
    final ApiResponse response = await _client.get('/billing/plan');
    return BillingPlans.fromJson(response.dataMap);
  }

  /// POST /billing/checkout — pending to'lov yaratadi va checkout URL qaytaradi.
  Future<CheckoutResult> checkout({
    required UserPlan plan,
    required PaymentProvider provider,
  }) async {
    final ApiResponse response = await _client.post(
      '/billing/checkout',
      body: <String, dynamic>{
        'plan': plan.apiValue,
        'provider': provider.apiValue,
      },
    );
    return CheckoutResult.fromJson(response.dataMap);
  }

  /// GET /billing/payments/{orderId} — to'lov holatini so'rash (polling).
  Future<PaymentStatus> paymentStatus(String orderId) async {
    final ApiResponse response =
        await _client.get('/billing/payments/$orderId');
    final Object? payment = response.dataMap['payment'];
    if (payment is Map) {
      return PaymentStatus.fromApi(payment['status']?.toString());
    }
    return PaymentStatus.pending;
  }
}
