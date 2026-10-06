import '../../../../core/utils/json_values.dart';
import '../../domain/entities/pharmacy_request.dart';

/// Parses a request from the list, details and quote responses. The docs
/// pin only a few fields, so common spellings are accepted.
class PharmacyRequestModel extends PharmacyRequest {
  const PharmacyRequestModel({
    required super.id,
    required super.status,
    super.customerName,
    super.customerNote,
    super.hasPrescription,
    super.createdAt,
    super.quote,
  });

  factory PharmacyRequestModel.fromJson(Map<String, dynamic> json) {
    final dynamic customer = json['customer'];
    final String customerName = customer is Map
        ? <String>[
            jsonText(customer['f_name']),
            jsonText(customer['l_name']),
          ].where((String part) => part.isNotEmpty).join(' ')
        : jsonText(json['customer_name']);
    final double? amount = double.tryParse('${json['medicine_amount']}');

    return PharmacyRequestModel(
      id: jsonInt(json['id']),
      status: PharmacyRequestStatus.fromApi(jsonText(json['status'])),
      customerName: customerName,
      customerNote: <String>[
        jsonText(json['customer_note']),
        jsonText(json['note']),
        jsonText(json['description']),
      ].firstWhere((String note) => note.isNotEmpty, orElse: () => ''),
      hasPrescription: isTruthy(json['has_prescription']),
      createdAt: DateTime.tryParse(jsonText(json['created_at']))?.toLocal(),
      quote: amount == null
          ? null
          : PharmacyQuote(
              amount: amount,
              summary: jsonText(json['medicine_summary']),
              note: jsonText(json['pharmacy_note']),
            ),
    );
  }
}

/// `{pharmacy_requests: [...]}` (paged with `total_size`), or a bare list.
List<PharmacyRequest> parsePharmacyRequests(dynamic response) =>
    <PharmacyRequest>[
      for (final Map<String, dynamic> item in jsonMaps(
        response is Map ? response['pharmacy_requests'] : response,
      ))
        PharmacyRequestModel.fromJson(item),
    ];

extension PharmacyQuoteRequest on PharmacyQuote {
  Map<String, dynamic> toJson() => <String, dynamic>{
    'medicine_amount': amount,
    'medicine_summary': summary.trim(),
    if (note.trim().isNotEmpty) 'pharmacy_note': note.trim(),
  };
}
