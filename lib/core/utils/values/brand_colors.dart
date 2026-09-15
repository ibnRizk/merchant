import 'package:flutter/material.dart';

/// Raw SSM Merchant brand palette shared by the standalone (not-yet-wired-to-
/// theme) screens under `features/*/presentation`. Centralised here purely to
/// avoid re-declaring the same hex values in every small widget file.
abstract class BrandColors {
  static const Color navy = Color(0xFF173C66);
  static const Color orange = Color(0xFFF6921E);

  static const Color peachBg = Color(0xFFFCE9D8);
  static const Color statusBg = Color(0xFFE6F5EC);
  static const Color statusText = Color(0xFF2E9E5B);

  static const Color fieldFill = Color(0xFFF5F6F8);
  static const Color border = Color(0xFFE2E5EA);
  static const Color hintGray = Color(0xFFAAB2BD);
  static const Color textGray = Color(0xFF9AA1AC);
}
