import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/price_format.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/merchant_order.dart';
import '../../domain/entities/order_line.dart';
import '../../domain/entities/order_status.dart';

/// Display text for orders. Every dynamic fragment is bidi-isolated so
/// English names inside Arabic layouts (and the reverse) never reorder.
extension OrderStatusDisplay on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pendingMerchant => Strings.newStatus,
    OrderStatus.accepted => Strings.statusAccepted,
    OrderStatus.preparing => Strings.statusPreparing,
    OrderStatus.readyForPickup =>
      Strings.statusReadyForPickup,
    OrderStatus.dispatching => Strings.statusDispatching,
    OrderStatus.driverAssigned ||
    OrderStatus.driverAccepted =>
      Strings.statusDriverAssigned,
    OrderStatus.pickedUp => Strings.statusPickedUp,
    OrderStatus.outForDelivery =>
      Strings.statusOutForDelivery,
    OrderStatus.delivered => Strings.delivered,
    OrderStatus.rejected => Strings.statusRejected,
    OrderStatus.cancelled ||
    OrderStatus.failed => Strings.cancelledStatus,
    OrderStatus.assignmentFailed =>
      Strings.statusAssignmentFailed,
    OrderStatus.refunded => Strings.statusRefunded,
    OrderStatus.unknown => Strings.statusUnknown,
  };

  /// Pill colors: (background, text).
  (Color, Color) pillColors(AppColors colors) {
    if (isCompleted)
      return (colors.successContainer, colors.success);
    // A failed dispatch still needs the merchant, so it keeps the alarm color.
    if (isCancelled || this == OrderStatus.assignmentFailed)
      return (colors.errorContainer, colors.error);
    if (isNew) return (colors.primaryLight, colors.primary);
    if (isActive)
      return (
        colors.info.withValues(alpha: 0.12),
        colors.info,
      );
    return (colors.border, colors.textSecondary);
  }
}

extension OrderActionDisplay on OrderAction {
  /// Label of the single forward button (see [OrderStatus.nextAction]).
  String get label => switch (this) {
    OrderAction.accept => Strings.acceptOrder,
    OrderAction.reject => Strings.rejectOrder,
    OrderAction.startPreparing => Strings.startPreparing,
    OrderAction.readyForPickup => Strings.statusReadyForPickup,
    OrderAction.retryDispatch => Strings.retryDispatch,
  };
}

extension OrderDisplay on MerchantOrder {
  /// `#1048`, kept left-to-right so `#` never jumps to the end in RTL.
  String get number => '#$id'.ltrIsolated;

  String amountLabel(String currency) => formatOrderAmount(amount, currency);

  String get itemsLabel =>
      '$itemsCount ${itemsCount == 1 ? Strings.itemSingular : Strings.itemsPlural}';

  String get customerLabel => customerName.bidiIsolated;

  String get paymentLabel => switch (paymentMethod) {
    '' => '',
    'cash_on_delivery' => Strings.paymentCash,
    _ => Strings.paymentOnline,
  };

  /// `Today - 12:18 · Khalid`, skipping the parts that are missing.
  String metaLine(String locale, {DateTime? now}) =>
      <String>[
        if (createdAt != null)
          formatOrderTime(createdAt!, locale, now: now),
        if (customerName.isNotEmpty) customerLabel,
      ].join(' · ');
}

extension OrderLineDisplay on OrderLine {
  /// `Burger × 2`; the name keeps its own direction.
  String get titleLabel =>
      '${name.bidiIsolated} × ${'$quantity'.ltrIsolated}';

  String get extrasLabel =>
      extras.map((String e) => e.bidiIsolated).join(' · ');

  String totalLabel(String currency) => formatOrderAmount(total, currency);
}

/// `28.50 EGP`, with the number kept left-to-right inside Arabic text.
String formatOrderAmount(double amount, String currency) {
  final String price = formatPrice(amount).ltrIsolated;
  return currency.isEmpty ? price : '$price $currency';
}

/// `Today - 12:18`, `Yesterday - 19:42`, or `12 Sep - 14:20`.
String formatOrderTime(
  DateTime time,
  String locale, {
  DateTime? now,
}) {
  final DateTime today = DateUtils.dateOnly(
    now ?? DateTime.now(),
  );
  final DateTime day = DateUtils.dateOnly(time);
  final String dayLabel = switch (today
      .difference(day)
      .inDays) {
    0 => Strings.today,
    1 => Strings.yesterday,
    _ => DateFormat.MMMd(locale).format(time),
  };
  return '$dayLabel - ${DateFormat.Hm(locale).format(time).ltrIsolated}';
}
