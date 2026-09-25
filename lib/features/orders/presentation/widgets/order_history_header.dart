import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// "سجل الطلبات" title with a "تصدير" export link at the end.
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
    final AppColors colors = context.colors;
    return Row(
      children: <Widget>[
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
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onExportTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            exportLabel,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
