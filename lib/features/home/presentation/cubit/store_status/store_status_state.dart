/// The store's open/closed switch.
final class StoreStatusState {
  /// `null` until the profile has loaded.
  final bool? isOpen;

  /// A change is in flight; the switch shows it optimistically.
  final bool isUpdating;

  /// The last change failed and was reverted. A new instance per failure,
  /// so a listener can tell it apart.
  final StoreStatusFailure? failure;

  const StoreStatusState({this.isOpen, this.isUpdating = false, this.failure});
}

final class StoreStatusFailure {
  final String message;

  // Not const: each failure must be a distinct instance.
  StoreStatusFailure(this.message);
}
