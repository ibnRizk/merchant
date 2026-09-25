import 'package:ssm_merchant/features/home/domain/entities/greeting_period.dart';
import 'package:flutter_test/flutter_test.dart';

GreetingPeriod at(int hour, [int minute = 0]) =>
    GreetingPeriod.of(DateTime(2026, 9, 25, hour, minute));

void main() {
  test('morning starts at 05:00', () {
    expect(at(4, 59), GreetingPeriod.evening);
    expect(at(5), GreetingPeriod.morning);
  });

  test('morning ends at noon', () {
    expect(at(11, 59), GreetingPeriod.morning);
    expect(at(12), GreetingPeriod.evening);
  });

  test('late night is evening', () {
    expect(at(23), GreetingPeriod.evening);
    expect(at(0), GreetingPeriod.evening);
  });
}
