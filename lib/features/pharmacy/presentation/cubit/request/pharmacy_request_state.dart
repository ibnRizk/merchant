import 'dart:typed_data';

import '../../../domain/entities/pharmacy_request.dart';

sealed class PharmacyRequestState {
  const PharmacyRequestState();
}

final class PharmacyRequestLoading extends PharmacyRequestState {
  const PharmacyRequestLoading();
}

final class PharmacyRequestLoadFailure extends PharmacyRequestState {
  final String message;

  const PharmacyRequestLoadFailure(this.message);
}

/// Loading the prescription image is separate from the request: a failed
/// image must not hide the request or block quoting.
enum PrescriptionStatus { none, loading, loaded, failed }

final class PharmacyRequestLoaded extends PharmacyRequestState {
  final PharmacyRequest request;
  final PrescriptionStatus prescriptionStatus;
  final Uint8List? prescription;

  /// A quote is in flight.
  final bool isSending;

  /// Describes only the emit it came with (see [PharmacyNotice]).
  final PharmacyNotice? notice;

  const PharmacyRequestLoaded({
    required this.request,
    this.prescriptionStatus = PrescriptionStatus.none,
    this.prescription,
    this.isSending = false,
    this.notice,
  });

  /// [notice] is not carried over.
  PharmacyRequestLoaded copyWith({
    PharmacyRequest? request,
    PrescriptionStatus? prescriptionStatus,
    Uint8List? prescription,
    bool? isSending,
    PharmacyNotice? notice,
  }) => PharmacyRequestLoaded(
    request: request ?? this.request,
    prescriptionStatus: prescriptionStatus ?? this.prescriptionStatus,
    prescription: prescription ?? this.prescription,
    isSending: isSending ?? this.isSending,
    notice: notice,
  );
}

/// A one-off outcome for the UI to announce. Never const, so a listener
/// can tell a fresh notice apart with `identical`.
sealed class PharmacyNotice {
  const PharmacyNotice();
}

final class QuoteSentNotice extends PharmacyNotice {
  // Not const: each notice must be a distinct instance.
  QuoteSentNotice();
}

final class QuoteInvalidNotice extends PharmacyNotice {
  final PharmacyQuoteError error;

  QuoteInvalidNotice(this.error);
}

/// The request moved on (the customer accepted, rejected or cancelled)
/// since it was loaded; it is reloaded.
final class RequestNotActionableNotice extends PharmacyNotice {
  RequestNotActionableNotice();
}

final class PharmacyFailureNotice extends PharmacyNotice {
  final String message;

  PharmacyFailureNotice(this.message);
}
