/// `true`, `1`, `"1"` or `"true"`: the API sends flags in any of these.
bool isTruthy(dynamic value) =>
    value == true || value == 1 || value == '1' || value == 'true';
