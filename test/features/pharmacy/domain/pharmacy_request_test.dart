import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/entities/store_category.dart';
import 'package:ssm_merchant/features/pharmacy/domain/entities/pharmacy_request.dart';

void main() {
  test('only submitted and quoted requests can be priced', () {
    expect(
      <PharmacyRequestStatus>[
        for (final PharmacyRequestStatus s in PharmacyRequestStatus.values)
          if (s.canQuote) s,
      ],
      <PharmacyRequestStatus>[
        PharmacyRequestStatus.submitted,
        PharmacyRequestStatus.quoted,
      ],
    );
  });

  test('a quote needs a positive amount and a summary', () {
    expect(
      const PharmacyQuote(amount: 0, summary: 'x').validationError,
      PharmacyQuoteError.invalidAmount,
    );
    expect(
      const PharmacyQuote(amount: 10, summary: '  ').validationError,
      PharmacyQuoteError.missingSummary,
    );
    expect(
      const PharmacyQuote(amount: 10, summary: 'Panadol').validationError,
      isNull,
    );
  });

  test('a pharmacy store is recognised by slug or English name', () {
    const StoreCategory bySlug = StoreCategory(
      id: 1,
      name: 'صيدلية',
      nameAr: 'صيدلية',
      nameEn: '',
      slug: 'pharmacy',
    );
    const StoreCategory byName = StoreCategory(
      id: 2,
      name: 'Pharmacies',
      nameAr: 'صيدليات',
      nameEn: 'Pharmacies',
    );
    const StoreCategory grocery = StoreCategory(
      id: 3,
      name: 'Grocery',
      nameAr: 'بقالة',
      nameEn: 'Grocery',
    );

    expect(bySlug.isPharmacy, isTrue);
    expect(byName.isPharmacy, isTrue);
    expect(grocery.isPharmacy, isFalse);
  });
}
