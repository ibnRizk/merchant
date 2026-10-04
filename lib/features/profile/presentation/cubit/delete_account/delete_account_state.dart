import '../../../domain/entities/account_deletion.dart';

sealed class DeleteAccountState {
  const DeleteAccountState();
}

final class DeleteAccountInitial extends DeleteAccountState {
  const DeleteAccountInitial();
}

final class DeleteAccountLoading extends DeleteAccountState {
  const DeleteAccountLoading();
}

/// The request is queued for an admin; the session should end now.
final class DeleteAccountRequested extends DeleteAccountState {
  const DeleteAccountRequested();
}

/// Refused (409) for a reason the merchant can fix first.
final class DeleteAccountBlocked extends DeleteAccountState {
  final DeletionBlockReason reason;

  const DeleteAccountBlocked(this.reason);
}

final class DeleteAccountFailure extends DeleteAccountState {
  final String message;

  const DeleteAccountFailure(this.message);
}
