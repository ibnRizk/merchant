import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure_message.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repos/wallet_repository.dart';
import 'wallet_state.dart';

export 'wallet_state.dart';

/// Balances, payout history and payout requests
/// (`GET /vendor/wallet`, `POST /vendor/withdraw-requests`).
class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;

  /// Bumped on every fetch, so an older response can't overwrite a newer one.
  int _generation = 0;

  WalletCubit({required WalletRepository repository})
    : _repository = repository,
      super(const WalletLoading());

  Future<void> load() async {
    final int generation = ++_generation;
    emit(const WalletLoading());
    final result = await _repository.getWallet();
    if (isClosed || generation != _generation) return;

    emit(
      result.fold(
        (failure) => WalletLoadFailure(failure.displayMessage),
        WalletLoaded.new,
      ),
    );
  }

  /// Keeps the current figures on screen until the new ones arrive.
  Future<void> refresh() async {
    if (state is! WalletLoaded) return load();

    final int generation = ++_generation;
    final result = await _repository.getWallet();
    final WalletState latest = state;
    if (isClosed || generation != _generation || latest is! WalletLoaded) {
      return;
    }

    emit(
      result.fold(
        (failure) => latest.copyWith(
          notice: WalletFailureNotice(failure.displayMessage),
        ),
        (WalletOverview overview) => latest.copyWith(overview: overview),
      ),
    );
  }

  /// Requests a payout of [amount], then reloads the balances (the amount
  /// moves to `pendingWithdraw`). The caller validates [amount] with
  /// [WalletBalance.validateWithdrawal] first; an invalid one is ignored.
  Future<void> requestWithdrawal(double amount) async {
    final WalletState current = state;
    if (current is! WalletLoaded ||
        current.isSubmitting ||
        current.overview.balance.validateWithdrawal(amount) != null) {
      return;
    }

    emit(current.copyWith(isSubmitting: true));
    final result = await _repository.requestWithdrawal(amount);
    final WalletState latest = state;
    if (isClosed || latest is! WalletLoaded) return;

    result.fold(
      (failure) => emit(
        latest.copyWith(
          isSubmitting: false,
          notice: WalletFailureNotice(failure.displayMessage),
        ),
      ),
      (_) {
        emit(
          latest.copyWith(
            isSubmitting: false,
            notice: WithdrawRequestedNotice(),
          ),
        );
        refresh();
      },
    );
  }
}
