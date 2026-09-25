import 'package:equatable/equatable.dart';

import 'clock_time.dart';

/// One weekday's opening hours. A closing time earlier than the opening time
/// means the store closes after midnight.
class DaySchedule extends Equatable {
  /// 0 = Sunday through 6 = Saturday, as the API numbers them.
  final int day;
  final bool isOpen;

  /// Kept while the day is closed, so switching it back on restores them.
  /// Always set on an open day.
  final ClockTime? openingTime;
  final ClockTime? closingTime;

  /// Hours given to a day opened for the first time.
  static const ClockTime defaultOpening = ClockTime(10, 0);
  static const ClockTime defaultClosing = ClockTime(22, 0);

  const DaySchedule({
    required this.day,
    required this.isOpen,
    this.openingTime,
    this.closingTime,
  });

  DaySchedule withOpen(bool isOpen) => DaySchedule(
    day: day,
    isOpen: isOpen,
    openingTime: openingTime ?? (isOpen ? defaultOpening : null),
    closingTime: closingTime ?? (isOpen ? defaultClosing : null),
  );

  DaySchedule withOpeningTime(ClockTime time) => DaySchedule(
    day: day,
    isOpen: isOpen,
    openingTime: time,
    closingTime: closingTime,
  );

  DaySchedule withClosingTime(ClockTime time) => DaySchedule(
    day: day,
    isOpen: isOpen,
    openingTime: openingTime,
    closingTime: time,
  );

  @override
  List<Object?> get props => [day, isOpen, openingTime, closingTime];
}
