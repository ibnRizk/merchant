import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';

/// Full-width red outlined "Cancel order" action, shown under the next step
/// of an accepted or preparing order (list card and Order Details).
class CancelOrderButton extends StatelessWidget {
  const CancelOrderButton({
    super.key,
    required this.onPressed,
    this.isBusy = false,
  });

  final VoidCallback onPressed;

  /// A command is in flight: the button is disabled.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final Color red = context.colors.error;
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: isBusy ? null : onPressed,
        icon: const Icon(Icons.cancel_outlined, size: 20),
        label: Text(
          Strings.cancelOrder,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: red,
          disabledForegroundColor: red.withValues(alpha: 0.5),
          backgroundColor: red.withValues(alpha: 0.06),
          side: BorderSide(color: red, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
