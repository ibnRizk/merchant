import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/pharmacy/domain/entities/pharmacy_request.dart';
import 'package:ssm_merchant/features/pharmacy/domain/repos/pharmacy_repository.dart';

export '../../helpers/fake_dio_consumer.dart';

PharmacyRequest aRequest(
  int id, {
  PharmacyRequestStatus status = PharmacyRequestStatus.submitted,
  bool hasPrescription = false,
}) => PharmacyRequest(
  id: id,
  status: status,
  customerNote: 'Panadol',
  hasPrescription: hasPrescription,
);

const PharmacyQuote aQuote = PharmacyQuote(amount: 185.5, summary: 'Panadol');

class FakePharmacyRepository implements PharmacyRepository {
  Either<Failure, List<PharmacyRequest>> requestsResult = Right(
    <PharmacyRequest>[aRequest(1), aRequest(2)],
  );
  Either<Failure, PharmacyRequest> requestResult = Right(aRequest(1));
  Either<Failure, Uint8List> prescriptionResult = Right(
    Uint8List.fromList(<int>[1, 2, 3]),
  );
  Either<Failure, Unit> quoteResult = const Right(unit);

  int requestCalls = 0;
  int prescriptionCalls = 0;
  final List<PharmacyQuote> quotes = <PharmacyQuote>[];

  @override
  Future<Either<Failure, List<PharmacyRequest>>> getRequests() async =>
      requestsResult;

  @override
  Future<Either<Failure, PharmacyRequest>> getRequest(int id) async {
    requestCalls++;
    return requestResult;
  }

  @override
  Future<Either<Failure, Uint8List>> getPrescription(int id) async {
    prescriptionCalls++;
    return prescriptionResult;
  }

  @override
  Future<Either<Failure, PharmacyRequest>> sendQuote(
    PharmacyRequest request,
    PharmacyQuote quote,
  ) async {
    quotes.add(quote);
    return quoteResult.map((_) => request.quoted(quote));
  }
}
