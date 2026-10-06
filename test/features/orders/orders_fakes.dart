import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/orders/domain/entities/merchant_order.dart';
import 'package:ssm_merchant/features/orders/domain/entities/order_line.dart';
import 'package:ssm_merchant/features/orders/domain/entities/order_status.dart';
import 'package:ssm_merchant/features/orders/domain/params/order_command.dart';
import 'package:ssm_merchant/features/orders/domain/repos/orders_repository.dart';

export '../../helpers/fake_dio_consumer.dart';

MerchantOrder anOrder(
  int id, {
  OrderStatus status = OrderStatus.pendingMerchant,
  int? version = 1,
  DateTime? createdAt,
}) => MerchantOrder(
  id: id,
  status: status,
  statusVersion: version,
  amount: 50,
  createdAt: createdAt,
);

const OrderLine burgerLine = OrderLine(
  id: 1,
  name: 'Burger',
  quantity: 2,
  unitPrice: 20,
);

OrderHistoryPage historyPage(
  List<MerchantOrder> orders, {
  int page = 1,
  int limit = 20,
  int? total,
}) => OrderHistoryPage(
  orders: orders,
  page: page,
  limit: limit,
  totalSize: total ?? orders.length,
);

/// Answers from overridable handlers and records every command.
class FakeOrdersRepository implements OrdersRepository {
  Future<Either<Failure, List<MerchantOrder>>> Function() onGetCurrent =
      () async => Right(<MerchantOrder>[
        anOrder(1),
        anOrder(2, status: OrderStatus.accepted),
        anOrder(3, status: OrderStatus.preparing),
      ]);

  Future<Either<Failure, OrderHistoryPage>> Function(int page) onGetCompleted =
      (_) async => Right(
        historyPage(<MerchantOrder>[
          anOrder(10, status: OrderStatus.delivered),
          anOrder(11, status: OrderStatus.rejected),
        ]),
      );

  Either<Failure, MerchantOrder> orderResult = Right(
    anOrder(1, status: OrderStatus.accepted),
  );
  Either<Failure, List<OrderLine>> linesResult = const Right(<OrderLine>[
    burgerLine,
  ]);

  Future<Either<Failure, OrderStatusChange>> Function(OrderCommand command)
  onSendCommand = (OrderCommand command) async => Right(
    OrderStatusChange(
      orderId: command.orderId,
      status: switch (command.action) {
        OrderAction.accept => OrderStatus.accepted,
        OrderAction.reject => OrderStatus.rejected,
        OrderAction.startPreparing => OrderStatus.preparing,
        OrderAction.readyForPickup => OrderStatus.readyForPickup,
      },
      statusVersion: (command.expectedVersion ?? 0) + 1,
    ),
  );

  final List<int> completedRequests = <int>[];
  final List<OrderCommand> commands = <OrderCommand>[];
  final List<int> retriedDispatches = <int>[];
  Either<Failure, Unit> retryDispatchResult = const Right(unit);
  int currentRequests = 0;

  @override
  Future<Either<Failure, List<MerchantOrder>>> getCurrentOrders() {
    currentRequests++;
    return onGetCurrent();
  }

  @override
  Future<Either<Failure, OrderHistoryPage>> getCompletedOrders({
    required int page,
  }) {
    completedRequests.add(page);
    return onGetCompleted(page);
  }

  @override
  Future<Either<Failure, MerchantOrder>> getOrder(int orderId) async =>
      orderResult;

  @override
  Future<Either<Failure, List<OrderLine>>> getOrderLines(int orderId) async =>
      linesResult;

  @override
  Future<Either<Failure, OrderStatusChange>> sendCommand(OrderCommand command) {
    commands.add(command);
    return onSendCommand(command);
  }

  @override
  Future<Either<Failure, Unit>> retryDispatch(int orderId) async {
    retriedDispatches.add(orderId);
    return retryDispatchResult;
  }
}
