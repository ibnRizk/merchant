import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/pharmacy/presentation/cubit/requests/pharmacy_requests_cubit.dart';

import '../pharmacy_fakes.dart';

void main() {
  late FakePharmacyRepository repository;
  late PharmacyRequestsCubit cubit;

  setUp(() {
    repository = FakePharmacyRepository();
    cubit = PharmacyRequestsCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('load lists the requests', () async {
    await cubit.load();

    expect((cubit.state as PharmacyRequestsLoaded).requests, hasLength(2));
  });

  test('a failed refresh keeps the list and reports it', () async {
    await cubit.load();
    repository.requestsResult = const Left(NetworkFailure(message: 'offline'));

    await cubit.refresh();

    final PharmacyRequestsLoaded state = cubit.state as PharmacyRequestsLoaded;
    expect(state.requests, hasLength(2));
    expect(state.refreshFailure?.message, 'offline');
  });
}
