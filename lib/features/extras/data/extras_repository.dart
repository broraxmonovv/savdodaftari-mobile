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
}
