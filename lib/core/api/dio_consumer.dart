import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/env/app_env.dart';
import '../../injection_container.dart';
import '../entities/merchant_approval_status.dart';
import '../error/exceptions.dart';
import '../utils/extension.dart';
import '../utils/log_utils.dart';
import '../utils/values/strings.dart';
import 'api_endpoints.dart';
import 'api_error_body.dart';
import 'status_code.dart';

/// Thin, typed wrapper over Dio. Data sources depend on this abstraction, not
/// on Dio itself, which keeps them unit-testable with a fake consumer.
abstract class DioConsumer {
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters});

  /// The raw body of a binary download (e.g. a private image stream).
  Future<List<int>> getBytes(String path);

  /// [headers] are added to this request only (e.g. `Idempotency-Key`).
  Future<dynamic> post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<dynamic> put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  });

  void updateLanguageCodeHeader();

  void updateDeviceTokenHeader(String token);

  void updateDeviceTypeHeader();
}

class DioConsumerImpl implements DioConsumer {
  final Dio client;

  DioConsumerImpl({required this.client}) {
    client.options
      ..baseUrl = AppEnv.baseUrl
      ..connectTimeout = AppEnv.connectTimeout
      ..receiveTimeout = AppEnv.receiveTimeout
      ..contentType = Headers.jsonContentType
      ..headers = <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.acceptLanguageHeader: sharedPreferences
            .getLanguageCode()
            .name,
        'device-lang': sharedPreferences.getLanguageCode().name,
        'device-type': _devicePlatform,
        // Required by every merchant route; anything else returns 401.
        'vendorType': 'owner',
        // The language the server localises its messages into.
        'X-localization': sharedPreferences.getLanguageCode().name,
      };

