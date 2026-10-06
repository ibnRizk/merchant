import 'package:equatable/equatable.dart';

import '../entities/merchant_approval_status.dart';

abstract class Failure extends Equatable {
  abstract final String? message;

  const Failure();

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  @override
  final String? message;

  const ServerFailure({this.message});
}

/// See `UnexpectedResponseException`; shown as `Strings.unexpectedResponse`.
class UnexpectedResponseFailure extends ServerFailure {
  const UnexpectedResponseFailure();
}

class UnauthorizedFailure extends Failure {
  @override
  final String? message;

  const UnauthorizedFailure({this.message});
}

/// The account is pending, rejected or suspended (HTTP 403 with
/// `merchant-not-approved` / `merchant-suspended`).
class AccountRestrictedFailure extends Failure {
  @override
  final String? message;
  final MerchantApprovalStatus status;

  const AccountRestrictedFailure({required this.status, this.message});

  @override
  List<Object?> get props => [message, status];
}

/// The server refused because of the resource's state (HTTP 409).
class ConflictFailure extends Failure {
  @override
  final String? message;

  /// The API's `errors[].code`, e.g. `active_orders_exist`.
  final String? code;

  const ConflictFailure({this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class CacheFailure extends Failure {
  @override
  final String? message;

  const CacheFailure({this.message});
}

class NetworkFailure extends Failure {
  @override
  final String? message;

  const NetworkFailure({this.message});
}

class FetchDataFailure extends Failure {
  @override
  final String? message;

  const FetchDataFailure({this.message});
}
