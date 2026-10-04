import 'dart:async';

import '../entities/merchant_approval_status.dart';

/// Session events raised by the network layer and handled once, app-wide.
class AuthEventBus {
  static final AuthEventBus instance = AuthEventBus._internal();
  AuthEventBus._internal();

  final _unauthorizedController = StreamController<void>.broadcast();
  final _accountRestrictedController =
      StreamController<MerchantApprovalStatus>.broadcast();

  /// The token is missing, invalid or revoked (401).
  Stream<void> get unauthorizedStream => _unauthorizedController.stream;

  /// The account may not operate right now (403 `merchant-not-approved` /
  /// `merchant-suspended`). The token is still valid for onboarding routes.
  Stream<MerchantApprovalStatus> get accountRestrictedStream =>
      _accountRestrictedController.stream;

  void emitUnauthorized() {
    _unauthorizedController.add(null);
  }

  void emitAccountRestricted(MerchantApprovalStatus status) {
    _accountRestrictedController.add(status);
  }
}
