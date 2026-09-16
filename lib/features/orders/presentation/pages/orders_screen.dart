import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/action_card.dart';
import '../../../../core/widgets/brand_back_button.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../widgets/new_order_detail_card.dart';
import '../widgets/order_live_banner.dart';
import '../widgets/orders_screen_header.dart';

/// New-orders screen, reached by pushing `AppRoutes.newOrdersName` (e.g.
/// from the home dashboard's "فتح الطلبات" action). Self-contained: owns
/// its own [Scaffold] and RTL [Directionality] since it's no longer hosted
/// inside [MainScaffold]'s tab bar.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              OrdersScreenHeader(
                title: Strings.newOrdersTitle,
                badgeText: '5 ${Strings.waiting}',
                leading: const BrandBackButton(),
              ),
              const SizedBox(height: 16),
              OrderLiveBanner(
                title: Strings.directFromCustomer,
                subtitle: Strings.managementMonitors,
              ),
              const SizedBox(height: 16),
              NewOrderDetailCard(
                orderId: 'SSM-1048#',
                meta: 'منذ 3 دقائق - توصيل حي السلام',
                price: '71 ${Strings.currencySar}',
                items: const <OrderLineItem>[
                  OrderLineItem(name: 'برجر SSM × 1', price: '56 ر.س'),
                  OrderLineItem(name: 'بطاطس مقرمشة × 1', price: '8 ر.س'),
                ],
                noteLabel: Strings.customerNote,
                noteText: 'بدون بصل، وتغليف منفصل للبطاطس.',
                onAccept: () {
                  showBrandSnackBar(context, 'تم قبول الطلب SSM-1048#');
                  context.pushNamed(AppRoutes.activeOrdersName);
                },
                onReject: () {
                  showBrandSnackBar(
                    context,
                    'تم رفض الطلب SSM-1048#',
                    isError: true,
                  );
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.home);
                  }
                },
              ),
              const SizedBox(height: 16),
              ActionCard(
                title: 'SSM-1047#',
                subtitle: 'كافيه سحابة - 38 ر.س',
                actionLabel: Strings.view,
                onTap: () => showBrandSnackBar(
                  context,
                  'تفاصيل الطلب SSM-1047# ستتوفر قريباً',
                ),
              ),
              const SizedBox(height: 12),
              ActionCard(
                title: 'SSM-1046#',
                subtitle: 'سوبرماركت الواحة - 112 ر.س',
                actionLabel: Strings.view,
                onTap: () => showBrandSnackBar(
                  context,
                  'تفاصيل الطلب SSM-1046# ستتوفر قريباً',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
