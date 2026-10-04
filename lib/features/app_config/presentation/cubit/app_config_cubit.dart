import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_config.dart';
import '../../domain/repos/app_config_repository.dart';

/// App-wide config, provided above the router. Starts from the cached copy
/// and is refreshed whenever a session reaches the home screen.
class AppConfigCubit extends Cubit<AppConfig> {
  final AppConfigRepository _repository;
  bool _isRefreshing = false;

  AppConfigCubit({required AppConfigRepository repository})
    : _repository = repository,
      super(repository.cachedConfig());

  /// Needs a token: call it only once logged in, or the 401 would log the
  /// user out. A failure keeps the current config; it is not worth an error
  /// on screen.
  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    final result = await _repository.fetchConfig();
    _isRefreshing = false;
    if (isClosed) return;
    result.fold((_) {}, emit);
  }
}

extension AppConfigContext on BuildContext {
  /// The currency label, rebuilding the caller when the config changes.
  /// Call it from `build` only.
  String get currency =>
      select<AppConfigCubit, String>((AppConfigCubit c) => c.state.currency);
}
