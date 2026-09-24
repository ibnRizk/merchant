import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/enums.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';

/// Each language's name in its own script. Deliberately not translated, so
/// a merchant who switched by mistake can still find their language.
String nativeLanguageName(LanguageCode code) => switch (code) {
  LanguageCode.ar => 'العربية',
  LanguageCode.en => 'English',
};

/// Rounded language picker. [onSelected] fires only for a different language,
/// after the sheet has started closing.
Future<void> showLanguageBottomSheet(
  BuildContext context, {
  required LanguageCode current,
  required ValueChanged<LanguageCode> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    useSafeArea: true,
    builder: (BuildContext sheetContext) => _LanguageSheet(
      current: current,
      onSelected: (LanguageCode code) {
        Navigator.of(sheetContext).pop();
        if (code != current) onSelected(code);
      },
    ),
  );
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.current, required this.onSelected});

  final LanguageCode current;
  final ValueChanged<LanguageCode> onSelected;

  static const List<LanguageCode> _order = <LanguageCode>[
    LanguageCode.ar,
    LanguageCode.en,
  ];

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.translate_rounded,
                      size: 22,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          Strings.language,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          Strings.chooseAppLanguage,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              for (final LanguageCode code in _order) ...<Widget>[
                _LanguageOption(
                  code: code,
                  isSelected: code == current,
                  onTap: () => onSelected(code),
                ),
                if (code != _order.last) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  final LanguageCode code;
  final bool isSelected;
  final VoidCallback onTap;

  static const Duration _duration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final Color onPrimary = Theme.of(context).colorScheme.onPrimary;
    final String localizedName = switch (code) {
      LanguageCode.ar => Strings.arabic,
      LanguageCode.en => Strings.english,
    };

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: _duration,
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? colors.primaryLight : colors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? colors.primary : colors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                AnimatedContainer(
                  duration: _duration,
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colors.primary : colors.surface,
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.border,
                    ),
                  ),
                  child: Text(
                    switch (code) {
                      LanguageCode.ar => 'ع',
                      LanguageCode.en => 'En',
                    },
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? onPrimary : colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        nativeLanguageName(code),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        localizedName,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.5,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: _duration,
                  transitionBuilder: (Widget child, Animation<double> anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey<bool>(true),
                          size: 24,
                          color: colors.primary,
                        )
                      : Icon(
                          Icons.radio_button_unchecked_rounded,
                          key: const ValueKey<bool>(false),
                          size: 24,
                          color: colors.border,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
