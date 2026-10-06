import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/api/api_endpoints.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/pharmacy/data/datasources/pharmacy_remote_data_source.dart';
import 'package:ssm_merchant/features/pharmacy/data/repos/pharmacy_repository_impl.dart';
import 'package:ssm_merchant/features/pharmacy/domain/entities/pharmacy_request.dart';

import '../pharmacy_fakes.dart';

void main() {
  late FakeDioConsumer client;
  late PharmacyRemoteDataSourceImpl dataSource;
  late PharmacyRepositoryImpl repository;

  setUp(() {
    client = FakeDioConsumer();
    dataSource = PharmacyRemoteDataSourceImpl(client: client);
    repository = PharmacyRepositoryImpl(remote: dataSource);
  });

  test('lists requests from the paged response', () async {
    client.response = <String, dynamic>{
      'total_size': 1,
      'pharmacy_requests': <dynamic>[
        <String, dynamic>{
          'id': 3,
          'status': 'submitted',
          'customer': <String, dynamic>{'f_name': 'Sara', 'l_name': 'Ali'},
          'note': 'Panadol x2',
          'has_prescription': 1,
        },
      ],
    };

    final List<PharmacyRequest> requests = await dataSource.getRequests(
      limit: 50,
    );

    expect(client.calls.single.path, ApiEndpoints.pharmacyRequests);
    expect(client.calls.single.query?['limit'], 50);
    expect(requests.single.customerName, 'Sara Ali');
    expect(requests.single.customerNote, 'Panadol x2');
    expect(requests.single.hasPrescription, isTrue);
    expect(requests.single.quote, isNull);
  });

  test('details unwrap pharmacy_request and read the last quote', () async {
    client.response = <String, dynamic>{
      'pharmacy_request': <String, dynamic>{
        'id': 3,
        'status': 'quoted',
        'medicine_amount': '185.50',
        'medicine_summary': 'Panadol',
        'pharmacy_note': 'Generic ok',
      },
    };

    final PharmacyRequest request = await dataSource.getRequest(3);

    expect(request.status, PharmacyRequestStatus.quoted);
    expect(
      request.quote,
      const PharmacyQuote(
        amount: 185.5,
        summary: 'Panadol',
        note: 'Generic ok',
      ),
    );
  });

  test('the prescription is fetched as bytes', () async {
    client.response = <int>[1, 2, 3];

    final bytes = await dataSource.getPrescription(3);

    expect(client.calls.single.path, ApiEndpoints.pharmacyPrescription(3));
    expect(bytes, <int>[1, 2, 3]);
  });

  group('quote', () {
    test('posts the quote and marks the request quoted', () async {
      client.response = <String, dynamic>{'status': 'quoted'};
      const PharmacyQuote quote = PharmacyQuote(
        amount: 185.5,
        summary: ' Panadol ',
        note: ' ',
      );

      final result = await repository.sendQuote(aRequest(3), quote);

      expect(client.calls.single.path, ApiEndpoints.pharmacyQuote(3));
      expect(client.calls.single.body, <String, dynamic>{
        'medicine_amount': 185.5,
        'medicine_summary': 'Panadol',
      });
      final PharmacyRequest updated = result.getOrElse(() => aRequest(0));
      expect(updated.status, PharmacyRequestStatus.quoted);
      expect(updated.quote, quote);
    });

    test('a request that moved on fails with a ConflictFailure', () async {
      client.error = const ServerException(
        message: 'Not actionable',
        statusCode: 422,
        code: 'pharmacy_request_not_actionable',
      );

      final result = await repository.sendQuote(aRequest(3), aQuote);

      expect(
        result,
        const Left<Failure, PharmacyRequest>(
          ConflictFailure(
            message: 'Not actionable',
            code: 'pharmacy_request_not_actionable',
          ),
        ),
      );
    });

    test('a validation error keeps the server message', () async {
      client.error = const ServerException(
        message: 'The medicine summary field is required.',
        statusCode: 422,
      );

      final result = await repository.sendQuote(aRequest(3), aQuote);

      expect(
        result,
        const Left<Failure, PharmacyRequest>(
          ServerFailure(
            message: 'The medicine summary field is required.',
            statusCode: 422,
          ),
        ),
      );
    });
  });
}
