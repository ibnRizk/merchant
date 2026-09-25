import '../../../domain/entities/launch_destination.dart';

sealed class SplashState {
  const SplashState();
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

final class SplashResolved extends SplashState {
  final LaunchDestination destination;

  const SplashResolved(this.destination);
}
