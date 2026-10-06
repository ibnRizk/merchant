import '../utils/values/strings.dart';
import 'failures.dart';

extension FailureMessage on Failure {
  /// Server-provided reason when there is one, otherwise a generic message.
  String get displayMessage {
    if (this is UnexpectedResponseFailure) return Strings.unexpectedResponse;
    final String? text = message?.trim();
    return (text == null || text.isEmpty) ? Strings.somethingWentWrong : text;
  }
}
