import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/show_modal_bottom_sheet.dart';
import '../../domain/params/order_command.dart';

typedef RejectDecision = ({RejectReason reason, String note});

/// Asks for a rejection reason (required by the API) and an optional note.
/// Resolves to `null` when dismissed.
Future<RejectDecision?> showRejectOrderSheet(BuildContext context) async {
  RejectDecision? decision;
  await showAppModalBottomSheet(
    context: context,
    child: _RejectOrderSheet(onConfirm: (RejectDecision d) => decision = d),
  );
  return decision;
}

class _RejectOrderSheet extends StatefulWidget {
  const _RejectOrderSheet({required this.onConfirm});

  final ValueChanged<RejectDecision> onConfirm;

  @override
  State<_RejectOrderSheet> createState() => _RejectOrderSheetState();
}

class _RejectOrderSheetState extends State<_RejectOrderSheet> {
  final TextEditingController _noteController = TextEditingController();
  RejectReason? _reason;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _confirm() {
    final RejectReason? reason = _reason;
    if (reason == null) return;
    widget.onConfirm((reason: reason, note: _noteController.text.trim()));
    Navigator.of(context).pop();
  }

  static String _label(RejectReason reason) => switch (reason) {
    RejectReason.itemUnavailable => Strings.rejectReasonItemUnavailable,
    RejectReason.storeBusy => Strings.rejectReasonStoreBusy,
    RejectReason.storeClosing => Strings.rejectReasonStoreClosing,
    RejectReason.other => Strings.rejectReasonOther,
  };

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              Strings.rejectOrderTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              Strings.rejectReasonLabel,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            for (final RejectReason reason in RejectReason.values)
              _ReasonTile(
                label: _label(reason),
                isSelected: reason == _reason,
                onTap: () => setState(() => _reason = reason),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              minLines: 2,
              maxLength: 255,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.5,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: Strings.rejectNoteHint,
                hintStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.5,
                  color: colors.textSecondary,
                ),
                filled: true,
                fillColor: colors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _reason == null ? null : _confirm,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  Strings.rejectOrder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: <Widget>[
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20,
              color: isSelected ? colors.error : colors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
