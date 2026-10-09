import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/core/services/push/push_notification_service.dart';
import 'package:ssm_merchant/features/notifications/data/datasources/realtime_remote_data_source.dart';
import 'package:ssm_merchant/features/notifications/data/datasources/realtime_socket.dart';
import 'package:ssm_merchant/features/notifications/domain/entities/app_notification.dart';
import 'package:ssm_merchant/features/notifications/domain/entities/notifications_page.dart';
import 'package:ssm_merchant/features/notifications/domain/repos/notifications_repository.dart';
import 'package:ssm_merchant/features/notifications/domain/repos/push_token_repository.dart';
import 'package:ssm_merchant/features/notifications/domain/repos/realtime_repository.dart';

export '../../helpers/fake_dio_consumer.dart';

AppNotification notification(
  String id, {
  bool isRead = false,
  int? orderId,
  DateTime? createdAt,
}) => AppNotification(
  id: id,
  title: 'Title $id',
  body: 'Body $id',
  kind: NotificationKind.general,
  isRead: isRead,
  orderId: orderId,
  createdAt: createdAt,
);

class FakeNotificationsRepository implements NotificationsRepository {
  /// Keyed by page number; a missing page answers an empty last page.
  final Map<int, Either<Failure, NotificationsPage>> pages =
      <int, Either<Failure, NotificationsPage>>{};
  Either<Failure, int> unreadCount = const Right<Failure, int>(0);
  Either<Failure, Unit> markResult = const Right<Failure, Unit>(unit);
  Either<Failure, Unit> markAllResult = const Right<Failure, Unit>(unit);

  final List<int> requestedPages = <int>[];
  final List<String> markedIds = <String>[];
  int markAllCalls = 0;

  @override
  Future<Either<Failure, NotificationsPage>> getNotifications({
    int page = 1,
  }) async {
    requestedPages.add(page);
    return pages[page] ??
        const Right<Failure, NotificationsPage>(
          NotificationsPage(items: <AppNotification>[], hasMore: false),
        );
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async => unreadCount;

  @override
  Future<Either<Failure, Unit>> markAsRead(String id) async {
    markedIds.add(id);
    return markResult;
  }

  @override
  Future<Either<Failure, Unit>> markAllAsRead() async {
    markAllCalls++;
    return markAllResult;
  }
}

class FakePushTokenRepository implements PushTokenRepository {
  Either<Failure, Unit> registerResult = const Right<Failure, Unit>(unit);
  final StreamController<String> refreshes =
      StreamController<String>.broadcast();
  final List<String> registeredTokens = <String>[];
  int registerDeviceCalls = 0;
  int unregisterCalls = 0;

  /// Runs inside [unregisterDevice], to observe call order.
  void Function()? onUnregister;

  @override
  Future<Either<Failure, Unit>> registerDevice() async {
    registerDeviceCalls++;
    return registerResult;
  }

  @override
  Future<Either<Failure, Unit>> registerToken(String token) async {
    registeredTokens.add(token);
    return const Right<Failure, Unit>(unit);
  }

  @override
  Stream<String> get tokenRefreshes => refreshes.stream;

  @override
  Future<Either<Failure, Unit>> unregisterDevice() async {
    unregisterCalls++;
    onUnregister?.call();
    return const Right<Failure, Unit>(unit);
  }
}

class FakeRealtimeRepository implements RealtimeRepository {
  Either<Failure, Unit> connectResult = const Right<Failure, Unit>(unit);
  int connectCalls = 0;
  int disconnectCalls = 0;

  @override
  Future<Either<Failure, Unit>> connect() async {
    connectCalls++;
    return connectResult;
  }

  @override
  Future<void> disconnect() async => disconnectCalls++;
}

class FakePushTokenProvider implements PushTokenProvider {
  String? token = 'device-token';
  Object? getTokenError;
  int permissionRequests = 0;
  int deleteCalls = 0;
  final List<String> calls = <String>[];

  @override
  Future<void> requestPermission() async {
    permissionRequests++;
    calls.add('requestPermission');
  }

  @override
  Future<String?> getToken() async {
    calls.add('getToken');
    if (getTokenError != null) throw getTokenError!;
    return token;
  }

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();

  @override
  Future<void> deleteToken() async {
    deleteCalls++;
    calls.add('deleteToken');
  }
}

class FakeRealtimeRemoteDataSource implements RealtimeRemoteDataSource {
  int merchantId = 77;
  Object? error;
  final List<({String socketId, String channelName})> authorizations =
      <({String socketId, String channelName})>[];

  @override
  Future<int> getMerchantId() async {
    if (error != null) throw error!;
    return merchantId;
  }

  @override
  Future<String> authorizeChannel({
    required String socketId,
    required String channelName,
  }) async {
    authorizations.add((socketId: socketId, channelName: channelName));
    return 'key:signature';
  }
}

class FakeRealtimeSocket implements RealtimeSocket {
  final StreamController<RealtimeSocketMessage> messageController =
      StreamController<RealtimeSocketMessage>.broadcast();
  final StreamController<void> subscribedController =
      StreamController<void>.broadcast();

  String? openedChannel;
  ChannelAuthorizer? authorizer;
  int closeCalls = 0;

  @override
  Stream<RealtimeSocketMessage> get messages => messageController.stream;

  @override
  Stream<void> get subscribed => subscribedController.stream;

  @override
  Future<void> open({
    required String channelName,
    required ChannelAuthorizer authorize,
  }) async {
    openedChannel = channelName;
    authorizer = authorize;
  }

  @override
  Future<void> close() async => closeCalls++;
}
