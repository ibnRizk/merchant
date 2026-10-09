import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/app_notification.dart';

extension NotificationKindDisplay on NotificationKind {
  IconData get icon => switch (this) {
    NotificationKind.newOrder => Icons.shopping_bag_rounded,
    NotificationKind.orderUpdate => Icons.receipt_long_rounded,
    NotificationKind.delivery => Icons.delivery_dining_rounded,
    NotificationKind.wallet => Icons.account_balance_wallet_rounded,
    NotificationKind.general => Icons.notifications_rounded,
  };

  /// Used as the title when the server sent none.
  String get label => switch (this) {
    NotificationKind.newOrder => Strings.notificationKindNewOrder,
    NotificationKind.orderUpdate => Strings.notificationKindOrderUpdate,
    NotificationKind.delivery => Strings.notificationKindDelivery,
    NotificationKind.wallet => Strings.notificationKindWallet,
    NotificationKind.general => Strings.notificationKindGeneral,
  };

  /// Icon tile colors: (background, foreground).
  (Color, Color) tileColors(AppColors colors) => switch (this) {
    NotificationKind.newOrder => (colors.primaryLight, colors.primary),
    NotificationKind.orderUpdate => (
      colors.info.withValues(alpha: 0.12),
      colors.info,
    ),
    NotificationKind.delivery => (colors.successContainer, colors.success),
    NotificationKind.wallet => (
      colors.warning.withValues(alpha: 0.14),
      colors.warning,
    ),
    NotificationKind.general => (colors.border, colors.textSecondary),
  };
}

/// The day groups of the inbox, newest first.
enum NotificationSection {
  today,
  yesterday,
  earlier;

  String get label => switch (this) {
    NotificationSection.today => Strings.today,
    NotificationSection.yesterday => Strings.yesterday,
    NotificationSection.earlier => Strings.notificationsEarlier,
  };

  /// An unknown date counts as [earlier].
  static NotificationSection of(DateTime? time, DateTime now) {
    if (time == null) return NotificationSection.earlier;
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(time.year, time.month, time.day);
    final int daysAgo = today.difference(day).inDays;
    if (daysAgo <= 0) return NotificationSection.today;
    if (daysAgo == 1) return NotificationSection.yesterday;
    return NotificationSection.earlier;
  }
}

/// `14:20` today and yesterday (the section names the day), otherwise
/// `12 Mar, 14:20`.
String formatNotificationTime(
  DateTime time,
  NotificationSection section,
  String locale,
) {
  final String clock = DateFormat.Hm(locale).format(time);
  return section == NotificationSection.earlier
      ? '${DateFormat.MMMd(locale).format(time)}, $clock'
      : clock;
}
