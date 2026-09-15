import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/brand_colors.dart';
import '../../../../core/widgets/brand_back_button.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../widgets/active_order_detail_card.dart';
import '../widgets/collapsed_active_order_card.dart';
import '../widgets/new_order_detail_card.dart' show OrderLineItem;
import '../widgets/order_progress_stepper.dart';
import '../widgets/orders_screen_header.dart';

/// Active-orders screen, reached by pushing `AppRoutes.activeOrdersName`
/// (e.g. from the home dashboard's "عرض" action). Self-contained: owns its
/// own [Scaffold] and RTL [Directionality] since it's no longer hosted
/// inside [MainScaffold]'s tab bar.
class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const OrdersScreenHeader(
                  title: 'الطلبات النشطة',
                  badgeText: '2 طلبات',
                  leading: BrandBackButton(),
                ),
                const SizedBox(height: 16),
                ActiveOrderDetailCard(
                  orderId: 'SSM-1048#',
                  customerName: 'عبدالعزيز محمد',
                  statusLabel: 'قيد التجهيز',
                  steps: const <ProgressStep>[
                    ProgressStep(label: 'مقبول', color: BrandColors.orange),
                    ProgressStep(label: 'قيد التجهيز', color: BrandColors.navy),
                    ProgressStep(
                      label: 'جاهز للاستلام',
                      color: Color(0xFFD8DCE2),
                    ),
                  ],
                  items: const <OrderLineItem>[
                    OrderLineItem(name: 'برجر SSM × 1', price: '56 ر.س'),
                    OrderLineItem(name: 'بطاطس مقرمشة × 1', price: '8 ر.س'),
                  ],
                  ctaLabel: 'جاهز للاستلام',
                  onCtaPressed: () {
                    showBrandSnackBar(
                      context,
                      'تم تحديث الطلب SSM-1048# إلى جاهز للاستلام',
                    );
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                  noticeText: 'سيتم إرسال النظام تلقائياً لأقرب مندوب متصل',
                ),
                const SizedBox(height: 16),
                CollapsedActiveOrderCard(
                  orderId: 'SSM-1047#',
                  statusLabel: 'قيد التحضير',
                  subtitle: 'كافيه سحابة - منوع 12:55',
                  onTap: () => showBrandSnackBar(
                    context,
                    'تفاصيل الطلب SSM-1047# ستتوفر قريباً',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
