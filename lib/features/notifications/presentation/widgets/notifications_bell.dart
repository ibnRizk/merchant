import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';

/// Bell button with an unread badge; [unreadCount] 0 hides the badge.
class NotificationsBell extends StatelessWidget {
  const NotificationsBell({
    super.key,
    required this.unreadCount,
    required this.onTap,
  });

  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final bool hasUnread = unreadCount > 0;
    return Semantics(
      button: true,
      label: hasUnread
          ? '${Strings.notificationsTitle} ($unreadCount)'
          : Strings.notificationsTitle,
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: Center(
              child: Badge(
                isLabelVisible: hasUnread,
                backgroundColor: colors.error,
                textColor: Colors.white,
                offset: const Offset(6, -6),
                label: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Icon(
                  hasUnread
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  size: 24,
                  color: hasUnread ? colors.primary : colors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
