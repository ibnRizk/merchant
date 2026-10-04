/// Whether the merchant may use operational routes, as the server reports it.
///
/// Shared by login, the splash routing, the pending screen and the global
/// 403 handler, so it lives in `core`.
enum MerchantApprovalStatus {
  /// Waiting for an admin to review the application.
  pending,
  approved,
  rejected,

  /// Approved once, but an admin has since blocked the account or store.
  suspended,
}
