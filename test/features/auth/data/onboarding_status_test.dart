import 'package:ssm_merchant/core/api/api_endpoints.dart';
import 'package:ssm_merchant/core/entities/merchant_approval_status.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/auth/data/datasources/merchant_auth_remote_data_source.dart';
import 'package:ssm_merchant/features/auth/data/models/onboarding_status_model.dart';
import 'package:ssm_merchant/features/auth/data/repos/merchant_auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../launch/launch_fakes.dart';
import '../auth_fakes.dart';

void main() {
  group('OnboardingStatusModel', () {
    MerchantApprovalStatus statusOf(Map<String, dynamic> json) =>
        OnboardingStatusModel.fromJson(json).status;

    test('can_operate means approved', () {
      expect(
        statusOf(<String, dynamic>{
          'approval_status': 'approved',
          'can_operate': true,
        }),
        MerchantApprovalStatus.approved,
      );
    });

    test('pending and cannot operate is pending', () {
      expect(
        statusOf(<String, dynamic>{
          'approval_status': 'pending',
          'can_operate': false,
        }),
        MerchantApprovalStatus.pending,
      );
    });

    test('approved but cannot operate is suspended', () {
      expect(
        statusOf(<String, dynamic>{
          'approval_status': 'approved',
          'can_operate': false,
          'account_status': 'suspended',
        }),
        MerchantApprovalStatus.suspended,
      );
    });

    test('rejected keeps the rejection reason', () {
      final OnboardingStatusModel model = OnboardingStatusModel.fromJson(
        <String, dynamic>{
          'approval_status': 'rejected',
          'can_operate': false,
          'rejection_reason': 'Blurry commercial registration',
        },
      );

      expect(model.status, MerchantApprovalStatus.rejected);
      expect(model.rejectionReason, 'Blurry commercial registration');
    });

    test('an unknown status never grants access', () {
      expect(
        statusOf(<String, dynamic>{'approval_status': 'weird'}),
        MerchantApprovalStatus.pending,
      );
    });

    test('a blank rejection reason is null', () {
      expect(
        OnboardingStatusModel.fromJson(<String, dynamic>{
          'rejection_reason': '  ',
        }).rejectionReason,
        isNull,
      );
    });
  });

  group('repository', () {
    late FakeDioConsumer client;
    late FakeSecureStorage storage;
    late MerchantAuthRepositoryImpl repository;

    setUp(() {
      client = FakeDioConsumer();
      storage = FakeSecureStorage(accessToken: 'token');
      repository = MerchantAuthRepositoryImpl(
        remote: MerchantAuthRemoteDataSourceImpl(
          client: client,
          zoneId: 7,
          moduleId: 1,
        ),
        secureStorage: storage,
      );
    });

    test('getOnboardingStatus GETs the onboarding route', () async {
      client.response = <String, dynamic>{
        'approval_status': 'pending',
        'can_operate': false,
      };

      final result = await repository.getOnboardingStatus();

      expect(client.calls.single.verb, 'GET');
      expect(client.calls.single.path, ApiEndpoints.onboardingStatus);
      result.fold(
        (_) => fail('expected success'),
        (status) => expect(status.status, MerchantApprovalStatus.pending),
      );
    });

    test('getOnboardingStatus fails on a non-object body', () async {
      client.response = 'oops';

      final result = await repository.getOnboardingStatus();

      expect(result.isLeft(), isTrue);
    });

    test('clearSession removes the saved token', () async {
      final result = await repository.clearSession();

      expect(result.isRight(), isTrue);
      expect(storage.accessToken, isNull);
    });

    test('clearSession reports a keystore error', () async {
      final MerchantAuthRepositoryImpl failing = MerchantAuthRepositoryImpl(
        remote: MerchantAuthRemoteDataSourceImpl(
          client: client,
          zoneId: 7,
          moduleId: 1,
        ),
        secureStorage: _ThrowingRemoveStorage(),
      );

      final result = await failing.clearSession();

      expect(
        result.swap().getOrElse(() => throw 'no failure'),
        const CacheFailure(),
      );
    });
  });
}

class _ThrowingRemoveStorage extends FakeSecureStorage {
  @override
  Future<void> removeAccessToken() async => throw Exception('keystore');
}
