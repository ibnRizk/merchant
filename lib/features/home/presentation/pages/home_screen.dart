import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/action_card.dart';
import '../widgets/attention_section_header.dart';
import '../widgets/home_header.dart';
import '../widgets/stats_grid.dart';
import '../widgets/store_status_bar.dart';

/// Merchant home dashboard — composed from small widgets under
/// `presentation/widgets/`. Rendered as the body of [MainScaffold]'s
/// "الرئيسية" tab.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isStoreOpen = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            HomeHeader(
              greeting: Strings.goodMorning,
              storeName: 'مطاعم مذاق',
              avatarLetter: 'م',
            ),
            const SizedBox(height: 20),
            StoreStatusBar(
              isOpen: _isStoreOpen,
              onChanged: (bool value) => setState(() => _isStoreOpen = value),
            ),
            const SizedBox(height: 20),
            const StatsGrid(
              ordersToday: '24',
              newOrders: '5',
              revenueToday: '1,280',
              preparingOrders: '7',
            ),
            const SizedBox(height: 28),
            AttentionSectionHeader(
              title: Strings.needsAttention,
              actionLabel: Strings.viewAll,
              onActionTap: () => context.pushNamed(AppRoutes.newOrdersName),
            ),
            const SizedBox(height: 12),
            ActionCard(
              title: '5 ${Strings.newOrdersTitle}',
              subtitle: Strings.waitingForAcceptance,
              actionLabel: Strings.openOrders,
              onTap: () => context.pushNamed(AppRoutes.newOrdersName),
            ),
            const SizedBox(height: 12),
            ActionCard(
              title: '7 ${Strings.processingOrdersTitle}',
              subtitle: Strings.notifyDriverWhenReady,
              actionLabel: Strings.view,
              onTap: () => context.pushNamed(AppRoutes.activeOrdersName),
            ),
          ],
        ),
      ),
    );
  }
}
