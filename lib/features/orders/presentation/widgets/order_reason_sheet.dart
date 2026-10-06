import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/show_modal_bottom_sheet.dart';
import '../../domain/params/order_command.dart';

typedef RejectDecision = ({RejectReason reason, String note});
typedef CancelDecision = ({CancelReason reason, String note});

/// Asks for a rejection reason (required by the API) and an optional note.
/// Resolves to `null` when dismissed.
Future<RejectDecision?> showRejectOrderSheet(BuildContext context) async {
  return _showReasonSheet<RejectReason>(
    context,
    title: Strings.rejectOrderTitle,
    reasonLabel: Strings.rejectReasonLabel,
    confirmLabel: Strings.rejectOrder,
    reasons: RejectReason.values,
    label: (RejectReason reason) => switch (reason) {
      RejectReason.itemUnavailable => Strings.rejectReasonItemUnavailable,
      RejectReason.storeBusy => Strings.rejectReasonStoreBusy,
      RejectReason.storeClosing => Strings.rejectReasonStoreClosing,
      RejectReason.other => Strings.rejectReasonOther,
    },
  );
}

/// Asks why an accepted order is being cancelled (required by the API) and
/// for an optional note. Resolves to `null` when dismissed.
Future<CancelDecision?> showCancelOrderSheet(BuildContext context) async {
  return _showReasonSheet<CancelReason>(
    context,
    title: Strings.cancelOrderTitle,
    reasonLabel: Strings.cancelReasonLabel,
    confirmLabel: Strings.cancelOrder,
    reasons: CancelReason.values,
    label: (CancelReason reason) => switch (reason) {
      CancelReason.itemUnavailable => Strings.rejectReasonItemUnavailable,
      CancelReason.storeClosing => Strings.rejectReasonStoreClosing,
      CancelReason.customerRequest => Strings.cancelReasonCustomerRequest,
      CancelReason.other => Strings.rejectReasonOther,
    },
  );
}

Future<({R reason, String note})?> _showReasonSheet<R>(
  BuildContext context, {
  required String title,
  required String reasonLabel,
  required String confirmLabel,
  required List<R> reasons,
  required String Function(R reason) label,
}) async {
  ({R reason, String note})? decision;
  await showAppModalBottomSheet(
    context: context,
    child: _OrderReasonSheet<R>(
      title: title,
      reasonLabel: reasonLabel,
      confirmLabel: confirmLabel,
      reasons: reasons,
      label: label,
      onConfirm: (R reason, String note) =>
          decision = (reason: reason, note: note),
    ),
  );
  return decision;
}

/// A destructive decision on an order that needs a reason: pick one, add an
/// optional note, confirm.
class _OrderReasonSheet<R> extends StatefulWidget {
  const _OrderReasonSheet({
    required this.title,
    required this.reasonLabel,
    required this.confirmLabel,
    required this.reasons,
    required this.label,
    required this.onConfirm,
  });

  final String title;
  final String reasonLabel;
  final String confirmLabel;
  final List<R> reasons;
  final String Function(R reason) label;
  final void Function(R reason, String note) onConfirm;

  @override
  State<_OrderReasonSheet<R>> createState() => _OrderReasonSheetState<R>();
}

class _OrderReasonSheetState<R> extends State<_OrderReasonSheet<R>> {
  final TextEditingController _noteController = TextEditingController();
  R? _reason;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _confirm() {
    final R? reason = _reason;
    if (reason == null) return;
    widget.onConfirm(reason, _noteController.text.trim());
    Navigator.of(context).pop();
  }

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
              widget.title,
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
              widget.reasonLabel,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            for (final R reason in widget.reasons)
              _ReasonTile(
                label: widget.label(reason),
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
                  widget.confirmLabel,
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
