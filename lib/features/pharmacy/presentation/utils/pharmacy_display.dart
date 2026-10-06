import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/pharmacy_request.dart';

extension PharmacyRequestStatusDisplay on PharmacyRequestStatus {
  String get label => switch (this) {
    PharmacyRequestStatus.submitted => Strings.pharmacyAwaitingPrice,
    PharmacyRequestStatus.quoted => Strings.pharmacyQuoted,
    PharmacyRequestStatus.converted => Strings.pharmacyConverted,
    PharmacyRequestStatus.rejected => Strings.statusRejected,
    PharmacyRequestStatus.cancelled => Strings.cancelledStatus,
    PharmacyRequestStatus.unknown => Strings.statusUnknown,
  };

  /// Pill colors: (background, text).
  (Color, Color) pillColors(AppColors colors) => switch (this) {
    PharmacyRequestStatus.submitted => (colors.primaryLight, colors.primary),
    PharmacyRequestStatus.quoted => (
      colors.info.withValues(alpha: 0.12),
      colors.info,
    ),
    PharmacyRequestStatus.converted => (
      colors.successContainer,
      colors.success,
    ),
    PharmacyRequestStatus.rejected ||
    PharmacyRequestStatus.cancelled => (colors.errorContainer, colors.error),
    PharmacyRequestStatus.unknown => (colors.border, colors.textSecondary),
  };
}

extension PharmacyQuoteErrorDisplay on PharmacyQuoteError {
  String get message => switch (this) {
    PharmacyQuoteError.invalidAmount => Strings.quoteAmountInvalid,
    PharmacyQuoteError.missingSummary => Strings.quoteSummaryRequired,
  };
}

/// `12 Mar 2026, 14:20` in [locale].
String formatRequestTime(DateTime time, String locale) =>
    '${DateFormat.yMMMd(locale).format(time)}, ${DateFormat.Hm(locale).format(time)}';
