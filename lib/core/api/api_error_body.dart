import '../entities/merchant_approval_status.dart';

/// The first `errors[].code` of an API error body
/// (`{"errors":[{"code":"...","message":"..."}]}`), or `null`.
String? apiErrorCode(dynamic data) {
  if (data is! Map) return null;
  final dynamic errors = data['errors'];
  if (errors is! List) return null;
  for (final dynamic error in errors) {
    if (error is Map && error['code'] != null) return error['code'].toString();
  }
  return null;
}

/// The account restriction a 403 body describes, or `null` when the 403 is
/// about something else (a foreign document, a legacy validation error...).
///
/// `merchant-not-approved` carries `approval_status` (`pending` or
/// `rejected`). `merchant-suspended` is not in the API docs yet; it is
/// matched so the app is ready when the server starts sending it.
MerchantApprovalStatus? accountRestrictionOf(dynamic data) {
  final String? code = apiErrorCode(data)?.replaceAll('_', '-');
  return switch (code) {
    'merchant-not-approved' =>
      _approvalStatusOf(data) == 'rejected'
          ? MerchantApprovalStatus.rejected
          : MerchantApprovalStatus.pending,
    'merchant-suspended' => MerchantApprovalStatus.suspended,
    _ => null,
  };
}

String? _approvalStatusOf(dynamic data) {
  final dynamic errors = data is Map ? data['errors'] : null;
  if (errors is! List) return null;
  for (final dynamic error in errors) {
    if (error is Map && error['approval_status'] != null) {
      return error['approval_status'].toString();
    }
  }
  return null;
}
