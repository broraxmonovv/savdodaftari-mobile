/// O'zbek lotin yozuvini kirillga o'tkazadi (1995 yil lotin alifbosi qoidalari bo'yicha).
///
/// Ilovaning "O'zbekcha (kirill)" tili shu o'tkazgich orqali hosil bo'ladi: lotincha matnlar
/// va serverdan kelgan xabarlar kirillda ko'rsatiladi. `{name}` kabi o'rin-belgilar, havola,
/// email, brend nomlari (Payme, Click, Pro, PDF ...) o'zgarishsiz qoladi.
abstract final class UzScript {
  /// Kirillga o'tkazilmaydigan so'zlar (kichik harfda).
  static const Set<String> _keep = <String>{
    'pro', 'pdf', 'excel', 'xlsx', 'sms', 'otp', 'pin', 'qr', 'api', 'ai', 'ocr',
    'usd', 'eur', 'rub', 'kzt', 'gbp', 'cny', 'payme', 'click', 'telegram',
    'google', 'bluetooth', 'android', 'ios', 'wifi', 'email', 'xprinter',
    'cbu', 'uz', 'ru', 'www', 'http', 'https', 'com', 'id', 'b2b',
  };

  static final RegExp _token = RegExp(
    r'\{[^}]*\}' // {name} o'rin-belgilari
    r'|Savdo Up' // brend nomi
    r'|https?://\S+' // havolalar
    r'|[\w.+-]+@[\w.-]+' // email
    r"|[A-Za-z][A-Za-z'’ʻʼ‘`]*", // lotincha so'z
  );

  static const String _vowels = 'aeiou';

  static const Map<String, String> _single = <String, String>{
    'a': 'а', 'b': 'б', 'c': 'с', 'd': 'д', 'e': 'е', 'f': 'ф', 'g': 'г',
    'h': 'ҳ', 'i': 'и', 'j': 'ж', 'k': 'к', 'l': 'л', 'm': 'м', 'n': 'н',
    'o': 'о', 'p': 'п', 'q': 'қ', 'r': 'р', 's': 'с', 't': 'т', 'u': 'у',
    'v': 'в', 'w': 'в', 'x': 'х', 'y': 'й', 'z': 'з',
  };

  /// Matndagi barcha lotincha so'zlarni kirillga o'tkazadi.
  static String toCyrillic(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input.replaceAllMapped(_token, (Match m) {
      final String part = m[0]!;
      final String first = part[0];
      if (first == '{' || part.contains('@') || part.startsWith('http')) {
        return part;
      }
      if (part == 'Savdo Up') {
        return part;
      }
      if (_keep.contains(part.toLowerCase())) {
        return part;
      }
      return _word(part);
    });
  }

  static String _word(String word) {
    final String w = word
        .replaceAll('’', "'")
        .replaceAll('ʻ', "'")
        .replaceAll('ʼ', "'")
        .replaceAll('‘', "'")
        .replaceAll('`', "'");
    final String lower = w.toLowerCase();
    final bool allUpper = w.length > 1 &&
        w == w.toUpperCase() &&
        w != w.toLowerCase() &&
        !w.contains("'");
    final StringBuffer out = StringBuffer();

    String at(int i) => i >= 0 && i < lower.length ? lower[i] : '';
    bool isUpper(int i) => w[i] != lower[i];

    void put(String cyr, int i) {
      // Katta harf bilan boshlangan bo'lsa, o'tkazilgan harfning birinchisi katta bo'ladi
      out.write(isUpper(i) ? _cap(cyr) : cyr);
    }

    int i = 0;
    while (i < lower.length) {
      final String c = lower[i];
      final String n = at(i + 1);

      if (c == 's' && n == 'h') {
        put('ш', i);
        i += 2;
      } else if (c == 'c' && n == 'h') {
        put('ч', i);
        i += 2;
      } else if (c == 'o' && n == "'") {
        put('ў', i);
        i += 2;
      } else if (c == 'g' && n == "'") {
        put('ғ', i);
        i += 2;
      } else if (c == 'y' && n == 'o' && at(i + 2) != "'") {
        put('ё', i);
        i += 2;
      } else if (c == 'y' && n == 'a') {
        put('я', i);
        i += 2;
      } else if (c == 'y' && n == 'u') {
        put('ю', i);
        i += 2;
      } else if (c == 'y' && n == 'e') {
        final bool afterVowel = i == 0 || _vowels.contains(at(i - 1));
        put(afterVowel ? 'е' : 'йе', i);
        i += 2;
      } else if (c == 'e' && i == 0) {
        put('э', i);
        i += 1;
      } else if (c == "'") {
        out.write('ъ');
        i += 1;
      } else {
        final String? mapped = _single[c];
        if (mapped == null) {
          out.write(w[i]);
        } else {
          put(mapped, i);
        }
        i += 1;
      }
    }

    final String result = out.toString();
    return allUpper ? result.toUpperCase() : result;
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
