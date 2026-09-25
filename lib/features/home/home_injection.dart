import '../../injection_container.dart';
import 'data/datasources/store_status_remote_data_source.dart';
import 'data/repos/store_status_repository_impl.dart';
import 'domain/repos/store_status_repository.dart';
import 'presentation/cubit/dashboard/dashboard_cubit.dart';
import 'presentation/cubit/store_status/store_status_cubit.dart';

/// Cubits are factories, provided at the home route. The dashboard reuses
/// the orders feature's repository.
Future<void> initHomeFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance
    ..registerFactory<DashboardCubit>(
      () => DashboardCubit(repository: ServiceLocator.instance()),
    )
    ..registerFactory<StoreStatusCubit>(
      () => StoreStatusCubit(repository: ServiceLocator.instance()),
    );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<StoreStatusRepository>(
    () => StoreStatusRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<StoreStatusRemoteDataSource>(
    () => StoreStatusRemoteDataSourceImpl(client: ServiceLocator.instance()),
  );
}
