import '../../../../core/api/status_code.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/failures/transition_rejected_failure.dart';

/// See [TransitionRejectedFailure].
class TransitionRejectedException extends AppException {
  @override
  final String? message;

  const TransitionRejectedException({this.message});

  /// [error] as a [TransitionRejectedException] when an order command got a
  /// 404 or a 422 `order_transition_invalid`, otherwise `null`. Other 422s
  /// (validation errors) stay [ServerException]s.
  static TransitionRejectedException? from(ServerException error) {
    final bool rejected = switch (error.statusCode) {
      StatusCode.notFound => true,
      StatusCode.unProcessableContent =>
        error.code?.replaceAll('-', '_') == 'order_transition_invalid',
      _ => false,
    };
    return rejected
        ? TransitionRejectedException(message: error.message)
        : null;
  }

  @override
  Failure toFailure() => TransitionRejectedFailure(message: message);
}
