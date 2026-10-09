import 'package:firebase_core/firebase_core.dart';

import '../../config/env/app_env.dart';
import '../../config/routes/push_tap_router.dart';
import '../../core/services/push/push_notification_service.dart';
import '../../injection_container.dart';
import 'data/datasources/notifications_remote_data_source.dart';
import 'data/datasources/realtime_remote_data_source.dart';
import 'data/datasources/realtime_socket.dart';
import 'data/repos/notifications_repository_impl.dart';
import 'data/repos/push_token_repository_impl.dart';
import 'data/repos/realtime_repository_impl.dart';
import 'domain/repos/notifications_repository.dart';
import 'domain/repos/push_token_repository.dart';
import 'domain/repos/realtime_repository.dart';
import 'presentation/cubit/live_updates/live_updates_cubit.dart';
import 'presentation/cubit/notifications/notifications_cubit.dart';
import 'presentation/cubit/unread_count/unread_count_cubit.dart';

/// Cubits are factories. The realtime repository and socket are singletons
/// on purpose: one connection per app, whichever cubit opened it.
Future<void> initNotificationsFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance
    ..registerFactory<NotificationsCubit>(
      () => NotificationsCubit(repository: ServiceLocator.instance()),
    )
    ..registerFactory<UnreadCountCubit>(
      () => UnreadCountCubit(repository: ServiceLocator.instance()),
    )
    ..registerFactory<LiveUpdatesCubit>(
      () => LiveUpdatesCubit(
        pushTokens: ServiceLocator.instance(),
        realtime: ServiceLocator.instance(),
      ),
    );

  /// Repository
  ServiceLocator.instance
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(remote: ServiceLocator.instance()),
    )
    ..registerLazySingleton<PushTokenRepository>(
      () => PushTokenRepositoryImpl(
        remote: ServiceLocator.instance(),
        device: ServiceLocator.instance<PushNotificationService>(),
      ),
    )
    ..registerLazySingleton<RealtimeRepository>(
      () => RealtimeRepositoryImpl(
        remote: ServiceLocator.instance(),
        socket: ServiceLocator.instance(),
        hub: ServiceLocator.instance(),
        isConfigured: _realtimeConfig.isConfigured,
      ),
    );

  /// DataSource
  ServiceLocator.instance
    ..registerLazySingleton<NotificationsRemoteDataSource>(
      () =>
          NotificationsRemoteDataSourceImpl(client: ServiceLocator.instance()),
    )
    ..registerLazySingleton<RealtimeRemoteDataSource>(
      () => RealtimeRemoteDataSourceImpl(client: ServiceLocator.instance()),
    )
    ..registerLazySingleton<RealtimeSocket>(
      () => PusherRealtimeSocket(config: _realtimeConfig),
    );

  /// Services
  ServiceLocator.instance
    // Resolved in main() after Firebase.initializeApp, so `apps` is final.
    ..registerLazySingleton<PushNotificationService>(
      () => PushNotificationService(firebaseReady: Firebase.apps.isNotEmpty),
    )
    ..registerLazySingleton<PushTapRouter>(
      () => PushTapRouter(push: ServiceLocator.instance()),
    );
}

RealtimeConfig get _realtimeConfig => RealtimeConfig(
  appKey: AppEnv.pusherAppKey,
  cluster: AppEnv.pusherCluster,
  host: AppEnv.pusherHost,
  port: AppEnv.pusherPort,
  scheme: AppEnv.pusherScheme,
);
