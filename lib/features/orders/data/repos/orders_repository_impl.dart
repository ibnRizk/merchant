import 'package:dartz/dartz.dart';

import '../../../../core/api/status_code.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../../../core/utils/idempotency_key.dart';
import '../../domain/entities/merchant_order.dart';
import '../../domain/entities/order_line.dart';
import '../../domain/order_failures.dart';
import '../../domain/params/order_command.dart';
import '../../domain/repos/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  /// Page size for the history list (the API allows 1–100).
  static const int pageSize = 20;

  final OrdersRemoteDataSource _remote;
  final String Function() _newKey;

  /// Keys of requests whose last attempt failed on the network: the server
  /// may have applied them, so a retry must reuse the key rather than risk
  /// acting twice. Keyed by the [OrderCommand], or by a
  /// `(retryDispatch: orderId)` record. Lives as long as this (singleton)
  /// repository.
  final Map<Object, String> _unconfirmedKeys = <Object, String>{};

  OrdersRepositoryImpl({
    required OrdersRemoteDataSource remote,
    String Function() newKey = generateIdempotencyKey,
  }) : _remote = remote,
       _newKey = newKey;

  @override
  Future<Either<Failure, List<MerchantOrder>>> getCurrentOrders() =>
      guardFailure(_remote.getCurrentOrders);

  @override
  Future<Either<Failure, OrderHistoryPage>> getCompletedOrders({
    required int page,
  }) => guardFailure(
    () => _remote.getCompletedOrders(page: page, limit: pageSize),
  );

  @override
  Future<Either<Failure, MerchantOrder>> getOrder(int orderId) =>
      guardFailure(() => _remote.getOrder(orderId));

  @override
  Future<Either<Failure, List<OrderLine>>> getOrderLines(int orderId) =>
      guardFailure(() => _remote.getOrderLines(orderId));

  @override
  Future<Either<Failure, OrderStatusChange>> sendCommand(
    OrderCommand command,
  ) => _sendOnce(
    command,
    command.orderId,
    (String key) => _remote.sendCommand(command, idempotencyKey: key),
  );

  @override
  Future<Either<Failure, Unit>> retryDispatch(int orderId) => _sendOnce(
    (retryDispatch: orderId),
    orderId,
    (String key) async {
      await _remote.retryDispatch(orderId, idempotencyKey: key);
      return unit;
    },
  );

  /// Sends an order action with an `Idempotency-Key`, reusing the key of a
  /// [request] whose last attempt never got an answer.
  Future<Either<Failure, T>> _sendOnce<T>(
    Object request,
    int orderId,
    Future<T> Function(String key) send,
  ) async {
    final String key = _unconfirmedKeys[request] ?? _newKey();
    final Either<Failure, T> result = await guardFailure(() => send(key));
    return result.fold(
      (Failure failure) {
        if (failure is NetworkFailure) {
          _unconfirmedKeys[request] = key;
        } else {
          _unconfirmedKeys.remove(request);
        }
        return Left<Failure, T>(_staleOrderFailure(failure) ?? failure);
      },
      (T value) {
        // The order moved on: any other pending request for it is stale.
        _unconfirmedKeys.removeWhere(
          (Object pending, _) => _orderIdOf(pending) == orderId,
        );
        return Right<Failure, T>(value);
      },
    );
  }

  static int? _orderIdOf(Object request) => switch (request) {
    OrderCommand(:final int orderId) => orderId,
    (retryDispatch: final int orderId) => orderId,
    _ => null,
  };

  /// 422 `order_transition_invalid` and 404 mean the local copy of the order
  /// is stale. Other 422s are validation errors and keep their message.
  static Failure? _staleOrderFailure(Failure failure) {
    if (failure is! ServerFailure) return null;
    final bool transitionInvalid =
        failure.statusCode == StatusCode.unProcessableContent &&
        failure.code?.replaceAll('-', '_') == 'order_transition_invalid';
    if (!transitionInvalid && failure.statusCode != StatusCode.notFound) {
      return null;
    }
    return TransitionRejectedFailure(message: failure.message);
  }
}
