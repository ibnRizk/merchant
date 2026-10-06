import '../../injection_container.dart';
import 'data/datasources/pharmacy_remote_data_source.dart';
import 'data/repos/pharmacy_repository_impl.dart';
import 'domain/repos/pharmacy_repository.dart';
import 'presentation/cubit/request/pharmacy_request_cubit.dart';
import 'presentation/cubit/requests/pharmacy_requests_cubit.dart';

/// Cubits are factories, provided at their routes.
Future<void> initPharmacyFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance
    ..registerFactory<PharmacyRequestsCubit>(
      () => PharmacyRequestsCubit(repository: ServiceLocator.instance()),
    )
    ..registerFactory<PharmacyRequestCubit>(
      () => PharmacyRequestCubit(repository: ServiceLocator.instance()),
    );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<PharmacyRepository>(
    () => PharmacyRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<PharmacyRemoteDataSource>(
    () => PharmacyRemoteDataSourceImpl(client: ServiceLocator.instance()),
  );
}
