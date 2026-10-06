/// `true`, `1`, `"1"` or `"true"`: the API sends flags in any of these.
bool isTruthy(dynamic value) =>
    value == true || value == 1 || value == '1' || value == 'true';

/// Trimmed text, `''` for `null`.
String jsonText(dynamic value) => value == null ? '' : value.toString().trim();

/// A number sent as a number or a string (`"125.50"`), else [fallback].
double jsonDouble(dynamic value, {double fallback = 0}) =>
    double.tryParse('$value') ?? fallback;

/// An integer sent as a number or a string, else [fallback].
int jsonInt(dynamic value, {int fallback = 0}) =>
    int.tryParse('$value') ?? double.tryParse('$value')?.toInt() ?? fallback;

/// A list, or the `data` list of a Laravel paginator; otherwise empty.
List<dynamic> jsonList(dynamic value) {
  if (value is List) return value;
  if (value is Map && value['data'] is List) return value['data'] as List;
  return const <dynamic>[];
}

/// The `Map` elements of [jsonList].
Iterable<Map<String, dynamic>> jsonMaps(dynamic value) =>
    jsonList(value).whereType<Map<String, dynamic>>();

/// `2026-01-31`: the date format the API's `from` / `to` filters take.
String jsonDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
