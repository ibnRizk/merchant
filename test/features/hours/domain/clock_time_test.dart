import 'package:ssm_merchant/features/hours/domain/entities/clock_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses HH:mm', () {
    expect(ClockTime.tryParse('09:30'), const ClockTime(9, 30));
  });

  test('parses HH:mm:ss, dropping the seconds', () {
    expect(ClockTime.tryParse('22:00:00'), const ClockTime(22, 0));
  });

  test('rejects an out-of-range time', () {
    expect(ClockTime.tryParse('24:00'), isNull);
  });

  test('rejects null and junk', () {
    expect(ClockTime.tryParse(null), isNull);
    expect(ClockTime.tryParse('10am'), isNull);
  });

  test('formats zero-padded HH:mm', () {
    expect(const ClockTime(2, 5).format(), '02:05');
  });
}
