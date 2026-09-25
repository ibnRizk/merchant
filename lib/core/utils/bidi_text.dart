/// Unicode bidi isolates for text that mixes Arabic and English.
///
/// Without isolation, neutral characters (`#`, `×`, digits, brackets) next
/// to text of the other direction get reordered: `#SSM-1048` shows as
/// `SSM-1048#` in an RTL layout, and an English name followed by `× 2`
/// scrambles. Wrapping each dynamic fragment keeps its own direction no
/// matter which layout direction surrounds it.
extension BidiText on String {
  /// U+2068 FIRST STRONG ISOLATE.
  static final String _fsi = String.fromCharCode(0x2068);

  /// U+2066 LEFT-TO-RIGHT ISOLATE.
  static final String _lri = String.fromCharCode(0x2066);

  /// U+2069 POP DIRECTIONAL ISOLATE.
  static final String _pdi = String.fromCharCode(0x2069);

  /// Direction detected from the text's first strong character.
  /// Use for user or server content: names, notes, addresses.
  String get bidiIsolated => isEmpty ? this : '$_fsi$this$_pdi';

  /// Always left-to-right. Use for codes and numbers such as order ids,
  /// phone numbers and prices.
  String get ltrIsolated => isEmpty ? this : '$_lri$this$_pdi';
}
