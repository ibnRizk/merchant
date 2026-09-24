import 'package:dio/dio.dart';

import 'api_endpoints.dart';

/// [LogInterceptor] that never prints credentials:
/// - request headers are not logged, so the bearer token never is;
/// - `/auth/*` bodies are skipped (passwords, OTPs, and the login token).
class RedactingLogInterceptor extends LogInterceptor {
  RedactingLogInterceptor()
    : super(
        request: true,
        requestBody: true,
        requestHeader: false,
        responseBody: true,
        responseHeader: false,
        error: true,
      );

  static bool _isSensitive(RequestOptions options) =>
      options.path.startsWith(ApiEndpoints.authPrefix);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_isSensitive(options)) {
      logPrint('*** Request *** ${options.method} ${options.uri} <redacted>');
      handler.next(options);
      return;
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (_isSensitive(response.requestOptions)) {
      logPrint(
        '*** Response *** ${response.statusCode} '
        '${response.requestOptions.uri} <redacted>',
      );
      handler.next(response);
      return;
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_isSensitive(err.requestOptions)) {
      // Error bodies are safe (validation messages), but the parent would
      // also dump the request, which holds the password.
      logPrint(
        '*** DioException *** ${err.response?.statusCode} '
        '${err.requestOptions.uri} ${err.response?.data}',
      );
      handler.next(err);
      return;
    }
    super.onError(err, handler);
  }
}
