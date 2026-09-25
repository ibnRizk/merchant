import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/merchant_order.dart';
import '../entities/order_line.dart';
import '../params/order_command.dart';

/// The merchant's orders. Every route needs an approved account.
abstract class OrdersRepository {
  /// New (`pendingMerchant`) and active orders; not paginated.
  Future<Either<Failure, List<MerchantOrder>>> getCurrentOrders();

  /// Finished orders, one page at a time; [page] starts at 1.
  Future<Either<Failure, OrderHistoryPage>> getCompletedOrders({
    required int page,
  });

  Future<Either<Failure, MerchantOrder>> getOrder(int orderId);

  Future<Either<Failure, List<OrderLine>>> getOrderLines(int orderId);

  /// Sends [command] with an `Idempotency-Key`. Retrying the same command
  /// after a network failure reuses its key, so the server applies it once.
  /// Fails with a `ConflictFailure` when `expectedVersion` is stale.
  Future<Either<Failure, OrderStatusChange>> sendCommand(OrderCommand command);
}
