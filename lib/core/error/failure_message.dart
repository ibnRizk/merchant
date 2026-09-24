import '../utils/values/strings.dart';
import 'failures.dart';

extension FailureMessage on Failure {
  /// Server-provided reason when there is one, otherwise a generic message.
  String get displayMessage {
    final String? text = message?.trim();
    return (text == null || text.isEmpty) ? Strings.somethingWentWrong : text;
  }
}
