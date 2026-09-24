import '../../config/env/app_env.dart';
import '../../injection_container.dart';
import 'data/datasources/merchant_auth_remote_data_source.dart';
import 'data/repos/merchant_auth_repository_impl.dart';
import 'domain/repos/merchant_auth_repository.dart';
import 'presentation/cubit/forgot_password/forgot_password_cubit.dart';
import 'presentation/cubit/login/login_cubit.dart';
import 'presentation/cubit/register/register_cubit.dart';
import 'presentation/cubit/store_categories/store_categories_cubit.dart';

/// Cubits are factories (fresh per screen); the repository and data source
/// are stateless lazy singletons. Cubits are provided at their routes.
Future<void> initAuthFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance
    ..registerFactory<LoginCubit>(
      () => LoginCubit(repository: ServiceLocator.instance()),
    )
    ..registerFactory<RegisterCubit>(
      () => RegisterCubit(repository: ServiceLocator.instance()),
    )
    ..registerFactory<StoreCategoriesCubit>(
      () => StoreCategoriesCubit(repository: ServiceLocator.instance()),
    )
    ..registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(repository: ServiceLocator.instance()),
    );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<MerchantAuthRepository>(
    () => MerchantAuthRepositoryImpl(
      remote: ServiceLocator.instance(),
      secureStorage: ServiceLocator.instance(),
    ),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<MerchantAuthRemoteDataSource>(
    () => MerchantAuthRemoteDataSourceImpl(
      client: ServiceLocator.instance(),
      zoneId: AppEnv.defaultZoneId,
      moduleId: AppEnv.defaultModuleId,
    ),
  );
}
