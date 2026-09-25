import 'package:flutter_base/core/error/exceptions.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/home/data/datasources/store_status_remote_data_source.dart';
import 'package:flutter_base/features/home/data/repos/store_status_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_dio_consumer.dart';

void main() {
  late FakeDioConsumer client;
  late StoreStatusRepositoryImpl repository;

  setUp(() {
    client = FakeDioConsumer();
    repository = StoreStatusRepositoryImpl(
      remote: StoreStatusRemoteDataSourceImpl(client: client),
    );
  });

  test('returns the server status on success', () async {
    client.response = <String, dynamic>{'message': 'ok', 'active': true};

    final result = await repository.setStoreOpen(isOpen: true);

    expect(result.fold((_) => null, (bool isOpen) => isOpen), isTrue);
  });

  test('maps an exception to its failure', () async {
    client.error = const UnauthorizedException(
      message: 'merchant-not-approved',
    );

    final result = await repository.setStoreOpen(isOpen: true);

    expect(
      result.fold((Failure f) => f, (_) => null),
      const UnauthorizedFailure(message: 'merchant-not-approved'),
    );
  });
}
