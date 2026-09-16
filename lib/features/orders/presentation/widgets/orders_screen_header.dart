import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/widgets/status_pill.dart';

/// Screen title with a peach count badge on the left (e.g. "5 بانتظار",
/// "2 طلبات"). Pass [leading] (e.g. a back button) for standalone-pushed
/// screens; it renders right next to the title.
class OrdersScreenHeader extends StatelessWidget {
  const OrdersScreenHeader({
    super.key,
    required this.title,
    required this.badgeText,
    this.leading,
  });

  final String title;
  final String badgeText;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (leading != null) ...<Widget>[
              leading!,
              const SizedBox(width: 10),
            ],
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        StatusPill(label: badgeText),
      ],
    );
  }
}
