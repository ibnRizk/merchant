import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/json_values.dart';
import '../../domain/entities/clock_time.dart';
import '../../domain/entities/day_schedule.dart';

/// Maps `/vendor/working-hours` days:
/// `{"day": 0, "is_open": true, "opening_time": "10:00", "closing_time": "22:00"}`.
class DayScheduleModel extends DaySchedule {
  const DayScheduleModel({
    required super.day,
    required super.isOpen,
    super.openingTime,
    super.closingTime,
  });

  /// Throws [ServerException] on a day number outside 0–6 or an open day
  /// without valid times: showing made-up hours would be worse than an error.
  factory DayScheduleModel.fromJson(Map<String, dynamic> json) {
    final int? day = int.tryParse('${json['day']}');
    final bool isOpen = isTruthy(json['is_open']);
    final ClockTime? opening = ClockTime.tryParse(
      json['opening_time']?.toString(),
    );
    final ClockTime? closing = ClockTime.tryParse(
      json['closing_time']?.toString(),
    );

    if (day == null || day < 0 || day > 6) {
      throw ServerException.unexpectedResponse();
    }
    if (isOpen && (opening == null || closing == null)) {
      throw ServerException.unexpectedResponse();
    }

    return DayScheduleModel(
      day: day,
      isOpen: isOpen,
      openingTime: opening,
      closingTime: closing,
    );
  }

  /// A closed day sends null times, as the API documents.
  static Map<String, dynamic> toJson(DaySchedule schedule) => <String, dynamic>{
    'day': schedule.day,
    'is_open': schedule.isOpen,
    'opening_time': schedule.isOpen ? schedule.openingTime?.format() : null,
    'closing_time': schedule.isOpen ? schedule.closingTime?.format() : null,
  };

  /// The `{"days": [...]}` envelope shared by the GET and PUT responses,
  /// sorted Sunday first.
  static List<DaySchedule> listFromResponse(dynamic response) {
    final dynamic days = response is Map ? response['days'] : null;
    if (days is! List) {
      throw ServerException.unexpectedResponse();
    }
    return <DaySchedule>[
      for (final dynamic day in days)
        if (day is Map<String, dynamic>)
          DayScheduleModel.fromJson(day)
        else
          throw ServerException.unexpectedResponse(),
    ]..sort((DaySchedule a, DaySchedule b) => a.day.compareTo(b.day));
  }

  static Map<String, dynamic> requestBody(
    List<DaySchedule> days,
  ) => <String, dynamic>{
    'days': <Map<String, dynamic>>[for (final DaySchedule d in days) toJson(d)],
  };
}
