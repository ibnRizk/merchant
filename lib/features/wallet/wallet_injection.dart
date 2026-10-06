import '../../injection_container.dart';
import 'data/datasources/wallet_remote_data_source.dart';
import 'data/repos/wallet_repository_impl.dart';
import 'domain/repos/wallet_repository.dart';
import 'presentation/cubit/wallet_cubit.dart';

/// The cubit is a factory, provided by the wallet route.
Future<void> initWalletFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<WalletCubit>(
    () => WalletCubit(repository: ServiceLocator.instance()),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(client: ServiceLocator.instance()),
  );
}
