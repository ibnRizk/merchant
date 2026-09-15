import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// "سجل الطلبات" title with a "تصدير" export link on the left.
class OrderHistoryHeader extends StatelessWidget {
  const OrderHistoryHeader({
    super.key,
    required this.title,
    required this.exportLabel,
    required this.onExportTap,
  });

  final String title;
  final String exportLabel;
  final VoidCallback onExportTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: BrandColors.navy,
          ),
        ),
        TextButton(
          onPressed: onExportTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            exportLabel,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: BrandColors.orange,
            ),
          ),
        ),
      ],
    );
  }
}
