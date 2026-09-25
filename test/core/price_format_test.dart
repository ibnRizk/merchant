import 'package:ssm_merchant/core/utils/price_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsePrice', () {
    test('parses a plain decimal', () {
      expect(parsePrice('25.50'), 25.5);
    });

    test('accepts Arabic-Indic digits and the Arabic decimal mark', () {
      expect(parsePrice('٢٥٫٥'), 25.5);
    });

    test('accepts a comma as the decimal separator', () {
      expect(parsePrice('25,5'), 25.5);
    });

    test('ignores surrounding whitespace', () {
      expect(parsePrice('  12 '), 12);
    });

    test('rejects text, negatives and empty input', () {
      expect(parsePrice('abc'), isNull);
      expect(parsePrice('-3'), isNull);
      expect(parsePrice(''), isNull);
    });
  });

  group('formatPrice', () {
    test('drops the decimals of a whole amount', () {
      expect(formatPrice(28), '28');
    });

    test('keeps two decimals otherwise', () {
      expect(formatPrice(28.5), '28.50');
    });
  });
}
