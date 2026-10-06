import 'package:equatable/equatable.dart';

/// Where a customer's prescription request stands.
enum PharmacyRequestStatus {
  /// New: waiting for the pharmacy's price.
  submitted,

  /// Priced; waiting for the customer to accept or reject.
  quoted,

  /// The customer accepted: it became a COD order.
  converted,
  rejected,
  cancelled,
  unknown;

  static PharmacyRequestStatus fromApi(String? value) =>
      switch (value?.trim().toLowerCase()) {
        'submitted' || 'pending' => submitted,
        'quoted' || 'priced' => quoted,
        'converted' || 'accepted' || 'ordered' => converted,
        'rejected' || 'declined' => rejected,
        'cancelled' || 'canceled' || 'expired' => cancelled,
        _ => unknown,
      };

  /// Only these can be (re-)quoted; anything else gets HTTP 422
  /// `pharmacy_request_not_actionable`.
  bool get canQuote => this == submitted || this == quoted;
}

/// The price a pharmacy sends for a request.
class PharmacyQuote extends Equatable {
  /// Total for the medicines, in the store currency.
  final double amount;

  /// What is included, e.g. "Panadol Extra 24 tablets x 1".
  final String summary;

  /// Optional note to the customer (substitutions, availability...).
  final String note;

  const PharmacyQuote({
    required this.amount,
    required this.summary,
    this.note = '',
  });

  /// Why this quote can't be sent, or `null` when it can.
  PharmacyQuoteError? get validationError {
    if (amount <= 0) return PharmacyQuoteError.invalidAmount;
    if (summary.trim().isEmpty) return PharmacyQuoteError.missingSummary;
    return null;
  }

  @override
  List<Object?> get props => [amount, summary, note];
}

enum PharmacyQuoteError { invalidAmount, missingSummary }

/// A customer's medicine request sent to this pharmacy.
class PharmacyRequest extends Equatable {
  final int id;
  final PharmacyRequestStatus status;
  final String customerName;

  /// What the customer wrote (medicines, dosage...).
  final String customerNote;

  /// A prescription image is attached; fetch it with
  /// `PharmacyRepository.getPrescription`.
  final bool hasPrescription;
  final DateTime? createdAt;

  /// The last price sent, if any.
  final PharmacyQuote? quote;

  const PharmacyRequest({
    required this.id,
    required this.status,
    this.customerName = '',
    this.customerNote = '',
    this.hasPrescription = false,
    this.createdAt,
    this.quote,
  });

  /// This request after [quote] was accepted by the server.
  PharmacyRequest quoted(PharmacyQuote quote) => PharmacyRequest(
    id: id,
    status: PharmacyRequestStatus.quoted,
    customerName: customerName,
    customerNote: customerNote,
    hasPrescription: hasPrescription,
    createdAt: createdAt,
    quote: quote,
  );

  @override
  List<Object?> get props => [
    id,
    status,
    customerName,
    customerNote,
    hasPrescription,
    createdAt,
    quote,
  ];
}
