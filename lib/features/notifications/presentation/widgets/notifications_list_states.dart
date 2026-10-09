import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_shimmer.dart';

/// "Today", "Yesterday", "Earlier" above each day group.
class NotificationsSectionHeader extends StatelessWidget {
  const NotificationsSectionHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, top: 8, bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

/// Shown when the inbox has nothing in it.
class NotificationsEmptyView extends StatelessWidget {
  const NotificationsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: Column(
        children: <Widget>[
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            Strings.noNotifications,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Strings.noNotificationsHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.5,
              height: 1.5,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder tiles while the first page loads, shaped like the real ones
/// so nothing jumps when they arrive.
class NotificationsLoadingView extends StatelessWidget {
  const NotificationsLoadingView({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    Widget bar(double widthFactor, double height) => FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );

    return AppShimmer(
      child: Column(
        children: <Widget>[
          for (int i = 0; i < count; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        bar(0.55, 14),
                        const SizedBox(height: 8),
                        bar(0.9, 11),
                        const SizedBox(height: 6),
                        bar(0.7, 11),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
