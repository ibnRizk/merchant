import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Green two-line banner explaining that new orders arrive automatically
/// from the customer app.
class OrderLiveBanner extends StatelessWidget {
  const OrderLiveBanner({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.successContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: colors.success,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: colors.success.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
