/// The canonical order lifecycle (`ssm_status` on the API).
///
/// The merchant drives `pendingMerchant` → `accepted` → `preparing` →
/// `readyForPickup`; dispatch and delivery are driven by the driver app.
enum OrderStatus {
  pendingMerchant,
  accepted,
  preparing,
  readyForPickup,
  dispatching,
  driverAssigned,
  driverAccepted,
  pickedUp,
  outForDelivery,
  delivered,
  rejected,
  cancelled,
  assignmentFailed,
  failed,
  refunded,
  unknown;

  /// Reads `ssm_status`, falling back to the legacy `order_status` values
  /// the history endpoint may still send.
  static OrderStatus fromApi(String? value) =>
      switch (value?.trim().toLowerCase()) {
        'pending_merchant' || 'pending' => pendingMerchant,
        'accepted' || 'confirmed' => accepted,
        'preparing' || 'processing' => preparing,
        'ready_for_pickup' || 'handover' => readyForPickup,
        'dispatching' => dispatching,
        'driver_assigned' => driverAssigned,
        'driver_accepted' => driverAccepted,
        'picked_up' => pickedUp,
        'out_for_delivery' => outForDelivery,
        'delivered' => delivered,
        'rejected' => rejected,
        'cancelled' || 'canceled' => cancelled,
        'assignment_failed' => assignmentFailed,
        'failed' => failed,
        'refunded' || 'refund_requested' => refunded,
        _ => unknown,
      };

  /// Waiting for the merchant to accept or reject.
  bool get isNew => this == pendingMerchant;

  bool get isCompleted => this == delivered;

  /// Ended without reaching the customer.
  bool get isCancelled => switch (this) {
    rejected || cancelled || failed || refunded => true,
    _ => false,
  };

  bool get isTerminal => isCompleted || isCancelled;

  /// Accepted and not finished yet (includes the dispatch stages, and
  /// [assignmentFailed], which the merchant can still recover).
  bool get isActive => !isNew && !isTerminal && this != unknown;

  /// Accepted but not handed to dispatch yet: the store can still call the
  /// order off (out of stock, closing, the customer asked).
  bool get canCancel => this == accepted || this == preparing;

  /// No driver accepted the order; `retry-dispatch` offers it again.
  bool get canRetryDispatch => this == assignmentFailed;

  /// The single forward step the merchant can take, if any. Rejecting is
  /// the extra option on a new order and is not returned here.
  OrderAction? get nextAction => switch (this) {
    pendingMerchant => OrderAction.accept,
    accepted => OrderAction.startPreparing,
    preparing => OrderAction.readyForPickup,
    _ => null,
  };
}

/// Commands the merchant can send for an order.
enum OrderAction {
  accept('accept'),
  reject('reject'),
  startPreparing('start-preparing'),
  readyForPickup('ready-for-pickup'),

  /// Only while [OrderStatus.canCancel]; needs a reason.
  cancel('cancel');

  /// The last path segment of `POST /vendor/orders/{id}/{path}`.
  final String path;

  const OrderAction(this.path);
}
