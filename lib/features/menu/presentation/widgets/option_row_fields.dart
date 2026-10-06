import 'package:flutter/material.dart';

import '../../../../core/utils/price_format.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';

/// Controllers for one editable variation or add-on row. Owned (and
/// disposed) by the screen's State.
class OptionRowControllers {
  final TextEditingController name;
  final TextEditingController price;

  /// Carried through unchanged: stock isn't edited on this screen.
  final int? stock;

  OptionRowControllers({String name = '', double? price, this.stock})
    : name = TextEditingController(text: name),
      price = TextEditingController(
        text: price == null ? '' : formatPrice(price),
      );

  void dispose() {
    name.dispose();
    price.dispose();
  }
}

/// Name and price fields for one row, with a remove button.
class OptionRowFields extends StatelessWidget {
  const OptionRowFields({
    super.key,
    required this.row,
    required this.namePlaceholder,
    required this.onRemove,
    this.allowFree = false,
    this.currency = '',
  });

  final OptionRowControllers row;
  final String namePlaceholder;
  final VoidCallback onRemove;

  /// Add-ons may cost nothing; variations must have a price.
  final bool allowFree;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    InputDecoration decoration(String hint, {String? suffix}) =>
        InputDecoration(
          hintText: hint,
          suffixText: suffix,
          isDense: true,
          filled: true,
          fillColor: colors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border),
          ),
        );
    const TextStyle style = TextStyle(fontFamily: 'Cairo', fontSize: 14);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: row.name,
              style: style,
              textInputAction: TextInputAction.next,
              decoration: decoration(namePlaceholder),
              validator: (String? text) => (text ?? '').trim().isEmpty
                  ? Strings.optionNameRequired
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 116,
            child: TextFormField(
              controller: row.price,
              style: style,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: decoration(
                Strings.optionPrice,
                suffix: currency.isEmpty ? null : currency,
              ),
              validator: (String? text) {
                final double? price = parsePrice(text ?? '');
                if (price == null || (!allowFree && price <= 0)) {
                  return Strings.optionPriceInvalid;
                }
                return null;
              },
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: Strings.removeOption,
            icon: Icon(Icons.close_rounded, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
