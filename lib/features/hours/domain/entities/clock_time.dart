import 'package:equatable/equatable.dart';

/// A wall-clock time of day in the store's local time, minute precision.
class ClockTime extends Equatable {
  final int hour;
  final int minute;

  const ClockTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);

  /// Accepts `HH:mm` and `HH:mm:ss`; `null` for anything else.
  static ClockTime? tryParse(String? text) {
    final RegExpMatch? match = RegExp(
      r'^(\d{1,2}):(\d{2})(?::\d{2})?$',
    ).firstMatch(text?.trim() ?? '');
    if (match == null) return null;
    final int hour = int.parse(match.group(1)!);
    final int minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return ClockTime(hour, minute);
  }

  /// `HH:mm`, the format the working-hours API expects.
  String format() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [hour, minute];
}
