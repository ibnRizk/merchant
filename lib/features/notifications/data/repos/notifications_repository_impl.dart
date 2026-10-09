import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../domain/entities/notifications_page.dart';
import '../../domain/repos/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remote;

  const NotificationsRepositoryImpl({
    required NotificationsRemoteDataSource remote,
  }) : _remote = remote;

  @override
  Future<Either<Failure, NotificationsPage>> getNotifications({int page = 1}) =>
      guardFailure(() => _remote.getNotifications(page: page));

  @override
  Future<Either<Failure, int>> getUnreadCount() =>
      guardFailure(_remote.getUnreadCount);

  @override
  Future<Either<Failure, Unit>> markAsRead(String id) => guardFailure(() async {
    await _remote.markAsRead(id);
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> markAllAsRead() => guardFailure(() async {
    await _remote.markAllAsRead();
    return unit;
  });
}
