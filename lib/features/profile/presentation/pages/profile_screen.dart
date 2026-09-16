import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../config/themes/theme_cubit.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/free_trial_banner.dart';
import '../../../../core/widgets/title_action_header.dart';
import '../widgets/language_toggle_row.dart';
import '../widgets/profile_address_field.dart';
import '../widgets/profile_avatar_block.dart';
import '../widgets/profile_dropdown_field.dart';
import '../widgets/theme_toggle_row.dart';

/// Profile tab body — composed from small widgets under
/// `presentation/widgets/`. Rendered inside [MainScaffold]; the bottom nav
/// bar and RTL directionality are provided by the parent scaffold.
///
/// Every UI label/message here comes from `Strings`/`.tr` (backed by
/// `lang/ar.json` + `lang/en.json`) so the screen re-renders correctly for
/// either language. The sample data in the controllers below (store name,
/// description, phone, address) is deliberately left as-is — it stands in
/// for content a real backend would return, not UI chrome, so it isn't
/// translated.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Stable, locale-independent values mapped to their localized labels.
  /// Keeping these separate means the selected category stays matched after
  /// a language switch, instead of losing its selection because the display
  /// text (and therefore the dropdown's value) changed underneath it.
  static const List<String> _categoryValues = <String>[
    'restaurants',
    'cafes',
    'sweets',
    'grocery',
  ];

  static String _categoryLabel(String value) {
    switch (value) {
      case 'restaurants':
        return Strings.categoryRestaurants;
      case 'cafes':
        return Strings.categoryCafes;
      case 'sweets':
        return Strings.categorySweets;
      default:
        return Strings.categoryGrocery;
    }
  }

  final TextEditingController _nameController = TextEditingController(
    text: 'مطاعم مذاق',
  );
  final TextEditingController _descriptionController = TextEditingController(
    text: 'وجبات برجر طازجة، بطاطس مقرمشة ومشروبات تناسب كل أفراد العائلة.',
  );
  final TextEditingController _contactController = TextEditingController(
    text: '05X XXX XXXX',
  );

  String _category = 'restaurants';
  final String _address = 'حي الملك فهد - محافظة نبرة';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LanguageCode languageCode = context.watch<LocaleCubit>().state;
    final Themes theme = context.watch<ThemeCubit>().state;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TitleActionHeader(
              title: Strings.profileTitle,
              actionLabel: Strings.save,
              onActionTap: () =>
                  showBrandSnackBar(context, Strings.profileSavedSuccess),
            ),
            const SizedBox(height: 20),
            ProfileAvatarBlock(
              storeName: _nameController.text,
              subtitle: '${_categoryLabel(_category)} - نبرة',
            ),
            const SizedBox(height: 24),
            AppFormField(
              label: Strings.storeNameLabel,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            ProfileDropdownField(
              label: Strings.categoryLabel,
              value: _category,
              options: <String, String>{
                for (final String value in _categoryValues)
                  value: _categoryLabel(value),
              },
              onChanged: (String? value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: Strings.storeDescriptionLabel,
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: Strings.contactNumberLabel,
              controller: _contactController,
              keyboardType: TextInputType.phone,
              valueColor: context.colors.primary,
            ),
            const SizedBox(height: 16),
            ProfileAddressField(
              label: Strings.addressLabel,
              address: _address,
              onTap: () =>
                  showBrandSnackBar(context, Strings.mapPickerComingSoon),
            ),
            const SizedBox(height: 16),
            ThemeToggleRow(
              theme: theme,
              onChanged: (Themes value) =>
                  context.read<ThemeCubit>().setTheme(value),
            ),
            const SizedBox(height: 12),
            LanguageToggleRow(
              languageCode: languageCode,
              onChanged: (LanguageCode code) =>
                  context.read<LocaleCubit>().setLocale(code),
            ),
            const SizedBox(height: 20),
            FreeTrialBanner(text: Strings.freeTrialBanner),
          ],
        ),
      ),
    );
  }
}
