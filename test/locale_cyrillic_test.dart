import 'package:bozorpro/core/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uzbek cyrillic strings are generated from latin', () {
    final AppStrings latin = AppStrings.uz;
    final AppStrings cyr = AppStrings.uzCyrl;

    expect(cyr.localeKey, 'uz_cyrl');
    expect(cyr.localeCode, 'uz'); // sana formati va ovoz tili uchun
    expect(cyr.appName, 'Savdo Up'); // brend o'zgarmaydi
    expect(cyr.isCyrillic, isTrue);
    expect(latin.isCyrillic, isFalse);

    expect(cyr.languageUzCyrl, 'Ўзбекча (кирилл)');
    expect(cyr.start, isNot(latin.start));
    expect(RegExp(r'[А-Яа-яЎўҚқҒғҲҳ]').hasMatch(cyr.start), isTrue);
    expect(cyr.planStandardFeatures.length, latin.planStandardFeatures.length);
  });

  test('placeholders survive transliteration in templates', () {
    final AppStrings cyr = AppStrings.uzCyrl;
    final String text = cyr.overdueDebts(3);
    expect(text, contains('3'));
    expect(text, isNot(contains('{count}')));
    expect(cyr.referralShareText('https://x.uz/r/ABC', 'ABC'), contains('https://x.uz/r/ABC'));
    expect(cyr.dyn("Qarz topilmadi"), 'Қарз топилмади');
    expect(AppStrings.uz.dyn("Qarz topilmadi"), 'Qarz topilmadi');
    expect(AppStrings.ru.dyn("Qarz"), 'Qarz');
  });

  test('every latin string field has no leftover latin words in cyrillic variant', () {
    // Faqat himoyalangan brend/qisqartmalar lotinda qolishi mumkin.
    const Set<String> allowed = <String>{
      'savdo', 'up', 'pro', 'pdf', 'excel', 'xlsx', 'sms', 'otp', 'pin', 'qr', 'api', 'ai',
      'ocr', 'usd', 'eur', 'rub', 'kzt', 'gbp', 'cny', 'payme', 'click', 'telegram', 'google',
      'bluetooth', 'android', 'ios', 'wifi', 'email', 'xprinter', 'cbu', 'uz', 'ru', 'www',
      'http', 'https', 'com', 'id', 'b2b', 'count', 'name', 'amount', 'date', 'stock', 'unit',
      'min', 'plan', 'days', 'sales', 'profit', 'expense', 'link', 'code', 'total', 'max',
      'customers', 'debts', 'products', 'time', 'price', 'day', 'seconds', 'qty', 'phone',
      'number', 'percent', 'balance', 'items', 'size', 'bonus', 'user', 'month',
    };
    final AppStrings cyr = AppStrings.uzCyrl;
    final List<String> sample = <String>[
      cyr.start, cyr.next, cyr.skip, cyr.navSettings, cyr.navReports, cyr.logout,
      cyr.languageLabel, cyr.planScreenTitle, cyr.voiceIntro, cyr.smsRemindersBody,
    ];
    for (final String value in sample) {
      for (final RegExpMatch m in RegExp(r'[A-Za-z]+').allMatches(value)) {
        expect(allowed.contains(m[0]!.toLowerCase()), isTrue, reason: '"$value" -> ${m[0]}');
      }
    }
  });

  test('locale keys round trip', () {
    for (final String key in <String>['uz', 'uz_cyrl', 'ru']) {
      expect(AppStrings.keyOf(AppStrings.localeOf(key)), key);
    }
    expect(AppStrings.apiLanguage('uz_cyrl'), 'uz');
    expect(AppStrings.apiLanguage('ru'), 'ru');
    expect(AppStrings.localeOf('uz_cyrl'), isA<Locale>());
  });
}
