import 'package:flutter/material.dart';

import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/order_status.dart';
import '../cubit/order_notice.dart';

/// Announces an order command's outcome. Shared by every orders screen.
void showOrderNotice(BuildContext context, OrderNotice? notice) {
  switch (notice) {
    case OrderUpdatedNotice(:final status):
      showBrandSnackBar(context, switch (status) {
        OrderStatus.accepted => Strings.orderAccepted,
        OrderStatus.rejected => Strings.orderRejected,
        _ => Strings.orderUpdated,
      });
    case OrderConflictNotice():
      showBrandSnackBar(
        context,
        Strings.orderConflict,
        isError: true,
        duration: const Duration(seconds: 4),
      );
    case OrderDispatchRetriedNotice():
      showBrandSnackBar(context, Strings.dispatchRetried);
    case OrderActionFailedNotice(:final message):
      showBrandSnackBar(context, message, isError: true);
    case null:
      break;
  }
}

/// `listenWhen` helper: true when [current] carries a notice [previous]
/// didn't.
bool isNewNotice(OrderNotice? previous, OrderNotice? current) =>
    current != null && !identical(previous, current);
