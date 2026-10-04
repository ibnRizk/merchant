import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_config.dart';

abstract class AppConfigRepository {
  /// The last config fetched on this device, or [AppConfig.empty]. Never
  /// throws, so the app can show the right currency before the network
  /// answers.
  AppConfig cachedConfig();

  /// `GET /vendor/config` (needs a token). Caches the result on success.
  Future<Either<Failure, AppConfig>> fetchConfig();
}
