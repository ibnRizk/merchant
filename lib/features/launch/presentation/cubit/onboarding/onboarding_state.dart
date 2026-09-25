sealed class OnboardingState {
  const OnboardingState();
}

final class OnboardingInProgress extends OnboardingState {
  const OnboardingInProgress();
}

/// Onboarding was finished or skipped; continue to login.
final class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}
