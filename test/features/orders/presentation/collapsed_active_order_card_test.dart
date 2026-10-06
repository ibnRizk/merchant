import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/config/themes/app_theme.dart';
import 'package:ssm_merchant/core/utils/values/strings.dart';
import 'package:ssm_merchant/features/orders/domain/entities/order_status.dart';
import 'package:ssm_merchant/features/orders/presentation/widgets/collapsed_active_order_card.dart';

import '../orders_fakes.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget card) => tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(
        theme: lightTheme,
        home: Scaffold(body: card),
      ),
    ),
  );

  testWidgets('an order no driver accepted offers retry dispatch', (
    WidgetTester tester,
  ) async {
    int retries = 0;
    await pump(
      tester,
      CollapsedActiveOrderCard(
        order: anOrder(4, status: OrderStatus.assignmentFailed),
        onRetryDispatch: () => retries++,
      ),
    );

    await tester.tap(find.text(Strings.retryDispatch));

    expect(find.text(Strings.noDriverAccepted), findsOneWidget);
    expect(retries, 1);
  });

  testWidgets('an order still being dispatched has no retry button', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      CollapsedActiveOrderCard(
        order: anOrder(4, status: OrderStatus.dispatching),
        onRetryDispatch: () {},
      ),
    );

    expect(find.text(Strings.retryDispatch), findsNothing);
  });
}
