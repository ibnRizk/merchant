import 'package:equatable/equatable.dart';

import '../entities/merchant_approval_status.dart';
import 'failures.dart';

abstract class AppException extends Equatable implements Exception {
  abstract final String? message;

  const AppException();

  Failure toFailure();

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return '$message';
  }
}

class ServerException extends AppException {
  @override
  final String? message;

  /// The HTTP status, when the server answered with one.
  final int? statusCode;

  /// The API's `errors[].code`, e.g. `order_transition_invalid`.
  final String? code;

  const ServerException({this.message, this.statusCode, this.code});

  @override
  Failure toFailure() {
    return ServerFailure(message: message);
  }

  @override
  List<Object?> get props => [message, statusCode, code];
}

class FetchDataException extends AppException {
  @override
  final String? message;

  const FetchDataException({this.message});

  @override
  Failure toFailure() {
    return FetchDataFailure(message: message);
  }
}

class UnauthorizedException extends AppException {
  @override
  final String? message;

  const UnauthorizedException({this.message});

  @override
  Failure toFailure() {
    return UnauthorizedFailure(message: message);
  }
}

/// HTTP 403 with `merchant-not-approved` / `merchant-suspended`: the account
/// may not use operational routes.
class AccountRestrictedException extends AppException {
  @override
  final String? message;
  final MerchantApprovalStatus status;

  const AccountRestrictedException({required this.status, this.message});

  @override
  Failure toFailure() {
    return AccountRestrictedFailure(status: status, message: message);
  }

  @override
  List<Object?> get props => [message, status];
}

/// HTTP 409: the request clashes with the resource's current state, e.g.
/// deleting a product that is used in orders.
class ConflictException extends AppException {
  @override
  final String? message;

  /// The API's `errors[].code`, e.g. `active_orders_exist`.
  final String? code;

  const ConflictException({this.message, this.code});

  @override
  Failure toFailure() {
    return ConflictFailure(message: message, code: code);
  }

  @override
  List<Object?> get props => [message, code];
}

class InternetConnectionException extends AppException {
  @override
  final String? message;

  const InternetConnectionException({this.message});

  @override
  Failure toFailure() {
    return NetworkFailure(message: message);
  }
}

class CacheException extends AppException {
  @override
  final String? message;

  const CacheException({this.message});

  @override
  Failure toFailure() {
    return CacheFailure(message: message);
  }
}
