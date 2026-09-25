import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/hours/domain/entities/clock_time.dart';
import 'package:ssm_merchant/features/hours/domain/entities/day_schedule.dart';
import 'package:ssm_merchant/features/hours/domain/repos/working_hours_repository.dart';
import 'package:ssm_merchant/features/hours/presentation/cubit/working_hours/working_hours_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const List<DaySchedule> week = <DaySchedule>[
  DaySchedule(
    day: 0,
    isOpen: true,
    openingTime: ClockTime(10, 0),
    closingTime: ClockTime(22, 0),
  ),
  DaySchedule(day: 5, isOpen: false),
];

class FakeWorkingHoursRepository implements WorkingHoursRepository {
  Future<Either<Failure, List<DaySchedule>>> Function() onGet = () async =>
      const Right(week);
  Future<Either<Failure, List<DaySchedule>>> Function(List<DaySchedule>)
  onSave = (List<DaySchedule> days) async => Right(days);
  final List<List<DaySchedule>> saved = <List<DaySchedule>>[];

  @override
  Future<Either<Failure, List<DaySchedule>>> getWorkingHours() => onGet();

  @override
  Future<Either<Failure, List<DaySchedule>>> saveWorkingHours(
    List<DaySchedule> days,
  ) {
    saved.add(days);
    return onSave(days);
  }
}

void main() {
  late FakeWorkingHoursRepository repository;
  late WorkingHoursCubit cubit;

  List<DaySchedule> days() => (cubit.state as WorkingHoursReady).days;

  setUp(() {
    repository = FakeWorkingHoursRepository();
    cubit = WorkingHoursCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('load shows the server schedule', () async {
    await cubit.load();

    expect(cubit.state, isA<WorkingHoursEditing>());
    expect(days(), week);
  });

  test('load reports a failure', () async {
    repository.onGet = () async =>
        const Left(NetworkFailure(message: 'offline'));

    await cubit.load();

    expect((cubit.state as WorkingHoursLoadFailure).message, 'offline');
  });

  test('toggling a day changes only that day', () async {
    await cubit.load();

    cubit.setOpen(0, false);

    expect(days()[0].isOpen, isFalse);
    expect(days()[1], week[1]);
  });

  test('picking a time updates that day', () async {
    await cubit.load();

    cubit.setClosingTime(0, const ClockTime(2, 0));

    expect(days()[0].closingTime, const ClockTime(2, 0));
  });

  test('save sends the edited week', () async {
    await cubit.load();
    cubit.setOpen(5, true);

    await cubit.save();

    expect(repository.saved.single[1].isOpen, isTrue);
  });

  test('a successful save shows the server copy', () async {
    await cubit.load();
    repository.onSave = (_) async =>
        const Right(<DaySchedule>[DaySchedule(day: 0, isOpen: false)]);

    await cubit.save();

    expect(cubit.state, isA<WorkingHoursSaved>());
    expect(days(), const <DaySchedule>[DaySchedule(day: 0, isOpen: false)]);
  });

  test('a failed save keeps the edits and reports the message', () async {
    await cubit.load();
    cubit.setOpen(0, false);
    repository.onSave = (_) async =>
        const Left(ServerFailure(message: 'Invalid hours.'));

    await cubit.save();

    final WorkingHoursSaveFailure state =
        cubit.state as WorkingHoursSaveFailure;
    expect(state.message, 'Invalid hours.');
    expect(state.days[0].isOpen, isFalse);
  });

  test('edits and a second save are ignored while saving', () async {
    await cubit.load();
    final Completer<Either<Failure, List<DaySchedule>>> pending = Completer();
    repository.onSave = (_) => pending.future;

    final Future<void> first = cubit.save();
    cubit.setOpen(0, false);
    await cubit.save();

    expect(days()[0].isOpen, isTrue);
    expect(repository.saved, hasLength(1));
    pending.complete(const Right(week));
    await first;
  });

  test('ignores edits before the schedule loads', () {
    cubit.setOpen(0, false);

    expect(cubit.state, isA<WorkingHoursLoading>());
  });
}
