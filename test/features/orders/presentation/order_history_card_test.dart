import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ssm_merchant/config/themes/app_theme.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/app_config/domain/entities/app_config.dart';
import 'package:ssm_merchant/features/app_config/domain/repos/app_config_repository.dart';
import 'package:ssm_merchant/features/app_config/presentation/cubit/app_config_cubit.dart';
import 'package:ssm_merchant/features/orders/domain/entities/merchant_order.dart';
import 'package:ssm_merchant/features/orders/domain/entities/order_status.dart';
import 'package:ssm_merchant/features/orders/presentation/utils/order_display.dart';
import 'package:ssm_merchant/features/orders/presentation/widgets/order_history_card.dart';

class _FakeConfigRepo implements AppConfigRepository {
  @override
  AppConfig cachedConfig() => AppConfig.empty;

  @override
  Future<Either<Failure, AppConfig>> fetchConfig() async =>
      const Right(AppConfig.empty);
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ar');
  });

  Future<void> pumpCard(WidgetTester tester, Widget card) => tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => BlocProvider<AppConfigCubit>(
            create: (_) => AppConfigCubit(repository: _FakeConfigRepo()),
            child: MaterialApp(
              theme: lightTheme,
              locale: const Locale('ar'),
              home: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: card,
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets('OrderHistoryCard renders order number, status, customer and amount at edges',
      (WidgetTester tester) async {
    final order = MerchantOrder(
      id: 100071,
      status: OrderStatus.delivered,
      amount: 194,
      itemsCount: 0,
      customerName: 'حسين',
      createdAt: DateTime(2026, 10, 9, 16, 22),
    );

    await pumpCard(tester, OrderHistoryCard(order: order));

    expect(find.textContaining('100071'), findsOneWidget);
    expect(find.text(OrderStatus.delivered.label), findsOneWidget);
    expect(find.textContaining('حسين'), findsOneWidget);
    expect(find.textContaining('194'), findsOneWidget);

    // Verify positions: left element should be to the left of the right element
    final numberTopLeft = tester.getTopLeft(find.textContaining('100071'));
    final statusTopRight = tester.getTopRight(find.text(OrderStatus.delivered.label));
    expect(numberTopLeft.dx, lessThan(statusTopRight.dx));

    final itemsTopLeft = tester.getTopLeft(find.text(order.itemsLabel));
    final amountTopRight = tester.getTopRight(find.textContaining('194'));
    expect(itemsTopLeft.dx, lessThan(amountTopRight.dx));
  });

  testWidgets('OrderHistoryCard renders without error when customer or date is missing',
      (WidgetTester tester) async {
    const orderNoDateNoCustomer = MerchantOrder(
      id: 100072,
      status: OrderStatus.cancelled,
      amount: 50,
      itemsCount: 2,
    );

    await pumpCard(tester, const OrderHistoryCard(order: orderNoDateNoCustomer));

    expect(find.textContaining('100072'), findsOneWidget);
    expect(find.text(OrderStatus.cancelled.label), findsOneWidget);
  });
}
