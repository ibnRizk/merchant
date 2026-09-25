import 'package:flutter_base/features/hours/domain/entities/clock_time.dart';
import 'package:flutter_base/features/hours/domain/entities/day_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opening a day without hours gives it the default hours', () {
    const DaySchedule closed = DaySchedule(day: 5, isOpen: false);

    final DaySchedule opened = closed.withOpen(true);

    expect(opened.openingTime, DaySchedule.defaultOpening);
    expect(opened.closingTime, DaySchedule.defaultClosing);
  });

  test('closing and reopening a day keeps its hours', () {
    const DaySchedule open = DaySchedule(
      day: 1,
      isOpen: true,
      openingTime: ClockTime(8, 0),
      closingTime: ClockTime(2, 0),
    );

    expect(open.withOpen(false).withOpen(true), open);
  });

  test('closing a day without hours leaves them empty', () {
    const DaySchedule closed = DaySchedule(day: 5, isOpen: false);

    expect(closed.withOpen(false).openingTime, isNull);
  });
}
