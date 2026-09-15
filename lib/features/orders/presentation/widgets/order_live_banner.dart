import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// Green two-line banner explaining that new orders arrive automatically
/// from the customer app.
class OrderLiveBanner extends StatelessWidget {
  const OrderLiveBanner({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: BrandColors.statusBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: BrandColors.statusText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: BrandColors.statusText.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
