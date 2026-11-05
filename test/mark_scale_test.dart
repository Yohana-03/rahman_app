import 'package:finalrahman/core/formatters.dart';
import 'package:finalrahman/core/mark_scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('50-point papers omit the percent sign', () {
    final scale = markScale(
      scores: const [42.6, 41, 47],
      grades: const ['A', 'A', 'A'],
      className: 'Standard 5',
    );

    expect(scale, 50);
    expect(formatMark(42.6, scale), '42.6');
    expect(formatMark(41, scale), '41');
    expect(markFraction(42.6, scale), closeTo(0.852, 0.001));
  });

  test('100-point papers keep the percent sign', () {
    final scale = markScale(
      scores: const [80, 75],
      grades: const ['A', 'A'],
      className: 'Form Two',
    );

    expect(scale, 100);
    expect(formatMark(80, scale), '80%');
    expect(formatMark(75.5, scale), '75.5%');
  });

  test('a low secondary score stays on the 100-point scale', () {
    final scale = markScale(
      scores: const [42],
      grades: const ['F'],
      className: 'Form Two',
    );

    expect(scale, 100);
    expect(formatMark(42, scale), '42%');
  });

  test('percentages keep one decimal only when needed', () {
    expect(formatPlainNumber(95), '95');
    expect(formatPlainNumber(95.26), '95.3');
    expect(formatPlainNumber(10.04), '10');
  });

  test('performance change compares the previous examination', () {
    expect(
      performanceChangeLabel(45, 40),
      'Increase by 12.5% from previous examination',
    );
    expect(
      performanceChangeLabel(40, 45),
      'Fall by 11.1% from previous examination',
    );
    expect(performanceChangeLabel(40, null), isNull);
  });

  test('admission numbers are hidden from parent-facing text', () {
    expect(
      stripAdmission('Standard 5 • ADM-2026-0377'),
      'Standard 5',
    );
  });
}
