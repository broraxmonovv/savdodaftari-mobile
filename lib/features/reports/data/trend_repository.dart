import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'trend_models.dart';

class TrendRepository {
  const TrendRepository(this._client);

  final ApiClient _client;

  /// GET /reports/daily?period=week|month|all — butun davr uchun backend guruhni o'zi tanlaydi.
  Future<TrendSeries> fetch(TrendRange range) async {
    final ApiResponse response = await _client.get(
      '/reports/daily',
      query: <String, dynamic>{'period': range.period},
    );
    return TrendSeries.fromJson(response.dataMap);
  }
}
