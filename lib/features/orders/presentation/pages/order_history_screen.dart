import 'package:flutter/material.dart';

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
  static const List<String> _filters = <String>[
    'كل الطلبات',
    'مكتملة',
    'ملغاة',
  ];

  static const List<OrderHistoryEntry> _orders = <OrderHistoryEntry>[
    OrderHistoryEntry(
      orderId: 'SSM-1045#',
      statusLabel: 'تم التسليم',
      isCancelled: false,
      meta: 'اليوم - 12:18 · خالد أحمد',
      price: '64 ر.س',
      itemsLabel: '4 أصناف',
    ),
    OrderHistoryEntry(
      orderId: 'SSM-1039#',
      statusLabel: 'تم التسليم',
      isCancelled: false,
      meta: 'أمس - 19:42 · ريم العتيبي',
      price: '38 ر.س',
      itemsLabel: '2 أصناف',
    ),
    OrderHistoryEntry(
      orderId: 'SSM-1038#',
      statusLabel: 'ملغي',
      isCancelled: true,
      meta: 'أمس - 18:15 · عبدالعزيز محمد',
      price: '71 ر.س',
      itemsLabel: '3 أصناف',
    ),
    OrderHistoryEntry(
      orderId: 'SSM-1027#',
      statusLabel: 'تم التسليم',
      isCancelled: false,
      meta: 'الأحد - 14:20 · سارة أحمد',
      price: '28 ر.س',
      itemsLabel: '1 صنف',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OrderHistoryHeader(
              title: 'سجل الطلبات',
              exportLabel: 'تصدير',
              onExportTap: () =>
                  showBrandSnackBar(context, 'سيتم تصدير سجل الطلبات قريباً'),
            ),
            const SizedBox(height: 16),
            AppSearchField(
              controller: _searchController,
              hintText: 'ابحث برقم الطلب',
            ),
            const SizedBox(height: 16),
            HistoryFilterTabs(
              labels: _filters,
              selectedIndex: _selectedFilter,
              onChanged: (int index) => setState(() => _selectedFilter = index),
            ),
            const SizedBox(height: 16),
            for (final OrderHistoryEntry entry in _orders) ...<Widget>[
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
