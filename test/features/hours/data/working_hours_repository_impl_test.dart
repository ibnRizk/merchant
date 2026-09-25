import 'package:ssm_merchant/core/api/api_endpoints.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/hours/data/datasources/working_hours_remote_data_source.dart';
import 'package:ssm_merchant/features/hours/data/repos/working_hours_repository_impl.dart';
import 'package:ssm_merchant/features/hours/domain/entities/clock_time.dart';
import 'package:ssm_merchant/features/hours/domain/entities/day_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_dio_consumer.dart';

Map<String, dynamic> week() => <String, dynamic>{
  'days': <Map<String, dynamic>>[
    for (int day = 0; day < 7; day++)
      <String, dynamic>{
        'day': day,
        'is_open': day != 5,
        'opening_time': day != 5 ? '10:00' : null,
        'closing_time': day != 5 ? '22:00' : null,
      },
  ],
};

void main() {
  late FakeDioConsumer client;
  late WorkingHoursRepositoryImpl repository;

  setUp(() {
    client = FakeDioConsumer()..response = week();
    repository = WorkingHoursRepositoryImpl(
      remote: WorkingHoursRemoteDataSourceImpl(client: client),
    );
  });

  test('gets working-hours', () async {
    await repository.getWorkingHours();

    expect(client.calls.single.verb, 'GET');
    expect(client.calls.single.path, ApiEndpoints.workingHours);
  });

  test('returns all seven days', () async {
    final result = await repository.getWorkingHours();

    expect(result.fold((_) => null, (List<DaySchedule> d) => d.length), 7);
  });

  test('saves with a PUT of the days payload', () async {
    await repository.saveWorkingHours(const <DaySchedule>[
      DaySchedule(
        day: 0,
        isOpen: true,
        openingTime: ClockTime(10, 0),
        closingTime: ClockTime(22, 0),
      ),
    ]);

    expect(client.calls.single.verb, 'PUT');
    expect(client.calls.single.path, ApiEndpoints.workingHours);
    expect(client.calls.single.body, <String, dynamic>{
      'days': <Map<String, dynamic>>[
        <String, dynamic>{
          'day': 0,
          'is_open': true,
          'opening_time': '10:00',
          'closing_time': '22:00',
        },
      ],
    });
  });

  test('save returns the schedule the server answered with', () async {
    final result = await repository.saveWorkingHours(const <DaySchedule>[]);

    expect(
      result.fold((_) => null, (List<DaySchedule> d) => d[5].isOpen),
      false,
    );
  });

  test('a malformed response is a server failure', () async {
    client.response = <String, dynamic>{'message': 'ok'};

    final result = await repository.getWorkingHours();

    expect(result.fold((Failure f) => f, (_) => null), isA<ServerFailure>());
  });

  test('maps a validation error to its failure', () async {
    client.error = const ServerException(message: 'Invalid closing time.');

    final result = await repository.saveWorkingHours(const <DaySchedule>[]);

    expect(
      result.fold((Failure f) => f, (_) => null),
      const ServerFailure(message: 'Invalid closing time.'),
    );
  });
}
