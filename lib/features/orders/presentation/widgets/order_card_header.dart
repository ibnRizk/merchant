import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Title/subtitle at the start, a price or status at the end. The text
/// column takes the remaining width and ellipsizes, so neither side can
/// overflow whatever the language of the content.
class OrderCardHeader extends StatelessWidget {
  const OrderCardHeader({
    super.key,
    required this.title,
    this.subtitle = '',
    this.trailing,
    this.trailingWidget,
  });

  final String title;
  final String subtitle;

  /// Plain trailing text (e.g. the price)…
  final String? trailing;

  /// …or a trailing widget (e.g. a status pill).
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final TextDirection textDirection = Directionality.of(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  textDirection: textDirection,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textDirection: textDirection,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                trailing!,
                textDirection: textDirection,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ),
          ],
          if (trailingWidget != null) ...<Widget>[
            const SizedBox(width: 12),
            Flexible(
              child: Directionality(
                textDirection: textDirection,
                child: trailingWidget!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
