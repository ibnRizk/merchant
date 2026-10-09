import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/services/push/push_target.dart';

void main() {
  test('an order id in the data opens that order', () {
    expect(
      PushTarget.fromData(const <String, dynamic>{'order_id': '42'}),
      const OrderPushTarget(42),
    );
    expect(
      PushTarget.fromData(const <String, dynamic>{'orderId': 7}),
      const OrderPushTarget(7),
    );
  });

  test('anything else opens the inbox', () {
    expect(
      PushTarget.fromData(const <String, dynamic>{'type': 'promo'}),
      const InboxPushTarget(),
    );
    expect(
      PushTarget.fromData(const <String, dynamic>{'order_id': ''}),
      const InboxPushTarget(),
    );
    expect(
      PushTarget.fromData(const <String, dynamic>{'order_id': '0'}),
      const InboxPushTarget(),
    );
  });
}
