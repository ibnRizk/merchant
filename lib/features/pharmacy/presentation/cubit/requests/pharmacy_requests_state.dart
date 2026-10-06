import '../../../domain/entities/pharmacy_request.dart';

sealed class PharmacyRequestsState {
  const PharmacyRequestsState();
}

final class PharmacyRequestsLoading extends PharmacyRequestsState {
  const PharmacyRequestsLoading();
}

final class PharmacyRequestsLoadFailure extends PharmacyRequestsState {
  final String message;

  const PharmacyRequestsLoadFailure(this.message);
}

final class PharmacyRequestsLoaded extends PharmacyRequestsState {
  final List<PharmacyRequest> requests;

  /// Set when a refresh failed; the list stays. A new instance per
  /// failure, so a listener can tell it apart.
  final PharmacyRefreshFailure? refreshFailure;

  const PharmacyRequestsLoaded(this.requests, {this.refreshFailure});
}

final class PharmacyRefreshFailure {
  final String message;

  // Not const: each failure must be a distinct instance.
  PharmacyRefreshFailure(this.message);
}
