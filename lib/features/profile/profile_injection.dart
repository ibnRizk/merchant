import '../../injection_container.dart';
import 'data/datasources/profile_remote_data_source.dart';
import 'data/repos/profile_repository_impl.dart';
import 'domain/repos/profile_repository.dart';
import 'presentation/cubit/logout/logout_cubit.dart';
import 'presentation/cubit/profile/profile_cubit.dart';

/// Cubits are factories (fresh per screen); the repository and data source
/// are stateless lazy singletons. Cubits are provided at the home route.
Future<void> initProfileFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance
    ..registerFactory<ProfileCubit>(
      () => ProfileCubit(repository: ServiceLocator.instance()),
    )
    ..registerFactory<LogoutCubit>(
      () => LogoutCubit(repository: ServiceLocator.instance()),
    );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remote: ServiceLocator.instance(),
      secureStorage: ServiceLocator.instance(),
    ),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(client: ServiceLocator.instance()),
  );
}
