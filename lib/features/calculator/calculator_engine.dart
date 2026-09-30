/// Kalkulyator mantiqi: ifoda satri sifatida saqlanadi (`12+3×4`), amallar
/// ustuvorligi (× ÷ avval, + − keyin) hisobga olinadi. UI'dan mustaqil.
class CalculatorEngine {
  static const String plus = '+';
  static const String minus = '−';
  static const String times = '×';
  static const String divide = '÷';
  static const List<String> operators = <String>[plus, minus, times, divide];

  String _expr = '';
  bool _justEvaluated = false;
  bool _error = false;

  /// Ifoda (formatlanmagan): `1200+35`.
  String get expression => _expr;

  bool get hasError => _error;

  bool _isOp(String ch) => operators.contains(ch);

  bool get _endsWithOperator => _expr.isNotEmpty && _isOp(_expr[_expr.length - 1]);

  /// Oxirgi son (belgisiz) boshlanadigan indeks.
  int get _lastNumberStart {
    int i = _expr.length;
    while (i > 0 && !_isOp(_expr[i - 1])) {
      i--;
    }
    return i;
  }

  String get _lastNumber => _expr.substring(_lastNumberStart);

  void _resetIfNeeded({required bool forDigit}) {
    if (_error || (_justEvaluated && forDigit)) {
      _expr = '';
      _error = false;
    }
    _justEvaluated = false;
  }

  void inputDigit(String digit) {
    _resetIfNeeded(forDigit: true);
    if (_lastNumber == '0') {
      _expr = _expr.substring(0, _expr.length - 1);
    }
    _expr += digit;
  }

  void inputDot() {
    _resetIfNeeded(forDigit: true);
    final String number = _lastNumber;
    if (number.contains('.')) {
      return;
    }
    _expr += number.isEmpty ? '0.' : '.';
  }

  void inputOperator(String op) {
    if (_error) {
      clear();
    }
    _justEvaluated = false;
    if (_expr.isEmpty) {
      // Ifoda boshida faqat manfiy son boshlash mumkin.
      if (op == minus) {
        _expr = minus;
      }
      return;
    }
    if (_expr == minus) {
      return;
    }
    if (_endsWithOperator) {
      final String prev = _expr[_expr.length - 1];
      final bool prevIsSign = _expr.length >= 2 &&
          prev == minus &&
          (_expr[_expr.length - 2] == times ||
              _expr[_expr.length - 2] == divide);
      if (prevIsSign) {
        // `5×−` ustiga operator bosilsa ikkalasi ham almashadi.
        _expr = _expr.substring(0, _expr.length - 2) + op;
      } else if (op == minus && (prev == times || prev == divide)) {
        // × yoki ÷ dan keyin − — manfiy son boshlanishi.
        _expr += op;
      } else {
        _expr = _expr.substring(0, _expr.length - 1) + op;
      }
      return;
    }
    _expr += op;
  }

  void backspace() {
    if (_error) {
      clear();
      return;
    }
    _justEvaluated = false;
    if (_expr.isNotEmpty) {
      _expr = _expr.substring(0, _expr.length - 1);
    }
  }

  void clear() {
    _expr = '';
    _error = false;
    _justEvaluated = false;
  }

  /// Oxirgi sonni foizga aylantiradi: `200×50` -> `200×0.5`.
  void percent() {
    if (_error || _expr.isEmpty || _endsWithOperator) {
      return;
    }
    final int start = _lastNumberStart;
    final double? value = double.tryParse(_expr.substring(start));
    if (value == null) {
      return;
    }
    _expr = _expr.substring(0, start) + _asExpression(value / 100);
    _justEvaluated = false;
  }

  /// Oxirgi son ishorasini almashtiradi (`±`).
  void toggleSign() {
    if (_error) {
      return;
    }
    _justEvaluated = false;
    final int start = _lastNumberStart;
    if (start == _expr.length) {
      return;
    }
    final bool unaryMinus = start > 0 &&
        _expr[start - 1] == minus &&
        (start == 1 || _isOp(_expr[start - 2]));
    if (unaryMinus) {
      _expr = _expr.substring(0, start - 1) + _expr.substring(start);
    } else {
      _expr = _expr.substring(0, start) + minus + _expr.substring(start);
    }
  }

  /// `=` — natijani hisoblab ifoda o'rniga qo'yadi.
  void equals() {
    if (_error || _expr.isEmpty) {
      return;
    }
    final double? value = evaluate(_expr);
    if (value == null) {
      _error = true;
      return;
    }
    _expr = _asExpression(value);
    _justEvaluated = true;
  }

