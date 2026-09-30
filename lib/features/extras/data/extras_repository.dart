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

  /// GET /announcements — admin yuborgan bildirishnomalar.
  Future<AnnouncementList> announcements() async {
    final ApiResponse response = await _client.get('/announcements');
    return AnnouncementList(
      items: response.dataList.map(Announcement.fromJson).toList(),
      unreadCount: response.metaNumber('unread_count').toInt(),
    );
  }

  Future<void> markAnnouncementRead(int id) async {
    await _client.post('/announcements/$id/read');
  }

  Future<void> markAllAnnouncementsRead() async {
    await _client.post('/announcements/read-all');
  }

  /// GET /notifications — hisoblangan ogohlantirishlar (qarz, qoldiq, tarif).
  Future<List<AlertItem>> alerts() async {
    final ApiResponse response = await _client.get('/notifications');
    final Object? items = response.dataMap['items'];
    if (items is! List) {
      return const <AlertItem>[];
    }
    return items
        .whereType<Map<Object?, Object?>>()
        .map((Map<Object?, Object?> e) =>
            AlertItem.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  /// POST /devices — push uchun FCM tokenini ro'yxatdan o'tkazadi.
  Future<void> registerDevice(String token, String platform) async {
    await _client.post(
      '/devices',
      body: <String, dynamic>{'token': token, 'platform': platform},
    );
  }

  /// DELETE /devices — chiqishda tokenni o'chiradi.
  Future<void> unregisterDevice(String token) async {
    await _client.delete('/devices', body: <String, dynamic>{'token': token});
  }

  /// POST /ai/voice — ovozli buyruq matnini tahlil qiladi (faqat Pro).
  Future<VoiceResult> voice(String text) async {
    final ApiResponse response = await _client.post(
      '/ai/voice',
      body: <String, dynamic>{'text': text},
    );
    return VoiceResult.fromJson(response.dataMap);
  }

  /// POST /ai/ocr-import — daftar rasmini tahlil qiladi (Pro). Hech narsa yozilmaydi.
  Future<List<OcrItem>> ocrExtract(String imagePath) async {
    final ApiResponse response = await _client.postFile(
      '/ai/ocr-import',
      fileField: 'image',
      filePath: imagePath,
      receiveTimeout: const Duration(seconds: 120),
    );
    final Object? items = response.dataMap['items'];
    if (items is! List) {
      return const <OcrItem>[];
    }
    return items
        .whereType<Map<Object?, Object?>>()
        .map((Map<Object?, Object?> e) =>
            OcrItem.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  /// POST /ai/ocr-import/confirm — foydalanuvchi tekshirgan qatorlarni yozadi.
  Future<OcrImportSummary> ocrConfirm(List<OcrItem> items) async {
    final ApiResponse response = await _client.post(
      '/ai/ocr-import/confirm',
      body: <String, dynamic>{
        'items': items
            .map((OcrItem it) => <String, dynamic>{
                  'name': it.name,
                  'amount': it.amount.round(),
                  if (it.phone != null && it.phone!.isNotEmpty) 'phone': it.phone,
                  if (it.note != null && it.note!.isNotEmpty) 'note': it.note,
                })
            .toList(),
      },
    );
    return OcrImportSummary.fromJson(response.dataMap);
  }

  /// POST /ai/assistant — AI biznes yordamchi (Pro). [history]: oldingi xabarlar.
  Future<String> assistant(String message, List<ChatMessage> history) async {
    final ApiResponse response = await _client.post(
      '/ai/assistant',
      body: <String, dynamic>{
        'message': message,
        if (history.isNotEmpty)
          'history': history
              .map((ChatMessage m) =>
                  <String, String>{'role': m.role, 'content': m.content})
              .toList(),
      },
    );
    return response.dataMap['reply']?.toString() ?? '';
  }
}
