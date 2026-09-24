import 'package:flutter/material.dart';

import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../domain/entities/merchant_profile.dart';
import 'profile_avatar_block.dart';
import 'profile_section_card.dart';

/// Editable owner and store fields. The controllers belong to the screen,
/// so edits survive rebuilds and save attempts.
class ProfileForm extends StatelessWidget {
  const ProfileForm({
    super.key,
    required this.formKey,
    required this.profile,
    required this.firstNameController,
    required this.lastNameController,
    required this.storeNameController,
    required this.storePhoneController,
    required this.storeEmailController,
    required this.storeAddressController,
  });

  final GlobalKey<FormState> formKey;
  final MerchantProfile profile;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController storeNameController;
  final TextEditingController storePhoneController;
  final TextEditingController storeEmailController;
  final TextEditingController storeAddressController;

  static String? _required(String? value) =>
      Validator.call(value: value ?? '', type: ValidatorType.standard);

  static String? _phone(String? value) =>
      Validator.call(value: value ?? '', type: ValidatorType.phone);

  /// Store e-mail is optional, but must be valid when given.
  static String? _optionalEmail(String? value) =>
      (value == null || value.trim().isEmpty)
      ? null
      : Validator.call(value: value.trim(), type: ValidatorType.email);

  @override
  Widget build(BuildContext context) {
    final StoreProfile? store = profile.store;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ProfileAvatarBlock(
            storeName: store?.name ?? profile.fullName,
            subtitle: store == null ? profile.email : profile.fullName,
            logoUrl: store?.logoUrl,
          ),
          const SizedBox(height: 24),
          if (store != null) ...<Widget>[
            ProfileSectionCard(
              title: Strings.storeInfoSection,
              icon: Icons.storefront_outlined,
              children: <Widget>[
                AppFormField(
                  label: Strings.storeNameLabel,
                  controller: storeNameController,
                  validator: _required,
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: Strings.storePhoneLabel,
                  controller: storePhoneController,
                  keyboardType: TextInputType.phone,
                  validator: _phone,
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: Strings.storeEmailLabel,
                  controller: storeEmailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _optionalEmail,
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: Strings.addressLabel,
                  controller: storeAddressController,
                  maxLines: 2,
                  validator: _required,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          ProfileSectionCard(
            title: Strings.ownerInfoSection,
            icon: Icons.person_outline_rounded,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: AppFormField(
                      label: Strings.firstName,
                      controller: firstNameController,
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppFormField(
                      label: Strings.lastName,
                      controller: lastNameController,
                      validator: _required,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
