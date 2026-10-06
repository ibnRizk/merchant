import '../../domain/entities/wallet.dart';

sealed class WalletState {
  const WalletState();
}

final class WalletLoading extends WalletState {
  const WalletLoading();
}

/// The first load failed; there is nothing to show.
final class WalletLoadFailure extends WalletState {
  final String message;

  const WalletLoadFailure(this.message);
}

final class WalletLoaded extends WalletState {
  final WalletOverview overview;

  /// A withdrawal request is in flight.
  final bool isSubmitting;

  /// Describes only the emit it came with (see [WalletNotice]).
  final WalletNotice? notice;

  const WalletLoaded(this.overview, {this.isSubmitting = false, this.notice});

  /// [notice] is not carried over.
  WalletLoaded copyWith({
    WalletOverview? overview,
    bool? isSubmitting,
    WalletNotice? notice,
  }) => WalletLoaded(
    overview ?? this.overview,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    notice: notice,
  );
}

/// A one-off outcome for the UI to announce. Instances are never const, so
/// a listener can tell a fresh notice apart with `identical`.
sealed class WalletNotice {
  const WalletNotice();
}

final class WithdrawRequestedNotice extends WalletNotice {
  // Not const: each notice must be a distinct instance.
  WithdrawRequestedNotice();
}

final class WalletFailureNotice extends WalletNotice {
  final String message;

  WalletFailureNotice(this.message);
}
