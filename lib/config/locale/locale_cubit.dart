import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/enums.dart';
import '../../injection_container.dart';

/// Holds the active [LanguageCode] and persists it to SharedPreferences so
/// the choice survives a restart. Mirrors [ThemeCubit].
class LocaleCubit extends Cubit<LanguageCode> {
  LocaleCubit() : super(sharedPreferences.getLanguageCode());

  Locale get locale => Locale(state.name);

  Future<void> setLocale(LanguageCode code) async {
    if (code == state) return;
    await sharedPreferences.saveLanguageCode(code.name);
    emit(code);
  }

  Future<void> toggle() =>
      setLocale(state == LanguageCode.ar ? LanguageCode.en : LanguageCode.ar);
}
