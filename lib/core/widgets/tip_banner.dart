import 'package:flutter/material.dart';

import '../utils/values/brand_colors.dart';

/// Peach note/tip banner with a bold leading label (e.g. "ملاحظة العميل:",
/// "نصيحة:") followed by regular-weight body text.
class TipBanner extends StatelessWidget {
  const TipBanner({super.key, required this.boldPrefix, required this.text});

  final String boldPrefix;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BrandColors.peachBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        textAlign: TextAlign.right,
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: BrandColors.noteText,
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
