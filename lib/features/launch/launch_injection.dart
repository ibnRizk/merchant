import '../../injection_container.dart';
import 'data/repos/launch_repository_impl.dart';
import 'domain/repos/launch_repository.dart';
import 'presentation/cubit/onboarding/onboarding_cubit.dart';
import 'presentation/cubit/splash/splash_cubit.dart';

/// Splash and onboarding. Cubits are factories provided at their routes.
Future<void> initLaunchFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance
    ..registerFactory<SplashCubit>(
      () => SplashCubit(repository: ServiceLocator.instance()),
    )
    ..registerFactory<OnboardingCubit>(
      () => OnboardingCubit(repository: ServiceLocator.instance()),
    );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<LaunchRepository>(
    () => LaunchRepositoryImpl(
      preferences: ServiceLocator.instance(),
      secureStorage: ServiceLocator.instance(),
    ),
  );
}
