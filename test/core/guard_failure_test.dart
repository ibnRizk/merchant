import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/core/error/guard_failure.dart';

void main() {
  Future<Failure?> failureOf(Future<Object?> Function() action) async =>
      (await guardFailure(action)).fold((Failure f) => f, (_) => null);

  test('an unexpected error carries no raw text', () async {
    final Failure? failure = await failureOf(
      () async => throw const FormatException('Unexpected character <html>'),
    );

    expect(failure, isA<UnexpectedResponseFailure>());
    expect(failure?.message, isNull);
  });

  test('an unreadable response maps to UnexpectedResponseFailure', () async {
    final Failure? failure = await failureOf(
      () async => throw const UnexpectedResponseException(),
    );

    expect(failure, isA<UnexpectedResponseFailure>());
  });

  test('a server error keeps the server message', () async {
    final Failure? failure = await failureOf(
      () async => throw const ServerException(message: 'Store is closed.'),
    );

    expect(failure, const ServerFailure(message: 'Store is closed.'));
  });
}
