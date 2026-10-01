import 'package:bozorpro/core/l10n/uz_script.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uzbek latin -> cyrillic basics', () {
    final Map<String, String> cases = <String, String>{
      'Qarz daftari': 'Қарз дафтари',
      "so'm": 'сўм',
      "O'zbekcha": 'Ўзбекча',
      "Ma'lumot": 'Маълумот',
      "yo'q": 'йўқ',
      'Yangi mijoz': 'Янги мижоз',
      'Kalkulyator': 'Калкулятор',
      'Shahar chiqish': 'Шаҳар чиқиш',
      'Tasdiqlash': 'Тасдиқлаш',
      "g'oya to'lov": 'ғоя тўлов',
      'eski elektron': 'эски электрон',
      'Hisobot': 'Ҳисобот',
      'yordam': 'ёрдам',
      'yuqori': 'юқори',
    };
    cases.forEach((String latin, String cyrillic) {
      expect(UzScript.toCyrillic(latin), cyrillic, reason: latin);
    });
  });

  test('placeholders, brands, links and numbers are preserved', () {
    expect(
      UzScript.toCyrillic('Assalomu alaykum, {name}! Savdo Up — {link}'),
      'Ассалому алайкум, {name}! Savdo Up — {link}',
    );
    expect(UzScript.toCyrillic('Payme yoki Click orqali Pro'), 'Payme ёки Click орқали Pro');
    expect(UzScript.toCyrillic('50 000 so\'m, +998901234567'), '50 000 сўм, +998901234567');
    expect(UzScript.toCyrillic('bro.raxmonov@gmail.com'), 'bro.raxmonov@gmail.com');
    expect(UzScript.toCyrillic('https://t.me/savdoup_support_bot'), 'https://t.me/savdoup_support_bot');
    expect(UzScript.toCyrillic('Ўзбекча (кирилл)'), 'Ўзбекча (кирилл)');
    expect(UzScript.toCyrillic('SMS PDF'), 'SMS PDF');
  });

  test('uppercase words stay uppercase', () {
    expect(UzScript.toCyrillic('QARZ'), 'ҚАРЗ');
    expect(UzScript.toCyrillic('SHIRIN'), 'ШИРИН');
  });
}
