import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repos/launch_repository.dart';
import 'onboarding_state.dart';

export 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final LaunchRepository _repository;

  OnboardingCubit({required LaunchRepository repository})
    : _repository = repository,
      super(const OnboardingInProgress());

  /// Called by both "Get started" and "Skip".
  Future<void> complete() async {
    if (state is OnboardingCompleted) return;
    // Emit first so a double tap can't save twice. If saving fails, the
    // merchant still continues; onboarding just shows again next launch.
    emit(const OnboardingCompleted());
    await _repository.markOnboardingSeen();
  }
}
