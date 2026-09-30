import 'package:flutter_test/flutter_test.dart';
import 'package:bozorpro/features/calculator/calculator_engine.dart';

void press(CalculatorEngine c, String keys) {
  for (final String ch in keys.split('')) {
    if (RegExp('[0-9]').hasMatch(ch)) {
      c.inputDigit(ch);
    } else if (ch == '.') {
      c.inputDot();
    } else if (ch == '=') {
      c.equals();
    } else if (ch == '+') {
      c.inputOperator(CalculatorEngine.plus);
    } else if (ch == '-') {
      c.inputOperator(CalculatorEngine.minus);
    } else if (ch == '*') {
      c.inputOperator(CalculatorEngine.times);
    } else if (ch == '/') {
      c.inputOperator(CalculatorEngine.divide);
    }
  }
}

void main() {
  test('operator precedence', () {
    final CalculatorEngine c = CalculatorEngine();
    press(c, '2+3*4=');
    expect(c.expression, '14');
  });

  test('decimals are rounded without float noise', () {
    final CalculatorEngine c = CalculatorEngine();
    press(c, '0.1+0.2=');
    expect(c.expression, '0.3');
  });

  test('division by zero gives error and recovers on next digit', () {
    final CalculatorEngine c = CalculatorEngine();
    press(c, '5/0=');
    expect(c.hasError, isTrue);
    press(c, '7');
    expect(c.hasError, isFalse);
    expect(c.expression, '7');
  });

  test('negative results can be continued', () {
    final CalculatorEngine c = CalculatorEngine();
    press(c, '3-8=');
    expect(c.expression, '${CalculatorEngine.minus}5');
    press(c, '*2=');
    expect(c.expression, '${CalculatorEngine.minus}10');
  });

  test('consecutive operators replace each other', () {
    final CalculatorEngine c = CalculatorEngine();
    press(c, '5+*3=');
    expect(c.expression, '15');
  });

  test('percent and sign toggle', () {
    final CalculatorEngine c = CalculatorEngine();
    press(c, '200*50');
    c.percent();
    expect(c.expression, '200${CalculatorEngine.times}0.5');
    c.equals();
    expect(c.expression, '100');
    c.toggleSign();
    expect(c.expression, '${CalculatorEngine.minus}100');
    c.toggleSign();
    expect(c.expression, '100');
  });

  test('preview and display grouping', () {
    final CalculatorEngine c = CalculatorEngine();
    press(c, '1200+35');
    expect(c.preview, '1235');
    expect(CalculatorEngine.display(c.expression),
        '1 200 + 35');
  });

  test('leading zero and single dot', () {
    final CalculatorEngine c = CalculatorEngine();
    press(c, '007.5.5');
    expect(c.expression, '7.55');
  });
}
