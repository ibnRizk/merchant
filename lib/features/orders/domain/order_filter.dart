import 'entities/merchant_order.dart';

/// The order-history tabs.
enum OrderFilter { all, completed, cancelled }

/// Merges current and past orders into one list, newest first. An order in
/// both lists (it finished between the two requests) is kept once, with the
/// history copy winning because it is the final state.
List<MerchantOrder> mergeOrders(
  List<MerchantOrder> current,
  List<MerchantOrder> history,
) {
  final Map<int, MerchantOrder> byId = <int, MerchantOrder>{
    for (final MerchantOrder order in current) order.id: order,
    for (final MerchantOrder order in history) order.id: order,
  };
  final List<MerchantOrder> merged = byId.values.toList()..sort(_newestFirst);
  return merged;
}

/// Orders on the [filter] tab whose id matches [query].
List<MerchantOrder> filterOrders(
  List<MerchantOrder> orders, {
  required OrderFilter filter,
  String query = '',
}) {
  final String digits = orderQueryDigits(query);
  return <MerchantOrder>[
    for (final MerchantOrder order in orders)
      if (_inFilter(order, filter) &&
          (digits.isEmpty || '${order.id}'.contains(digits)))
        order,
  ];
}

/// The digits of a search query, so `#1048`, `SSM-1048` and Arabic-Indic
/// `١٠٤٨` all find order 1048.
String orderQueryDigits(String query) {
  const String arabicDigits = '٠١٢٣٤٥٦٧٨٩';
  final StringBuffer digits = StringBuffer();
  for (final int rune in query.runes) {
    final String char = String.fromCharCode(rune);
    final int arabicIndex = arabicDigits.indexOf(char);
    if (arabicIndex >= 0) {
      digits.write(arabicIndex);
    } else if (rune >= 0x30 && rune <= 0x39) {
      digits.write(char);
    }
  }
  return digits.toString();
}

bool _inFilter(MerchantOrder order, OrderFilter filter) => switch (filter) {
  OrderFilter.all => true,
  OrderFilter.completed => order.status.isCompleted,
  OrderFilter.cancelled => order.status.isCancelled,
};

int _newestFirst(MerchantOrder a, MerchantOrder b) {
  final DateTime? aTime = a.createdAt;
  final DateTime? bTime = b.createdAt;
  if (aTime != null && bTime != null) {
    final int byTime = bTime.compareTo(aTime);
    if (byTime != 0) return byTime;
  }
  return b.id.compareTo(a.id);
}
