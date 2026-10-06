import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/pharmacy_request.dart';

/// Prescription requests sent to this pharmacy. Every route needs an
/// approved pharmacy account.
abstract class PharmacyRepository {
  /// The latest requests, newest first.
  Future<Either<Failure, List<PharmacyRequest>>> getRequests();

  Future<Either<Failure, PharmacyRequest>> getRequest(int id);

  /// The prescription image's bytes (a private stream, never a URL).
  Future<Either<Failure, Uint8List>> getPrescription(int id);

  /// Sends (or replaces) the price. The customer then accepts, which
  /// creates a COD order, or rejects. Fails with a `ConflictFailure` when
  /// the request can no longer be quoted.
  Future<Either<Failure, PharmacyRequest>> sendQuote(
    PharmacyRequest request,
    PharmacyQuote quote,
  );
}
