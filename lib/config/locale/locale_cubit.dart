import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/enums.dart';
import '../../injection_container.dart';
import 'app_localizations.dart';

/// Holds the active [LanguageCode] and persists it to SharedPreferences so
/// the choice survives a restart. Mirrors [ThemeCubit].
class LocaleCubit extends Cubit<LanguageCode> {
  LocaleCubit() : super(sharedPreferences.getLanguageCode());

  Locale get locale => Locale(state.name);

  Future<void> setLocale(LanguageCode code) async {
    if (code == state) return;
    await sharedPreferences.saveLanguageCode(code.name);
    // The server localises its messages from `X-localization`; without this
    // the old language sticks until the next app start.
    dioConsumer.updateLanguageCodeHeader();

    // Pre-load the new localizations and update the singleton BEFORE emitting.
    // This ensures that when the UI widgets rebuild synchronously upon emit,
    // the `.tr` extension already serves the new strings, avoiding the race 
    // condition with MaterialApp's async LocalizationsDelegate.
    final AppLocalizations newLoc = AppLocalizations(Locale(code.name));
    await newLoc.load(locale: Locale(code.name));
    ServiceLocator.injectAppLocalizations(newLoc);

    emit(code);
  }

  Future<void> toggle() =>
      setLocale(state == LanguageCode.ar ? LanguageCode.en : LanguageCode.ar);
}
