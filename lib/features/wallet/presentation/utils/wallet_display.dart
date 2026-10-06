import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/wallet.dart';

extension WithdrawStatusDisplay on WithdrawStatus {
  String get label => switch (this) {
    WithdrawStatus.pending => Strings.withdrawPending,
    WithdrawStatus.approved => Strings.withdrawApproved,
    WithdrawStatus.denied => Strings.withdrawDenied,
    WithdrawStatus.unknown => Strings.statusUnknown,
  };

  /// Pill colors: (background, text).
  (Color, Color) pillColors(AppColors colors) => switch (this) {
    WithdrawStatus.pending => (colors.primaryLight, colors.primary),
    WithdrawStatus.approved => (colors.successContainer, colors.success),
    WithdrawStatus.denied => (colors.errorContainer, colors.error),
    WithdrawStatus.unknown => (colors.border, colors.textSecondary),
  };
}

extension WithdrawAmountErrorDisplay on WithdrawAmountError {
  String get message => switch (this) {
    WithdrawAmountError.invalid => Strings.withdrawAmountInvalid,
    WithdrawAmountError.belowMinimum => Strings.withdrawAmountTooLow,
    WithdrawAmountError.aboveBalance => Strings.withdrawAmountAboveBalance,
  };
}
