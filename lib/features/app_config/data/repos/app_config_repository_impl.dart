import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../../../core/services/local_storage/app_shared_preferences.dart';
import '../../domain/entities/app_config.dart';
import '../../domain/repos/app_config_repository.dart';
import '../datasources/app_config_remote_data_source.dart';
import '../models/app_config_model.dart';

class AppConfigRepositoryImpl implements AppConfigRepository {
  final AppConfigRemoteDataSource _remote;
  final AppSharedPreferences _preferences;

  const AppConfigRepositoryImpl({
    required AppConfigRemoteDataSource remote,
    required AppSharedPreferences preferences,
  }) : _remote = remote,
       _preferences = preferences;

  @override
  AppConfig cachedConfig() {
    try {
      final Map<String, dynamic>? raw = _preferences.getAppConfig();
      return raw == null ? AppConfig.empty : AppConfigModel.fromJson(raw);
    } on AppException {
      // A cache written by an older build: ignore it until the next fetch.
      return AppConfig.empty;
    }
  }

  @override
  Future<Either<Failure, AppConfig>> fetchConfig() =>
      guardFailure<AppConfig>(() async {
        final Map<String, dynamic> raw = await _remote.getConfig();
        // Parse first, so a malformed body never replaces a good cache.
        final AppConfig config = AppConfigModel.fromJson(raw);
        await _preferences.saveAppConfig(raw);
        return config;
      });
}
