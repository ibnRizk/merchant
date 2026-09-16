import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';

/// Accept/reject row for a new order: the larger orange "accept" action
/// sits on the right (primary), the smaller outlined "reject" on the left.
class OrderActionButtons extends StatelessWidget {
  const OrderActionButtons({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final ColorScheme scheme = Theme.of(
      context,
    ).colorScheme;
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: scheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                Strings.acceptAndStart,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: onReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textSecondary,
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                Strings.rejectOrder,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
