import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/profile/domain/entities/merchant_profile.dart';
import 'package:flutter_base/features/profile/domain/params/update_profile_params.dart';
import 'package:flutter_base/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile_fakes.dart';

void main() {
  late FakeProfileRepository repository;
  late ProfileCubit cubit;

  setUp(() {
    repository = FakeProfileRepository();
    cubit = ProfileCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  Future<void> save({String storeName = 'Mazaq'}) => cubit.saveProfile(
    firstName: 'Sara',
    lastName: 'Ali',
    storeName: storeName,
    storePhone: '+201111111111',
    storeEmail: 'store@example.com',
    storeAddress: 'Tahrir St',
  );

  group('loadProfile', () {
    test('emits loading then loaded', () async {
      final Future<List<ProfileState>> states = cubit.stream.take(2).toList();

      await cubit.loadProfile();

      final List<ProfileState> emitted = await states;
      expect(emitted[0], isA<ProfileLoading>());
      expect(emitted[1], isA<ProfileLoaded>());
      expect((emitted[1] as ProfileLoaded).profile, sampleProfile);
    });

    test('emits the failure message when loading fails', () async {
      repository.getResult = const Left<Failure, MerchantProfile>(
        NetworkFailure(message: 'offline'),
      );

      await cubit.loadProfile();

      expect(cubit.state, isA<ProfileLoadFailure>());
      expect((cubit.state as ProfileLoadFailure).message, 'offline');
    });
  });

  group('saveProfile', () {
    setUp(() => cubit.loadProfile());

    test('does not call the API when nothing changed', () async {
      await save();

      expect(cubit.state, isA<ProfileUnchanged>());
      expect(repository.updateCalls, isEmpty);
    });

    test('sends the changes and emits saving then saved', () async {
      final Future<List<ProfileState>> states = cubit.stream.take(2).toList();

      await save(storeName: 'New Name');

      final List<ProfileState> emitted = await states;
      expect(emitted[0], isA<ProfileSaving>());
      expect(emitted[1], isA<ProfileSaved>());
      expect(
        repository.updateCalls.single,
        const UpdateProfileParams(storeName: 'New Name'),
      );
    });

    test('keeps the loaded profile and reports the error on failure', () async {
      repository.updateResult = const Left<Failure, MerchantProfile>(
        ServerFailure(message: 'The store phone has already been taken.'),
      );

      await save(storeName: 'New Name');

      final ProfileState state = cubit.state;
      expect(state, isA<ProfileSaveFailure>());
      expect((state as ProfileSaveFailure).profile, sampleProfile);
      expect(state.message, 'The store phone has already been taken.');
    });

    test('is ignored before a profile has loaded', () async {
      final ProfileCubit fresh = ProfileCubit(repository: repository);
      addTearDown(fresh.close);

      await fresh.saveProfile(
        firstName: 'x',
        lastName: 'x',
        storeName: 'x',
        storePhone: 'x',
        storeEmail: 'x',
        storeAddress: 'x',
      );

      expect(fresh.state, isA<ProfileInitial>());
      expect(repository.updateCalls, isEmpty);
    });
  });
}
