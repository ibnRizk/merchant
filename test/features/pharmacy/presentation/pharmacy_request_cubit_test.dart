import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/pharmacy/domain/entities/pharmacy_request.dart';
import 'package:ssm_merchant/features/pharmacy/presentation/cubit/request/pharmacy_request_cubit.dart';

import '../pharmacy_fakes.dart';

void main() {
  late FakePharmacyRepository repository;
  late PharmacyRequestCubit cubit;

  PharmacyRequestLoaded loaded() => cubit.state as PharmacyRequestLoaded;

  setUp(() {
    repository = FakePharmacyRepository();
    cubit = PharmacyRequestCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('load fetches the prescription when there is one', () async {
    repository.requestResult = Right(aRequest(1, hasPrescription: true));

    await cubit.load(1);
    await Future<void>.delayed(Duration.zero);

    expect(loaded().prescriptionStatus, PrescriptionStatus.loaded);
    expect(loaded().prescription, <int>[1, 2, 3]);
  });

  test('a failed prescription keeps the request on screen', () async {
    repository
      ..requestResult = Right(aRequest(1, hasPrescription: true))
      ..prescriptionResult = const Left(ServerFailure());

    await cubit.load(1);
    await Future<void>.delayed(Duration.zero);

    expect(loaded().request.id, 1);
    expect(loaded().prescriptionStatus, PrescriptionStatus.failed);
  });

  test('sending a quote marks the request quoted', () async {
    await cubit.load(1);

    await cubit.sendQuote(aQuote);

    expect(repository.quotes, <PharmacyQuote>[aQuote]);
    expect(loaded().request.status, PharmacyRequestStatus.quoted);
    expect(loaded().notice, isA<QuoteSentNotice>());
    expect(loaded().isSending, isFalse);
  });

  test('an invalid quote is announced and not sent', () async {
    await cubit.load(1);

    await cubit.sendQuote(const PharmacyQuote(amount: 10, summary: ''));

    expect(repository.quotes, isEmpty);
    expect(
      (loaded().notice as QuoteInvalidNotice).error,
      PharmacyQuoteError.missingSummary,
    );
  });

  test('a request that moved on is announced and reloaded', () async {
    await cubit.load(1);
    repository
      ..quoteResult = const Left(ConflictFailure())
      ..requestResult = Right(
        aRequest(1, status: PharmacyRequestStatus.converted),
      );

    await cubit.sendQuote(aQuote);
    expect(loaded().notice, isA<RequestNotActionableNotice>());
    await Future<void>.delayed(Duration.zero);

    expect(repository.requestCalls, 2);
    expect(loaded().request.status, PharmacyRequestStatus.converted);
  });

  test('a closed request is not quoted', () async {
    repository.requestResult = Right(
      aRequest(1, status: PharmacyRequestStatus.rejected),
    );
    await cubit.load(1);

    await cubit.sendQuote(aQuote);

    expect(repository.quotes, isEmpty);
  });
}
