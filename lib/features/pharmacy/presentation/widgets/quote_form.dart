import 'package:flutter/material.dart';

import '../../../../core/utils/price_format.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/pharmacy_request.dart';
import '../utils/pharmacy_display.dart';

/// Amount, summary and note for a price quote, prefilled from the last
/// quote when re-pricing. Calls [onSubmit] with a valid quote.
class QuoteForm extends StatefulWidget {
  const QuoteForm({
    super.key,
    required this.onSubmit,
    required this.isSending,
    this.initial,
    this.currency = '',
  });

  final ValueChanged<PharmacyQuote> onSubmit;
  final bool isSending;
  final PharmacyQuote? initial;
  final String currency;

  @override
  State<QuoteForm> createState() => _QuoteFormState();
}

class _QuoteFormState extends State<QuoteForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount = TextEditingController(
    text: widget.initial == null ? '' : formatPrice(widget.initial!.amount),
  );
  late final TextEditingController _summary = TextEditingController(
    text: widget.initial?.summary ?? '',
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.initial?.note ?? '',
  );

  @override
  void dispose() {
    _amount.dispose();
    _summary.dispose();
    _note.dispose();
    super.dispose();
  }

  PharmacyQuote _quote() => PharmacyQuote(
    amount: parsePrice(_amount.text) ?? 0,
    summary: _summary.text.trim(),
    note: _note.text.trim(),
  );

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(_quote());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppFormField(
            label: Strings.quoteAmount,
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixText: widget.currency.isEmpty ? null : widget.currency,
            validator: (_) =>
                _quote().validationError == PharmacyQuoteError.invalidAmount
                ? PharmacyQuoteError.invalidAmount.message
                : null,
          ),
          const SizedBox(height: 12),
          AppFormField(
            label: Strings.quoteSummary,
            hintText: Strings.quoteSummaryHint,
            controller: _summary,
            maxLines: 3,
            validator: (String? text) => (text ?? '').trim().isEmpty
                ? PharmacyQuoteError.missingSummary.message
                : null,
          ),
          const SizedBox(height: 12),
          AppFormField(
            label: Strings.quoteNote,
            hintText: Strings.quoteNoteHint,
            controller: _note,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: widget.initial == null
                ? Strings.sendQuote
                : Strings.updateQuote,
            isLoading: widget.isSending,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
