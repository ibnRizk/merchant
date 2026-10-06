import '../../../../core/error/failures.dart';

/// An order command was refused because the order moved on: HTTP 422
/// `order_transition_invalid` (its status no longer allows the command) or
/// HTTP 404 (it is gone, e.g. cancelled). The view is stale, so it is
/// handled like a [ConflictFailure]: announce it and reload.
class StaleOrderFailure extends Failure {
  @override
  final String? message;

  const StaleOrderFailure({this.message});
}

extension StaleOrderCheck on Failure {
  /// The command acted on an outdated view of the order (409, 404 or 422
  /// `order_transition_invalid`); reloading shows its real state.
  bool get isStaleOrder => this is ConflictFailure || this is StaleOrderFailure;
}
