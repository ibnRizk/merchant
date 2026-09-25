import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/widgets/status_pill.dart';

/// Screen title with a count badge at the end (e.g. "5 بانتظار",
/// "2 طلبات"). Pass [leading] (e.g. a back button) for standalone-pushed
/// screens; it renders right next to the title. The title shrinks with an
/// ellipsis instead of overflowing when the badge needs the room.
class OrdersScreenHeader extends StatelessWidget {
  const OrdersScreenHeader({
    super.key,
    required this.title,
    this.badgeText,
    this.leading,
  });

  final String title;
  final String? badgeText;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (leading != null) ...<Widget>[leading!, const SizedBox(width: 10)],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
        ),
        if (badgeText != null) ...<Widget>[
          const SizedBox(width: 8),
          StatusPill(label: badgeText!),
        ],
      ],
    );
  }
}
