import 'package:flutter/material.dart';

import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../widgets/history_filter_tabs.dart';
import '../widgets/order_history_card.dart';
import '../widgets/order_history_header.dart';

/// Order history tab body — composed from small widgets under
/// `presentation/widgets/`. Rendered inside [MainScaffold]; the bottom nav
/// bar and RTL directionality are provided by the parent scaffold.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> filters = <String>[
      Strings.allOrders,
      Strings.completed,
      Strings.cancelled,
    ];

    final List<OrderHistoryEntry> orders = <OrderHistoryEntry>[
      OrderHistoryEntry(
        orderId: 'SSM-1045#',
        statusLabel: Strings.delivered,
        isCancelled: false,
        meta: '${Strings.today} - 12:18 · خالد أحمد',
        price: '64 ${Strings.currencySar}',
        itemsLabel: '4 ${Strings.itemsPlural}',
      ),
      OrderHistoryEntry(
        orderId: 'SSM-1039#',
        statusLabel: Strings.delivered,
        isCancelled: false,
        meta: '${Strings.yesterday} - 19:42 · ريم العتيبي',
        price: '38 ${Strings.currencySar}',
        itemsLabel: '2 ${Strings.itemsPlural}',
      ),
      OrderHistoryEntry(
        orderId: 'SSM-1038#',
        statusLabel: Strings.cancelledStatus,
        isCancelled: true,
        meta: '${Strings.yesterday} - 18:15 · عبدالعزيز محمد',
        price: '71 ${Strings.currencySar}',
        itemsLabel: '3 ${Strings.itemsPlural}',
      ),
      OrderHistoryEntry(
        orderId: 'SSM-1027#',
        statusLabel: Strings.delivered,
        isCancelled: false,
        meta: 'الأحد - 14:20 · سارة أحمد',
        price: '28 ${Strings.currencySar}',
        itemsLabel: '1 ${Strings.itemSingular}',
      ),
    ];

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OrderHistoryHeader(
              title: Strings.orderHistory,
              exportLabel: Strings.export,
              onExportTap: () =>
                  showBrandSnackBar(context, 'سيتم تصدير سجل الطلبات قريباً'),
            ),
            const SizedBox(height: 16),
            AppSearchField(
              controller: _searchController,
              hintText: Strings.searchOrderNumber,
            ),
            const SizedBox(height: 16),
            HistoryFilterTabs(
              labels: filters,
              selectedIndex: _selectedFilter,
              onChanged: (int index) => setState(() => _selectedFilter = index),
            ),
            const SizedBox(height: 16),
            for (final OrderHistoryEntry entry in orders) ...<Widget>[
              OrderHistoryCard(
                entry: entry,
                onTap: () => showBrandSnackBar(
                  context,
                  'تفاصيل الطلب ${entry.orderId} ستتوفر قريباً',
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
