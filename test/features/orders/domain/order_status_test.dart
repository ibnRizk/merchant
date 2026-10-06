import 'package:ssm_merchant/features/orders/domain/entities/merchant_order.dart';
import 'package:ssm_merchant/features/orders/domain/entities/order_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../orders_fakes.dart';

void main() {
  test('an unknown API status parses as unknown', () {
    expect(OrderStatus.fromApi('teleported'), OrderStatus.unknown);
  });

  test('the next action follows the merchant lifecycle', () {
    expect(OrderStatus.pendingMerchant.nextAction, OrderAction.accept);
    expect(OrderStatus.accepted.nextAction, OrderAction.startPreparing);
    expect(OrderStatus.preparing.nextAction, OrderAction.readyForPickup);
    expect(OrderStatus.dispatching.nextAction, isNull);
  });

  test('a failed driver assignment can be retried', () {
    expect(OrderStatus.assignmentFailed.nextAction, OrderAction.retryDispatch);
    expect(OrderStatus.assignmentFailed.isActive, isTrue);
    expect(OrderStatus.assignmentFailed.isCancelled, isFalse);
  });

  test('retry dispatch posts to the retry-dispatch route', () {
    expect(OrderAction.retryDispatch.path, 'retry-dispatch');
  });

  test('dispatch stages are active, not new or terminal', () {
    expect(OrderStatus.driverAssigned.isActive, isTrue);
    expect(OrderStatus.driverAssigned.isNew, isFalse);
    expect(OrderStatus.driverAssigned.isTerminal, isFalse);
  });

  test('applyChange keeps the status when the new one is unknown', () {
    final MerchantOrder updated = anOrder(1, status: OrderStatus.accepted)
        .applyChange(
          const OrderStatusChange(
            orderId: 1,
            status: OrderStatus.unknown,
            statusVersion: 5,
          ),
        );

    expect(updated.status, OrderStatus.accepted);
    expect(updated.statusVersion, 5);
  });
}
