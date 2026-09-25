import 'package:ssm_merchant/core/api/api_endpoints.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ssm_merchant/features/profile/data/repos/profile_repository_impl.dart';
import 'package:ssm_merchant/features/profile/domain/params/update_profile_params.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile_fakes.dart';

void main() {
  late FakeDioConsumer client;
  late FakeSecureStorage storage;
  late ProfileRepositoryImpl repository;

  setUp(() {
    client = FakeDioConsumer();
    storage = FakeSecureStorage(accessToken: 'token');
    repository = ProfileRepositoryImpl(
      remote: ProfileRemoteDataSourceImpl(client: client),
      secureStorage: storage,
    );
  });

  group('getProfile', () {
    test('returns the parsed profile', () async {
      client.response = <String, dynamic>{
        'id': 7,
        'f_name': 'Sara',
        'stores': <dynamic>[
          <String, dynamic>{'id': 42, 'name': 'Mazaq'},
        ],
      };

      final result = await repository.getProfile();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected success'), (profile) {
        expect(profile.firstName, 'Sara');
        expect(profile.store?.name, 'Mazaq');
      });
      expect(client.calls.single.path, ApiEndpoints.vendorProfile);
    });

    test('maps an AppException to its failure', () async {
      client.error = const InternetConnectionException(message: 'offline');

      final result = await repository.getProfile();

      expect(
        result.swap().getOrElse(() => throw 'no failure'),
        const NetworkFailure(message: 'offline'),
      );
    });

    test('fails when the response is not a JSON object', () async {
      client.response = 'unexpected';

      final result = await repository.getProfile();

      expect(result.isLeft(), isTrue);
    });
  });

  group('updateProfile', () {
    test('PATCHes only the changed fields', () async {
      client.response = <String, dynamic>{'id': 7};

      await repository.updateProfile(
        const UpdateProfileParams(storeName: 'New Name'),
      );

      expect(client.calls.single.verb, 'PATCH');
      expect(client.calls.single.body, <String, dynamic>{
        'store_name': 'New Name',
      });
    });
  });

  group('logout', () {
    test('revokes the token and clears it locally', () async {
      final result = await repository.logout();

      expect(result.isRight(), isTrue);
      expect(client.calls.single.path, ApiEndpoints.vendorLogout);
      expect(storage.accessToken, isNull);
    });

    test('still clears the token when the server call fails', () async {
      client.error = const InternetConnectionException(message: 'offline');

      final result = await repository.logout();

      expect(result.isRight(), isTrue);
      expect(storage.accessToken, isNull);
    });
  });
}
