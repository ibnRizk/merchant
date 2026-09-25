import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../domain/params/update_profile_params.dart';
import '../../../domain/repos/profile_repository.dart';
import 'profile_state.dart';

export 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit({required ProfileRepository repository})
    : _repository = repository,
      super(const ProfileInitial());

  Future<void> loadProfile() async {
    if (state is ProfileLoading) return;
    emit(const ProfileLoading());

    final result = await _repository.getProfile();
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => ProfileLoadFailure(failure.displayMessage),
        ProfileLoaded.new,
      ),
    );
  }

  /// Sends only the fields that differ from the loaded profile.
  Future<void> saveProfile({
    required String firstName,
    required String lastName,
    required String storeName,
    required String storePhone,
    required String storeEmail,
    required String storeAddress,
  }) async {
    final ProfileState current = state;
    if (current is! ProfileReady || current is ProfileSaving) return;

    final UpdateProfileParams params = UpdateProfileParams.changesFrom(
      current.profile,
      firstName: firstName,
      lastName: lastName,
      storeName: storeName,
      storePhone: storePhone,
      storeEmail: storeEmail,
      storeAddress: storeAddress,
    );
    if (params.isEmpty) {
      emit(ProfileUnchanged(current.profile));
      return;
    }

    emit(ProfileSaving(current.profile));
    final result = await _repository.updateProfile(params);
    if (isClosed) return;

    emit(
      result.fold(
        (failure) =>
            ProfileSaveFailure(current.profile, failure.displayMessage),
        ProfileSaved.new,
      ),
    );
  }
}
