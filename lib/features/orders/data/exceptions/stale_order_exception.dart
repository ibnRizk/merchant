import '../../../../core/api/status_code.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/failures/stale_order_failure.dart';

/// See [StaleOrderFailure].
class StaleOrderException extends AppException {
  @override
  final String? message;

  const StaleOrderException({this.message});

  /// [error] as a [StaleOrderException] when an order command's 404 or 422
  /// `order_transition_invalid` caused it, otherwise `null`.
  static StaleOrderException? from(ServerException error) {
    final bool stale = switch (error.statusCode) {
      StatusCode.notFound => true,
      StatusCode.unProcessableContent =>
        error.code?.replaceAll('-', '_') == 'order_transition_invalid',
      _ => false,
    };
    return stale ? StaleOrderException(message: error.message) : null;
  }

  @override
  Failure toFailure() => StaleOrderFailure(message: message);
}
