import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/themes/theme_cubit.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/free_trial_banner.dart';
import '../../../../core/widgets/title_action_header.dart';
import '../../domain/entities/merchant_profile.dart';
import '../cubit/logout/logout_cubit.dart';
import '../cubit/profile/profile_cubit.dart';
import '../widgets/language_bottom_sheet.dart';
import '../widgets/language_tile.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_form.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_status_views.dart';
import '../widgets/theme_mode_selector.dart';

/// Profile tab body, rendered inside [MainScaffold]. [ProfileCubit] and
/// [LogoutCubit] are provided by the home route.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storePhoneController = TextEditingController();
  final TextEditingController _storeEmailController = TextEditingController();
  final TextEditingController _storeAddressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // The profile may already be loaded if this screen is rebuilt.
    final ProfileState state = context.read<ProfileCubit>().state;
    if (state is ProfileReady) _fillFrom(state.profile);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _storeNameController.dispose();
    _storePhoneController.dispose();
    _storeEmailController.dispose();
    _storeAddressController.dispose();
    super.dispose();
  }

  void _fillFrom(MerchantProfile profile) {
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _storeNameController.text = profile.store?.name ?? '';
    _storePhoneController.text = profile.store?.phone ?? '';
    _storeEmailController.text = profile.store?.email ?? '';
    _storeAddressController.text = profile.store?.address ?? '';
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ProfileCubit>().saveProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      storeName: _storeNameController.text,
      storePhone: _storePhoneController.text,
      storeEmail: _storeEmailController.text,
      storeAddress: _storeAddressController.text,
    );
  }

  Future<void> _logout() async {
    final bool confirmed = await showLogoutConfirmation(context);
    if (!confirmed || !mounted) return;
    context.read<LogoutCubit>().logout();
  }

  void _onProfileState(BuildContext context, ProfileState state) {
    switch (state) {
      case ProfileLoaded(:final profile):
        _fillFrom(profile);
      case ProfileSaved(:final profile):
        _fillFrom(profile);
        showBrandSnackBar(context, Strings.profileSavedSuccess);
      case ProfileUnchanged():
        showBrandSnackBar(context, Strings.profileNoChanges);
      case ProfileSaveFailure(:final message):
        showBrandSnackBar(context, message, isError: true);
      case ProfileInitial() ||
          ProfileLoading() ||
          ProfileLoadFailure() ||
          ProfileSaving():
        break;
    }
  }

  void _onLogoutState(BuildContext context, LogoutState state) {
    switch (state) {
      case LogoutSuccess():
        context.go(AppRoutes.splash);
      case LogoutFailure(:final message):
        showBrandSnackBar(context, message, isError: true);
      case LogoutInitial() || LogoutLoading():
        break;
    }
  }

  /// Save-status changes don't alter the form itself; skip those rebuilds.
  static bool _contentChanged(ProfileState previous, ProfileState current) {
    if (previous is ProfileReady && current is ProfileReady) {
      return previous.profile != current.profile;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Labels come from the global `Strings.*.tr`, so a language switch has
    // to rebuild this screen for them to refresh.
    final LanguageCode languageCode = context.watch<LocaleCubit>().state;

    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<ProfileCubit, ProfileState>(listener: _onProfileState),
        BlocListener<LogoutCubit, LogoutState>(listener: _onLogoutState),
      ],
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BlocSelector<
                ProfileCubit,
                ProfileState,
                ({bool isReady, bool isSaving})
              >(
                selector: (ProfileState state) => (
                  isReady: state is ProfileReady,
                  isSaving: state is ProfileSaving,
                ),
                builder: (_, ({bool isReady, bool isSaving}) status) =>
                    TitleActionHeader(
                      title: Strings.profileTitle,
                      actionLabel: Strings.save,
                      onActionTap: status.isReady ? _save : null,
                      isLoading: status.isSaving,
                    ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<ProfileCubit, ProfileState>(
                buildWhen: _contentChanged,
                builder: (BuildContext context, ProfileState state) =>
                    switch (state) {
                      ProfileInitial() ||
                      ProfileLoading() => const ProfileLoadingView(),
                      ProfileLoadFailure(:final message) => ProfileErrorView(
                        message: message,
                        onRetry: context.read<ProfileCubit>().loadProfile,
                      ),
                      ProfileReady(:final profile) => ProfileForm(
                        formKey: _formKey,
                        profile: profile,
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                        storeNameController: _storeNameController,
                        storePhoneController: _storePhoneController,
                        storeEmailController: _storeEmailController,
                        storeAddressController: _storeAddressController,
                      ),
                    },
              ),
              const SizedBox(height: 16),
              ProfileSectionCard(
                title: Strings.theme,
                icon: Icons.palette_outlined,
                children: <Widget>[
                  BlocBuilder<ThemeCubit, Themes>(
                    builder: (BuildContext context, Themes theme) =>
                        ThemeModeSelector(
                          selected: theme,
                          onChanged: context.read<ThemeCubit>().setTheme,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LanguageTile(
                current: languageCode,
                onTap: () => showLanguageBottomSheet(
                  context,
                  current: languageCode,
                  onSelected: context.read<LocaleCubit>().setLocale,
                ),
              ),
              const SizedBox(height: 20),
              FreeTrialBanner(text: Strings.freeTrialBanner),
              const SizedBox(height: 28),
              BlocSelector<LogoutCubit, LogoutState, bool>(
                // Stay busy after success until the route changes.
                selector: (LogoutState state) =>
                    state is LogoutLoading || state is LogoutSuccess,
                builder: (_, bool isLoading) =>
                    LogoutButton(isLoading: isLoading, onPressed: _logout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
