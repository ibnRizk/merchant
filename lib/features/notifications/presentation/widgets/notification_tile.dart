import 'package:flutter/material.dart';

import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/app_notification.dart';
import '../utils/notification_display.dart';

/// One inbox entry. Unread entries are tinted, carry an accent bar on the
/// start edge and a dot, and use a bolder title; read ones sit back.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.section,
    required this.onTap,
  });

  final AppNotification notification;
  final NotificationSection section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final bool unread = !notification.isRead;
    final (Color tileBackground, Color tileForeground) = notification.kind
        .tileColors(colors);
    final String title = notification.title.isNotEmpty
        ? notification.title
        : notification.kind.label;
    final DateTime? createdAt = notification.createdAt;
    final BorderRadius radius = BorderRadius.circular(16);

    return Semantics(
      button: true,
      // Lets screen readers tell read from unread without the colors.
      label: unread ? '• $title' : title,
      excludeSemantics: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: unread
              ? Color.alphaBlend(
                  colors.primary.withValues(alpha: 0.05),
                  colors.surface,
                )
              : colors.surface,
          borderRadius: radius,
          border: Border.all(
            color: unread
                ? colors.primary.withValues(alpha: 0.18)
                : colors.border,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: ClipRRect(
              borderRadius: radius,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 4,
                      color: unread ? colors.primary : Colors.transparent,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          10,
                          14,
                          14,
                          14,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _KindIcon(
                              icon: notification.kind.icon,
                              background: tileBackground,
                              foreground: tileForeground,
                              dimmed: !unread,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _Content(
                                title: title,
                                body: notification.body,
                                time: createdAt == null
                                    ? null
                                    : formatNotificationTime(
                                        createdAt,
                                        section,
                                        Localizations.localeOf(
                                          context,
                                        ).languageCode,
                                      ),
                                showsOrderLink: notification.orderId != null,
                                unread: unread,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KindIcon extends StatelessWidget {
  const _KindIcon({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.dimmed,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: dimmed ? 0.6 : 1,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 22, color: foreground),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.title,
    required this.body,
    required this.time,
    required this.showsOrderLink,
    required this.unread,
  });

  final String title;
  final String body;
  final String? time;
  final bool showsOrderLink;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                title.bidiIsolated,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.5,
                  height: 1.35,
                  fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                  color: unread ? colors.textPrimary : colors.textSecondary,
                ),
              ),
            ),
            if (time != null) ...<Widget>[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  time!.ltrIsolated,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    fontWeight: unread ? FontWeight.w700 : FontWeight.w400,
                    color: unread ? colors.primary : colors.textSecondary,
                  ),
                ),
              ),
            ],
            if (unread) ...<Widget>[
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (body.isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            body.bidiIsolated,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              height: 1.45,
              color: unread
                  ? colors.textPrimary.withValues(alpha: 0.85)
                  : colors.textSecondary,
            ),
          ),
        ],
        if (showsOrderLink) ...<Widget>[
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                Strings.notificationViewOrder,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 18,
                color: colors.primary,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
