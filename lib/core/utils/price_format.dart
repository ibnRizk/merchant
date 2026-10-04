/// Parses a price typed by the merchant. Accepts Arabic-Indic digits and
/// `,` / `٫` as the decimal separator, since Arabic keyboards produce them.
/// Returns `null` for anything that isn't a plain non-negative number.
double? parsePrice(String input) {
  const String arabicDigits = '٠١٢٣٤٥٦٧٨٩';
  final StringBuffer normalized = StringBuffer();
  for (final int rune in input.trim().runes) {
    final String char = String.fromCharCode(rune);
    final int arabicIndex = arabicDigits.indexOf(char);
    if (arabicIndex >= 0) {
      normalized.write(arabicIndex);
    } else if (char == ',' || char == '٫') {
      normalized.write('.');
    } else {
      normalized.write(char);
    }
  }
  final String text = normalized.toString();
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(text)) return null;
  return double.tryParse(text);
}

/// `28` for whole amounts, `28.50` otherwise.
String formatPrice(double price) => price == price.truncateToDouble()
    ? price.toStringAsFixed(0)
    : price.toStringAsFixed(2);

/// `28.50 EGP`. The amount alone while the server's currency is unknown,
/// rather than a guessed one.
String formatMoney(double amount, String currency) {
  final String price = formatPrice(amount);
  return currency.isEmpty ? price : '$price $currency';
}
