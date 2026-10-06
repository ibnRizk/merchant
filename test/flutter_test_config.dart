import 'dart:async';

import 'helpers/test_localizations.dart';

/// Runs before every test file. Some messages (e.g.
/// `ServerException.unexpectedResponse()`) are localized where they are
/// thrown, so `Strings.*` must resolve in plain unit tests too.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await registerTestLocalizations();
  await testMain();
}
