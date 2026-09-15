import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// Navy info banner explaining what happens after the merchant marks an
/// order ready — the quoted phrase is highlighted in brand orange.
class ReadyForPickupBanner extends StatelessWidget {
  const ReadyForPickupBanner({
    super.key,
    required this.prefix,
    required this.highlighted,
    required this.subtitle,
  });

  final String prefix;
  final String highlighted;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: BrandColors.navy,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              children: <InlineSpan>[
                TextSpan(text: prefix),
                TextSpan(
                  text: highlighted,
                  style: const TextStyle(color: BrandColors.orange),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
