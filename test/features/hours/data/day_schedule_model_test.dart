import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/features/hours/data/models/day_schedule_model.dart';
import 'package:ssm_merchant/features/hours/domain/entities/clock_time.dart';
import 'package:ssm_merchant/features/hours/domain/entities/day_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> openDay(int day) => <String, dynamic>{
  'day': day,
  'is_open': true,
  'opening_time': '10:00',
  'closing_time': '22:00',
};

void main() {
  group('fromJson', () {
    test('parses an open day', () {
      // Equatable compares runtime types, so compare the fields.
      expect(
        DayScheduleModel.fromJson(openDay(0)).props,
        const DaySchedule(
          day: 0,
          isOpen: true,
          openingTime: ClockTime(10, 0),
          closingTime: ClockTime(22, 0),
        ).props,
      );
    });

    test('parses a closed day with null times', () {
      final DaySchedule day = DayScheduleModel.fromJson(<String, dynamic>{
        'day': 5,
        'is_open': false,
        'opening_time': null,
        'closing_time': null,
      });

      expect(day.isOpen, isFalse);
      expect(day.openingTime, isNull);
    });

    test('accepts is_open as 1', () {
      expect(
        DayScheduleModel.fromJson(openDay(0)..['is_open'] = 1).isOpen,
        isTrue,
      );
    });

    test('throws on an open day without times', () {
      expect(
        () => DayScheduleModel.fromJson(openDay(0)..['closing_time'] = null),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws on a day outside 0-6', () {
      expect(
        () => DayScheduleModel.fromJson(openDay(7)),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('listFromResponse', () {
    test('sorts the days Sunday first', () {
      final List<DaySchedule> days = DayScheduleModel.listFromResponse(
        <String, dynamic>{
          'days': <Map<String, dynamic>>[openDay(6), openDay(0), openDay(3)],
        },
      );

      expect(days.map((DaySchedule d) => d.day), <int>[0, 3, 6]);
    });

    test('throws without a days list', () {
      expect(
        () => DayScheduleModel.listFromResponse(<String, dynamic>{}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('requestBody', () {
    test('matches the documented payload', () {
      final Map<String, dynamic> body =
          DayScheduleModel.requestBody(const <DaySchedule>[
            DaySchedule(
              day: 0,
              isOpen: true,
              openingTime: ClockTime(10, 0),
              closingTime: ClockTime(22, 0),
            ),
            DaySchedule(day: 5, isOpen: false),
            DaySchedule(
              day: 6,
              isOpen: true,
              openingTime: ClockTime(10, 0),
              closingTime: ClockTime(2, 0),
            ),
          ]);

      expect(body, <String, dynamic>{
        'days': <Map<String, dynamic>>[
          <String, dynamic>{
            'day': 0,
            'is_open': true,
            'opening_time': '10:00',
            'closing_time': '22:00',
          },
          <String, dynamic>{
            'day': 5,
            'is_open': false,
            'opening_time': null,
            'closing_time': null,
          },
          <String, dynamic>{
            'day': 6,
            'is_open': true,
            'opening_time': '10:00',
            'closing_time': '02:00',
          },
        ],
      });
    });

    test('a closed day sends null times even when it keeps them', () {
      final Map<String, dynamic> body =
          DayScheduleModel.requestBody(const <DaySchedule>[
            DaySchedule(
              day: 1,
              isOpen: false,
              openingTime: ClockTime(9, 0),
              closingTime: ClockTime(17, 0),
            ),
          ]);

      final Map<String, dynamic> day = (body['days'] as List).single;
      expect(day['opening_time'], isNull);
      expect(day['closing_time'], isNull);
    });
  });
}
