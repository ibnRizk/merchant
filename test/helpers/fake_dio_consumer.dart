import 'package:dio/dio.dart';
import 'package:flutter_base/core/api/dio_consumer.dart';

/// Records calls and answers with a canned [response] or throws [error].
class FakeDioConsumer implements DioConsumer {
  dynamic response;
  Object? error;
  final List<
    ({
      String verb,
      String path,
      Map<String, dynamic>? query,
      Map<String, dynamic>? body,
      FormData? formData,
    })
  >
  calls = [];

  Future<dynamic> _answer(
    String verb,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    FormData? formData,
  }) async {
    calls.add((
      verb: verb,
      path: path,
      query: query,
      body: body,
      formData: formData,
    ));
    if (error != null) throw error!;
    return response;
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _answer('GET', path, query: queryParameters);

  @override
  Future<dynamic> post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) => _answer('POST', path, body: body, formData: formData);

  @override
  Future<dynamic> put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) => _answer('PUT', path, body: body, formData: formData);

  @override
  Future<dynamic> patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) => _answer('PATCH', path, body: body, formData: formData);

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) => _answer('DELETE', path);

  @override
  void updateLanguageCodeHeader() {}

  @override
  void updateDeviceTokenHeader(String token) {}

  @override
  void updateDeviceTypeHeader() {}
}
