import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '/injection_container.dart';
import '../entities/merchant_approval_status.dart';
import 'api_endpoints.dart';
import 'api_error_body.dart';

class AppInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
    // Multipart bodies must keep the boundary Dio generates for them.
    if (options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // debugPrint(
    //     'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // A 401 from the public auth routes is a wrong password, not an expired
    // session, so it must not log the user out.
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.startsWith(ApiEndpoints.authPrefix)) {
      eventBus.emitUnauthorized(); // 🔥 Trigger navigation to Login
    }
    if (err.response?.statusCode == 403) {
      final MerchantApprovalStatus? restriction = accountRestrictionOf(
        err.response?.data,
      );
      if (restriction != null) eventBus.emitAccountRestricted(restriction);
    }
    // debugPrint is not stripped in release builds.
    if (kDebugMode) {
      final bool redact = err.requestOptions.path.startsWith(
        ApiEndpoints.authPrefix,
      );
      debugPrint(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path} => RESPONSE: ${redact ? '<redacted>' : err.response?.toString()}',
      );
    }
    super.onError(err, handler);
  }
}
