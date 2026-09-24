import '../../../domain/entities/merchant_profile.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// The first load failed; there is no profile to show yet.
final class ProfileLoadFailure extends ProfileState {
  final String message;

  const ProfileLoadFailure(this.message);
}

/// A profile is on screen. The subtypes describe the latest save attempt.
sealed class ProfileReady extends ProfileState {
  final MerchantProfile profile;

  const ProfileReady(this.profile);
}

final class ProfileLoaded extends ProfileReady {
  const ProfileLoaded(super.profile);
}

final class ProfileSaving extends ProfileReady {
  const ProfileSaving(super.profile);
}

/// Holds the profile as the server saved it.
final class ProfileSaved extends ProfileReady {
  const ProfileSaved(super.profile);
}

/// Save was requested but nothing differs from [profile].
final class ProfileUnchanged extends ProfileReady {
  const ProfileUnchanged(super.profile);
}

/// Save failed; [profile] is still the last saved version.
final class ProfileSaveFailure extends ProfileReady {
  final String message;

  const ProfileSaveFailure(super.profile, this.message);
}
