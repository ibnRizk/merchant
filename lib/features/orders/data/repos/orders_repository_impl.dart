import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../../../core/utils/idempotency_key.dart';
import '../../domain/entities/merchant_order.dart';
import '../../domain/entities/order_line.dart';
import '../../domain/params/order_command.dart';
import '../../domain/repos/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  /// Page size for the history list (the API allows 1–100).
  static const int pageSize = 20;

  final OrdersRemoteDataSource _remote;
  final String Function() _newKey;

  /// Keys of commands whose last attempt failed on the network: the server
  /// may have applied them, so a retry must reuse the key rather than risk
  /// acting twice. Lives as long as this (singleton) repository.
  final Map<OrderCommand, String> _unconfirmedKeys = <OrderCommand, String>{};

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
  ) async {
    final String key = _unconfirmedKeys[command] ?? _newKey();
    final Either<Failure, OrderStatusChange> result = await guardFailure(
      () => _remote.sendCommand(command, idempotencyKey: key),
    );
    if (result.fold((Failure f) => f is NetworkFailure, (_) => false)) {
      _unconfirmedKeys[command] = key;
    } else {
      _unconfirmedKeys.remove(command);
    }
    return result;
  }
}
