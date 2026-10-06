import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../domain/entities/pharmacy_request.dart';
import '../../domain/repos/pharmacy_repository.dart';
import '../datasources/pharmacy_remote_data_source.dart';

class PharmacyRepositoryImpl implements PharmacyRepository {
  /// Requests shown on the list (the API pages them).
  static const int pageSize = 50;

  final PharmacyRemoteDataSource _remote;

  const PharmacyRepositoryImpl({required PharmacyRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<PharmacyRequest>>> getRequests() =>
      guardFailure(() => _remote.getRequests(limit: pageSize));

  @override
  Future<Either<Failure, PharmacyRequest>> getRequest(int id) =>
      guardFailure(() => _remote.getRequest(id));

  @override
  Future<Either<Failure, Uint8List>> getPrescription(int id) =>
      guardFailure(() => _remote.getPrescription(id));

  /// The quote response may only carry `{status: quoted}`; the request is
  /// then updated locally with the quote that was sent.
  @override
  Future<Either<Failure, PharmacyRequest>> sendQuote(
    PharmacyRequest request,
    PharmacyQuote quote,
  ) => guardFailure(
    () async =>
        await _remote.sendQuote(request.id, quote) ?? request.quoted(quote),
  );
}
