import '../../../core/error/failures.dart';

/// An order command the server refused because the order is no longer in a
/// state that allows it: HTTP 422 `order_transition_invalid` (e.g. the
/// customer cancelled) or 404 (the order is gone or belongs to another
/// store). Like a 409 conflict, the local copy is stale and must be reloaded.
class TransitionRejectedFailure extends Failure {
  @override
  final String? message;

  const TransitionRejectedFailure({this.message});
}

extension StaleOrderFailure on Failure {
  /// The order changed under the merchant (409, 422 transition, 404): show
  /// the conflict notice and reload instead of the raw error.
  bool get meansStaleOrder =>
      this is ConflictFailure || this is TransitionRejectedFailure;
}