  /// Ifoda operator ichirsa — joriy natija (oldindan ko'rish), aks holda null.
  String? get preview {
    if (_error || _expr.isEmpty) {
      return null;
    }
    final String trimmed = _endsWithOperator
        ? _expr.substring(0, _expr.length - 1)
        : _expr;
    if (trimmed.length < 2 ||
        !RegExp('[+−×÷]').hasMatch(trimmed.substring(1))) {
      return null;
    }
    final double? value = evaluate(trimmed);
    return value == null ? null : _asExpression(value);
  }

  /// Ifodani ustuvorlik bilan hisoblaydi; noto'g'ri yoki 0 ga bo'lish — null.
  static double? evaluate(String expression) {
    final List<String> tokens = _tokenize(expression);
    if (tokens.isEmpty) {
      return null;
    }

    // 1-o'tish: × va ÷
    final List<String> pass = <String>[];
    for (int i = 0; i < tokens.length; i++) {
      final String t = tokens[i];
      if (t == times || t == divide) {
        if (pass.isEmpty || i + 1 >= tokens.length) {
          return null;
        }
        final double? a = double.tryParse(pass.removeLast());
        final double? b = double.tryParse(tokens[++i]);
        if (a == null || b == null) {
          return null;
        }
        if (t == divide && b == 0) {
          return null;
        }
        pass.add((t == times ? a * b : a / b).toString());
      } else {
        pass.add(t);
      }
    }

    // 2-o'tish: + va −
    double? total = double.tryParse(pass.first);
    if (total == null) {
      return null;
    }
    for (int i = 1; i + 1 < pass.length; i += 2) {
      final double? b = double.tryParse(pass[i + 1]);
      if (b == null) {
        return null;
      }
      total = pass[i] == plus ? total! + b : total! - b;
    }
    return total;
  }

  /// `-3+2×-4` kabi ifodani [son, operator, son, ...] ga ajratadi;
  /// son oldidagi birlamchi `−` manfiy son belgisi sifatida qaraladi.
  static List<String> _tokenize(String expression) {
    final List<String> tokens = <String>[];
    final StringBuffer number = StringBuffer();
    bool expectNumber = true;

    for (int i = 0; i < expression.length; i++) {
      final String ch = expression[i];
      if (operators.contains(ch)) {
        if (expectNumber) {
          if (ch != minus) {
            return <String>[];
          }
          number.write('-');
          continue;
        }
        tokens.add(number.toString());
        number.clear();
        tokens.add(ch);
        expectNumber = true;
      } else {
        number.write(ch);
        expectNumber = false;
      }
    }
    if (expectNumber) {
      return <String>[];
    }
    tokens.add(number.toString());
    return tokens;
  }

  /// Natijani ifoda ichida ishlatish uchun: manfiy ishora `−` (U+2212) bo'ladi.
  static String _asExpression(double value) =>
      formatNumber(value).replaceFirst('-', minus);

  /// Sonni chiroyli ko'rinishga keltiradi: 10 xona aniqlik, ortiqcha nollarsiz.
  static String formatNumber(double value) {
    if (value.isNaN || value.isInfinite) {
      return '0';
    }
    String text = value.toStringAsFixed(10);
    if (text.contains('.')) {
      text = text.replaceFirst(RegExp(r'0+$'), '');
      text = text.replaceFirst(RegExp(r'\.$'), '');
    }
    if (text == '-0') {
      return '0';
    }
    return text;
  }

  /// Ko'rsatish uchun: sonlarning butun qismi 3 xonadan guruhlanadi
  /// (`1234567.5` -> `1 234 567.5`), operatorlar atrofida bo'sh joy.
  static String display(String expression) {
    final StringBuffer out = StringBuffer();
    final StringBuffer number = StringBuffer();

    void flush() {
      if (number.isEmpty) {
        return;
      }
      final String raw = number.toString();
      final int dot = raw.indexOf('.');
      final String intPart = dot == -1 ? raw : raw.substring(0, dot);
      final String rest = dot == -1 ? '' : raw.substring(dot);
      final StringBuffer grouped = StringBuffer();
      for (int i = 0; i < intPart.length; i++) {
        if (i > 0 && (intPart.length - i) % 3 == 0) {
          grouped.write(' ');
        }
        grouped.write(intPart[i]);
      }
      out.write('$grouped$rest');
      number.clear();
    }

    for (int i = 0; i < expression.length; i++) {
      final String ch = expression[i];
      final bool isOp = operators.contains(ch);
      // Boshdagi yoki operator keyingi `−` — manfiy son belgisi.
      final bool unary =
          ch == minus && (i == 0 || operators.contains(expression[i - 1]));
      if (isOp && !unary) {
        flush();
        out.write(' $ch ');
      } else if (unary) {
        flush();
        out.write(ch);
      } else {
        number.write(ch);
      }
    }
    flush();
    return out.toString();
  }
}
