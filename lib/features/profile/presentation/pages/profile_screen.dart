import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/free_trial_banner.dart';
import '../../../../core/widgets/title_action_header.dart';
import '../widgets/profile_address_field.dart';
import '../widgets/profile_avatar_block.dart';
import '../widgets/profile_dropdown_field.dart';

/// Profile tab body — composed from small widgets under
/// `presentation/widgets/`. Rendered inside [MainScaffold]; the bottom nav
/// bar and RTL directionality are provided by the parent scaffold.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const List<String> _categories = <String>['مطاعم', 'مقاهي', 'حلويات', 'بقالة'];

  final TextEditingController _nameController =
      TextEditingController(text: 'مطاعم مذاق');
  final TextEditingController _descriptionController = TextEditingController(
    text: 'وجبات برجر طازجة، بطاطس مقرمشة ومشروبات تناسب كل أفراد العائلة.',
  );
  final TextEditingController _contactController =
      TextEditingController(text: '05X XXX XXXX');

  String _category = 'مطاعم';
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
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TitleActionHeader(
              title: 'الملف الشخصي',
              actionLabel: 'حفظ',
              onActionTap: () {},
            ),
            const SizedBox(height: 20),
            const ProfileAvatarBlock(
              storeName: 'مطاعم مذاق',
              subtitle: 'مطاعم - نبرة',
            ),
            const SizedBox(height: 24),
            AppFormField(label: 'اسم المتجر', controller: _nameController),
            const SizedBox(height: 16),
            ProfileDropdownField(
              label: 'القسم',
              value: _category,
              items: _categories,
              onChanged: (String? value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'وصف المتجر',
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'رقم التواصل',
              controller: _contactController,
              keyboardType: TextInputType.phone,
              valueColor: BrandColors.orange,
            ),
            const SizedBox(height: 16),
            ProfileAddressField(
              label: 'العنوان',
              address: _address,
              onTap: () {
                // TODO: launch map picker screen.
              },
            ),
            const SizedBox(height: 20),
            const FreeTrialBanner(
              text: 'المتاجر مجانية بدون رسوم أو عمولة في المرحلة الأولى.',
            ),
          ],
        ),
      ),
    );
  }
}
