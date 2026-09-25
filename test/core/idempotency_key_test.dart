import 'package:flutter_base/core/utils/bidi_text.dart';
import 'package:flutter_base/core/utils/idempotency_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates a version-4 UUID', () {
    expect(
      generateIdempotencyKey(),
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });

  test('generates a different key each time', () {
    expect(generateIdempotencyKey(), isNot(generateIdempotencyKey()));
  });

  test('ltrIsolated wraps the text in LRI and PDI', () {
    expect('#12'.ltrIsolated.runes.first, 0x2066);
    expect('#12'.ltrIsolated.runes.last, 0x2069);
  });

  test('bidiIsolated leaves empty text empty', () {
    expect(''.bidiIsolated, isEmpty);
  });
}
