import '../../injection_container.dart';
import 'data/datasources/app_config_remote_data_source.dart';
import 'data/repos/app_config_repository_impl.dart';
import 'domain/repos/app_config_repository.dart';
import 'presentation/cubit/app_config_cubit.dart';

/// The cubit is a lazy singleton like ThemeCubit and LocaleCubit: one
/// config for the whole app, provided above the router.
Future<void> initAppConfigFeatureInjection() async {
  /// Cubit
  ServiceLocator.instance.registerLazySingleton<AppConfigCubit>(
    () => AppConfigCubit(repository: ServiceLocator.instance()),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<AppConfigRepository>(
    () => AppConfigRepositoryImpl(
      remote: ServiceLocator.instance(),
      preferences: ServiceLocator.instance(),
    ),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<AppConfigRemoteDataSource>(
    () => AppConfigRemoteDataSourceImpl(client: ServiceLocator.instance()),
  );
}
