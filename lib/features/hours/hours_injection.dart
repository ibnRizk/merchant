import '../../injection_container.dart';
import 'data/datasources/working_hours_remote_data_source.dart';
import 'data/repos/working_hours_repository_impl.dart';
import 'domain/repos/working_hours_repository.dart';
import 'presentation/cubit/working_hours/working_hours_cubit.dart';

/// The cubit is a factory, provided at the home route with the other tabs.
Future<void> initHoursFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<WorkingHoursCubit>(
    () => WorkingHoursCubit(repository: ServiceLocator.instance()),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<WorkingHoursRepository>(
    () => WorkingHoursRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<WorkingHoursRemoteDataSource>(
    () => WorkingHoursRemoteDataSourceImpl(client: ServiceLocator.instance()),
  );
}
