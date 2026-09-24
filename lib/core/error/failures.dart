import 'package:equatable/equatable.dart';

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

class UnauthorizedFailure extends Failure {
  @override
  final String? message;

  const UnauthorizedFailure({this.message});
}

/// The server refused because of the resource's state (HTTP 409).
class ConflictFailure extends Failure {
  @override
  final String? message;

  const ConflictFailure({this.message});
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