    client.interceptors.add(appInterceptors);
    // LogInterceptor prints with print(), which also runs in release builds.
    if (kDebugMode && AppEnv.enableNetworkLogs) {
      client.interceptors.add(logInterceptor);
    }
  }

  static String get _devicePlatform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'other';
  }

  /// Re-read on every request so a login/logout mid-session takes effect
  /// without rebuilding the client.
  Future<void> _attachAccessToken() async {
    final String? accessToken = await secureStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      client.options.headers[HttpHeaders.authorizationHeader] =
          'Bearer $accessToken';
    } else {
      client.options.headers.remove(HttpHeaders.authorizationHeader);
    }
  }

  @override
  void updateLanguageCodeHeader() {
    final String code = sharedPreferences.getLanguageCode().name;
    client.options.headers[HttpHeaders.acceptLanguageHeader] = code;
    client.options.headers['device-lang'] = code;
    client.options.headers['X-localization'] = code;
  }

  @override
  void updateDeviceTokenHeader(String token) =>
      client.options.headers['device-token'] = token;

  @override
  void updateDeviceTypeHeader() =>
      client.options.headers['device-type'] = _devicePlatform;

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _request(
        'GET',
        path,
        () => client.get<dynamic>(path, queryParameters: queryParameters),
        details: 'params: $queryParameters',
      );

  @override
  Future<List<int>> getBytes(String path) async {
    final dynamic data = await _request(
      'GET',
      path,
      () => client.get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      ),
      logResponse: false,
    );
    if (data is List<int>) return data;
    throw const UnexpectedResponseException();
  }

  @override
  Future<dynamic> post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) => _request(
    'POST',
    path,
    () => client.post<dynamic>(
      path,
      queryParameters: queryParameters,
      data: formData ?? body,
      options: headers == null ? null : Options(headers: headers),
    ),
    details: 'formData: ${formData?.toPrint}, body: $body',
  );

  @override
  Future<dynamic> put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) => _request(
    'PUT',
    path,
    () => client.put<dynamic>(
      path,
      queryParameters: queryParameters,
      data: formData ?? body,
    ),
    details: 'formData: ${formData?.toPrint}, body: $body',
  );

  @override
  Future<dynamic> patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) => _request(
    'PATCH',
    path,
    () => client.patch<dynamic>(
      path,
      queryParameters: queryParameters,
      data: formData ?? body,
    ),
    details: 'formData: ${formData?.toPrint}, body: $body',
  );

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) => _request(
    'DELETE',
    path,
    () => client.delete<dynamic>(
      path,
      queryParameters: queryParameters,
      data: data,
    ),
    details: 'data: $data',
  );

  /// Single funnel for every verb: logging, token attachment and error mapping
  /// live here instead of being copy-pasted per method.
  Future<dynamic> _request(
    String verb,
    String path,
    Future<Response<dynamic>> Function() send, {
    String details = '',
    bool logResponse = true,
  }) async {
    // Auth bodies carry passwords/OTPs and responses carry the token.
    final bool redact = path.startsWith(ApiEndpoints.authPrefix);
    try {
      Log.i('[$verb][$path] ${redact ? '<redacted>' : details}');
      await _attachAccessToken();
      final Response<dynamic> response = await send();
      Log.i(
        '[$verb][$path] response: '
        '${redact || !logResponse ? '<redacted>' : response.data}',
      );
      return response.data;
    } on SocketException {
      throw InternetConnectionException(message: Strings.noInternetConnection);
    } on DioException catch (error) {
      _throwMappedError(error);
    } catch (_) {
      // Raw exception text is not fit to show users.
      throw const UnexpectedResponseException();
    }
  }

  /// Returns [Never] so the analyzer proves every branch throws. A `void`
  /// version silently lets the caller's Future resolve with `null` whenever a
  /// branch is missed.
  Never _throwMappedError(DioException error) {
    final int? status = error.response?.statusCode;
    final dynamic data = error.response?.data;

    if (status == StatusCode.forbidden) {
      final MerchantApprovalStatus? restriction = accountRestrictionOf(data);
      if (restriction != null) {
        throw AccountRestrictedException(
          status: restriction,
          message: _messageOf(data),
        );
      }
    }

    if (status == StatusCode.unauthorized || status == StatusCode.forbidden) {
      throw UnauthorizedException(message: _messageOf(data));
    }

    if (status == StatusCode.conflict) {
      throw ConflictException(
        message: _messageOf(data),
        code: apiErrorCode(data),
      );
    }

    if (status == StatusCode.unProcessableContent) {
      throw ServerException(
        message: _messageOf(data),
        statusCode: status,
        code: apiErrorCode(data),
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw InternetConnectionException(
          message: Strings.noInternetConnection,
        );
      case DioExceptionType.cancel:
        throw ServerException(message: Strings.requestCancelled);
      default:
        throw ServerException(
          message: _messageOf(data),
          statusCode: status,
          code: apiErrorCode(data),
        );
    }
  }

  /// Indexing `data['message']` directly throws whenever the server answers
  /// with an HTML error page or a bare string, masking the real failure.
  ///
  /// `errors` wins over `message` because it holds the specific reason:
  /// the API sends `{"errors":[{"code","message"}]}`, and Laravel validation
  /// sends `{"message":"... (and 1 more error)","errors":{"field":["..."]}}`.
  String _messageOf(dynamic data) {
    if (data is Map) {
      final List<String> errors = _errorMessagesOf(data['errors']);
      if (errors.isNotEmpty) return errors.join('\n');
    }
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data == null) return Strings.somethingWentWrong;
    // An HTML error page or other raw payload: never show it to users.
    return Strings.unexpectedResponse;
  }

  List<String> _errorMessagesOf(dynamic errors) {
    if (errors is List) {
      return <String>[
        for (final dynamic error in errors)
          if (error is Map && error['message'] != null)
            error['message'].toString(),
      ];
    }
    if (errors is Map) {
      return <String>[
        for (final dynamic messages in errors.values)
          if (messages is List && messages.isNotEmpty)
            messages.first.toString()
          else if (messages is String)
            messages,
      ];
    }
    return const <String>[];
  }
}
