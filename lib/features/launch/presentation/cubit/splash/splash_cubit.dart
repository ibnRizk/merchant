import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../auth/domain/repos/merchant_auth_repository.dart';
import '../../../domain/entities/launch_destination.dart';
import '../../../domain/repos/launch_repository.dart';
import 'splash_state.dart';

export 'splash_state.dart';

/// Decides where the app goes after the splash screen.
class SplashCubit extends Cubit<SplashState> {
  final LaunchRepository _repository;
  final MerchantAuthRepository _authRepository;

  /// Shortest time the splash stays visible, so it doesn't just flash.
  final Duration _minDisplay;

  SplashCubit({
    required LaunchRepository repository,
    required MerchantAuthRepository authRepository,
    Duration minDisplay = const Duration(milliseconds: 1500),
  }) : _repository = repository,
       _authRepository = authRepository,
       _minDisplay = minDisplay,
       super(const SplashLoading());

  Future<void> start() async {
    // The delay runs while the destination resolves, not after it.
    final Future<void> minDisplay = Future<void>.delayed(_minDisplay);
    final SplashResolved resolved = await _resolve();
    await minDisplay;
    if (isClosed) return;
    emit(resolved);
  }

  Future<SplashResolved> _resolve() async {
    // A saved session wins, so merchants who were already logged in before
    // onboarding existed never see it. Unreadable storage counts as "no".
    final bool hasSession = (await _repository.hasSession()).getOrElse(
      () => false,
    );
    if (hasSession) return _resolveSession();

    final bool seenOnboarding = (await _repository.hasSeenOnboarding())
        .getOrElse(() => false);
    return SplashResolved(
      seenOnboarding ? LaunchDestination.login : LaunchDestination.onboarding,
    );
  }

  /// A saved token is not proof the account can operate: a pending login
  /// saves one too, and an admin can suspend an approved account.
  Future<SplashResolved> _resolveSession() async {
    final result = await _authRepository.getOnboardingStatus();
    return result.fold(
      (Failure failure) => switch (failure) {
        // The token was revoked (the 401 has already cleared it).
        UnauthorizedFailure() => const SplashResolved(LaunchDestination.login),
        AccountRestrictedFailure(:final status) => SplashResolved(
          LaunchDestination.pendingApproval,
          approvalStatus: status,
        ),
        // Offline or a server error: let the merchant in. Home shows its own
        // errors, and any 403 still reroutes to the pending screen.
        _ => const SplashResolved(LaunchDestination.home),
      },
      (onboarding) => onboarding.canOperate
          ? const SplashResolved(LaunchDestination.home)
          : SplashResolved(
              LaunchDestination.pendingApproval,
              approvalStatus: onboarding.status,
            ),
    );
  }
}
