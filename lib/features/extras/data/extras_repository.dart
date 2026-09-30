import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'extras_models.dart';

/// Valyuta kurslari, qo'llab-quvvatlash, qo'llanma, referal va bonus endpointlari.
class ExtrasRepository {
  const ExtrasRepository(this._client);

  final ApiClient _client;

  /// GET /currencies — cbu.uz kurslari (backend keshlaydi va yangilab turadi).
  Future<CurrencyRates> currencies() async {
    final ApiResponse response = await _client.get('/currencies');
    return CurrencyRates.fromJson(response.dataMap);
  }

  Future<SupportInfo> support() async {
    final ApiResponse response = await _client.get('/support');
    return SupportInfo.fromJson(response.dataMap);
  }

  Future<List<GuideVideo>> guides() async {
    final ApiResponse response = await _client.get('/guides');
    return response.dataList.map(GuideVideo.fromJson).toList();
  }

  Future<ReferralInfo> referral() async {
    final ApiResponse response = await _client.get('/referral');
    return ReferralInfo.fromJson(response.dataMap);
  }

  /// GET /bonuses — javobdagi `meta.balance` joriy balans.
  Future<BonusSummary> bonuses() async {
    final ApiResponse response =
        await _client.get('/bonuses', query: <String, dynamic>{'per_page': 50});
    return BonusSummary(
      balance: response.balance,
      entries: response.dataList.map(BonusEntry.fromJson).toList(),
    );
  }

  /// POST /bonuses/pay-plan — tarifni to'liq bonus balansidan to'laydi.
  Future<void> payPlanWithBonus(String plan) async {
    await _client.post(
      '/bonuses/pay-plan',
      body: <String, dynamic>{'plan': plan},
    );
  }

  /// GET /withdrawals — yechib olish so'rovlari va minimal summa.
  Future<WithdrawalList> withdrawals() async {
    final ApiResponse response = await _client.get('/withdrawals');
    return WithdrawalList(
      items: response.dataList.map(WithdrawalRequest.fromJson).toList(),
      balance: response.balance,
      minWithdrawal: response.metaNumber('min_withdrawal'),
    );
  }

  /// POST /withdrawals — so'rov adminga yuboriladi, summa balansdan ushlanadi.
  Future<void> requestWithdrawal({
    required int amount,
    required String cardNumber,
    String? cardHolder,
  }) async {
    await _client.post(
      '/withdrawals',
      body: <String, dynamic>{
        'amount': amount,
        'card_number': cardNumber,
        if (cardHolder != null && cardHolder.trim().isNotEmpty)
          'card_holder': cardHolder.trim(),
      },
    );
  }
}
