import 'package:flutter/material.dart';

import '../../../../core/utils/price_format.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/wallet.dart';
import '../utils/wallet_display.dart';

/// Asks for a payout amount; pops with it once it passes
/// [WalletBalance.validateWithdrawal], or with `null` when dismissed.
Future<double?> showWithdrawSheet(
  BuildContext context, {
  required WalletBalance balance,
  required String currency,
}) => showModalBottomSheet<double>(
  context: context,
  isScrollControlled: true,
  backgroundColor: context.colors.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: _WithdrawSheet(balance: balance, currency: currency),
  ),
);

class _WithdrawSheet extends StatefulWidget {
  const _WithdrawSheet({required this.balance, required this.currency});

  final WalletBalance balance;
  final String currency;

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amount = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(parsePrice(_amount.text));
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                Strings.requestPayout,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${Strings.availableBalance}: '
                '${formatMoney(widget.balance.availableBalance, widget.currency)}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              AppFormField(
                label: Strings.payoutAmount,
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                suffixText: widget.currency.isEmpty ? null : widget.currency,
                validator: (String? text) => widget.balance
                    .validateWithdrawal(parsePrice(text ?? ''))
                    ?.message,
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: Strings.submitPayout, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
