import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';

/// Accept/reject row for a new order: the larger "accept" action first
/// (primary), the smaller outlined "reject" after it. Labels scale down to
/// fit on one line instead of wrapping out of the fixed-height buttons.
class OrderActionButtons extends StatelessWidget {
  const OrderActionButtons({
    super.key,
    required this.onAccept,
    required this.onReject,
    this.isBusy = false,
  });

  final VoidCallback onAccept;
  final VoidCallback onReject;

  /// A command is in flight: both buttons are disabled.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: isBusy ? null : onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: scheme.onPrimary,
                disabledBackgroundColor: colors.primary.withValues(alpha: 0.6),
                disabledForegroundColor: scheme.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isBusy
                  ? SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: scheme.onPrimary,
                      ),
                    )
                  : _ButtonLabel(Strings.acceptOrder),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: isBusy ? null : onReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textSecondary,
                side: BorderSide(color: colors.border),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _ButtonLabel(Strings.rejectOrder),
            ),
          ),
        ),
      ],
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        maxLines: 1,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
