import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/notifications_page.dart';

abstract class NotificationsRepository {
  /// [page] starts at 1.
  Future<Either<Failure, NotificationsPage>> getNotifications({int page = 1});

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, Unit>> markAsRead(String id);

  Future<Either<Failure, Unit>> markAllAsRead();
}
