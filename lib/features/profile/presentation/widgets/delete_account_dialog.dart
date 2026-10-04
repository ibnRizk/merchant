import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';

/// Strict confirmation for deleting the account: the merchant must type
/// [Strings.deleteConfirmWord] before the button enables. Resolves to the
/// optional reason (possibly empty) when confirmed, or `null` when
/// dismissed.
Future<String?> showDeleteAccountDialog(BuildContext context) =>
    showDialog<String>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(_onConfirmChanged);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onConfirmChanged() {
    final bool matches =
        _confirmController.text.trim().toUpperCase() ==
        Strings.deleteConfirmWord.toUpperCase();
    if (matches != _confirmed) setState(() => _confirmed = matches);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final TextStyle bodyStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 13.5,
      color: colors.textSecondary,
    );
    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      icon: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: colors.errorContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.delete_forever_rounded, color: colors.error),
      ),
      title: Text(
        Strings.deleteAccountTitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: colors.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              Strings.deleteAccountMessage,
              textAlign: TextAlign.center,
              style: bodyStyle,
            ),
            const SizedBox(height: 16),
            _DialogField(
              controller: _reasonController,
              hintText: Strings.deleteAccountReasonHint,
              maxLines: 2,
              maxLength: 255,
            ),
            const SizedBox(height: 12),
            Text(
              '${Strings.typeToConfirm} «${Strings.deleteConfirmWord}»',
              textAlign: TextAlign.start,
              style: bodyStyle.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _DialogField(
              controller: _confirmController,
              hintText: Strings.deleteConfirmWord,
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            Strings.cancel,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
            ),
          ),
        ),
        FilledButton(
          onPressed: _confirmed
              ? () => Navigator.of(context).pop(_reasonController.text.trim())
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            disabledBackgroundColor: colors.error.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            Strings.deleteAccount,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.border),
    );
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13.5,
        color: colors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.5,
          color: colors.textSecondary,
        ),
        isDense: true,
        filled: true,
        fillColor: colors.background,
        border: border,
        enabledBorder: border,
      ),
    );
  }
}
