import '../../injection_container.dart';
import 'data/datasources/orders_remote_data_source.dart';
import 'data/repos/orders_repository_impl.dart';
import 'domain/repos/orders_repository.dart';
import 'presentation/cubit/current_orders/current_orders_cubit.dart';
import 'presentation/cubit/order_details/order_details_cubit.dart';
import 'presentation/cubit/orders_history/orders_history_cubit.dart';

/// Cubits are factories (fresh per screen). The repository is a lazy
/// singleton on purpose: it remembers idempotency keys for commands that
/// must be retried with the same key.
Future<void> initOrdersFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance
    ..registerFactory<OrdersHistoryCubit>(
      () => OrdersHistoryCubit(repository: ServiceLocator.instance()),
    )
    ..registerFactory<CurrentOrdersCubit>(
      () => CurrentOrdersCubit(repository: ServiceLocator.instance()),
    )
    ..registerFactory<OrderDetailsCubit>(
      () => OrderDetailsCubit(repository: ServiceLocator.instance()),
    );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(client: ServiceLocator.instance()),
  );
}
