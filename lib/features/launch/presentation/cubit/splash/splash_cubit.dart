import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/launch_destination.dart';
import '../../../domain/repos/launch_repository.dart';
import 'splash_state.dart';

export 'splash_state.dart';

/// Decides where the app goes after the splash screen.
class SplashCubit extends Cubit<SplashState> {
  final LaunchRepository _repository;

  /// Shortest time the splash stays visible, so it doesn't just flash.
  final Duration _minDisplay;

  SplashCubit({
    required LaunchRepository repository,
    Duration minDisplay = const Duration(milliseconds: 1500),
  }) : _repository = repository,
       _minDisplay = minDisplay,
       super(const SplashLoading());

  Future<void> start() async {
    // The delay runs while the destination resolves, not after it.
    final Future<void> minDisplay = Future<void>.delayed(_minDisplay);
    final LaunchDestination destination = await _resolveDestination();
    await minDisplay;
    if (isClosed) return;
    emit(SplashResolved(destination));
  }

  Future<LaunchDestination> _resolveDestination() async {
    // A saved session wins, so merchants who were already logged in before
    // onboarding existed never see it. Unreadable storage counts as "no".
    final bool hasSession = (await _repository.hasSession()).getOrElse(
      () => false,
    );
    if (hasSession) return LaunchDestination.home;

    final bool seenOnboarding = (await _repository.hasSeenOnboarding())
        .getOrElse(() => false);
    return seenOnboarding
        ? LaunchDestination.login
        : LaunchDestination.onboarding;
  }
}
