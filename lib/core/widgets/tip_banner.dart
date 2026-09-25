import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';

/// Peach note/tip banner with a bold leading label (e.g. "ملاحظة العميل:",
/// "نصيحة:") followed by regular-weight body text.
class TipBanner extends StatelessWidget {
  const TipBanner({super.key, required this.boldPrefix, required this.text});

  final String boldPrefix;
  final String text;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        // `start` follows the layout direction; `right` misaligned English.
        textAlign: TextAlign.start,
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: colors.warning,
          ),
          children: <InlineSpan>[
            TextSpan(
              text: boldPrefix,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
