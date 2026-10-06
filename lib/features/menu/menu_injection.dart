import '../../injection_container.dart';
import 'data/datasources/catalog_remote_data_source.dart';
import 'data/repos/catalog_repository_impl.dart';
import 'domain/repos/catalog_repository.dart';
import 'presentation/cubit/menu/menu_cubit.dart';
import 'presentation/cubit/product_form/product_form_cubit.dart';
import 'presentation/cubit/product_options/product_options_cubit.dart';

/// Cubits are factories (fresh per screen); the repository and data source
/// are stateless lazy singletons. Cubits are provided at their routes.
Future<void> initMenuFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance
    ..registerFactory<MenuCubit>(
      () => MenuCubit(repository: ServiceLocator.instance()),
    )
    ..registerFactory<ProductFormCubit>(
      () => ProductFormCubit(repository: ServiceLocator.instance()),
    )
    ..registerFactory<ProductOptionsCubit>(
      () => ProductOptionsCubit(repository: ServiceLocator.instance()),
    );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(remote: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSourceImpl(client: ServiceLocator.instance()),
  );
}
