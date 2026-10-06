import 'dart:typed_data';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/status_code.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/pharmacy_request.dart';
import '../models/pharmacy_models.dart';

/// Talks to `/vendor/pharmacy-requests`. Throws [AppException]s; the
/// repository turns them into failures. A request that can no longer be
/// quoted (HTTP 422 `pharmacy_request_not_actionable`) surfaces as a
/// [ConflictException]: its state changed, like a 409.
abstract class PharmacyRemoteDataSource {
  Future<List<PharmacyRequest>> getRequests({required int limit});

  Future<PharmacyRequest> getRequest(int id);

  Future<Uint8List> getPrescription(int id);

  /// The updated request when the response carries it, else `null`.
  Future<PharmacyRequest?> sendQuote(int id, PharmacyQuote quote);
}

class PharmacyRemoteDataSourceImpl implements PharmacyRemoteDataSource {
  final DioConsumer _client;

  const PharmacyRemoteDataSourceImpl({required DioConsumer client})
    : _client = client;

  @override
  Future<List<PharmacyRequest>> getRequests({required int limit}) async =>
      parsePharmacyRequests(
        await _client.get(
          ApiEndpoints.pharmacyRequests,
          queryParameters: <String, dynamic>{'limit': limit, 'offset': 1},
        ),
      );

  @override
  Future<PharmacyRequest> getRequest(int id) async {
    final Map<String, dynamic> json = _asMap(
      await _client.get(ApiEndpoints.pharmacyRequest(id)),
    );
    final dynamic request = json['pharmacy_request'];
    return PharmacyRequestModel.fromJson(
      request is Map<String, dynamic> ? request : json,
    );
  }

  @override
  Future<Uint8List> getPrescription(int id) async => Uint8List.fromList(
    await _client.getBytes(ApiEndpoints.pharmacyPrescription(id)),
  );

  @override
  Future<PharmacyRequest?> sendQuote(int id, PharmacyQuote quote) async {
    final dynamic response;
    try {
      response = await _client.post(
        ApiEndpoints.pharmacyQuote(id),
        body: quote.toJson(),
      );
    } on ServerException catch (error) {
      if (error.statusCode == StatusCode.unProcessableContent &&
          error.code == 'pharmacy_request_not_actionable') {
        throw ConflictException(message: error.message, code: error.code);
      }
      rethrow;
    }
    final dynamic request = response is Map
        ? response['pharmacy_request']
        : null;
    return request is Map<String, dynamic>
        ? PharmacyRequestModel.fromJson(request)
        : null;
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    throw ServerException.unexpectedResponse();
  }
}
