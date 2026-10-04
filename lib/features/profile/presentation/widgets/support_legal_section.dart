import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../app_config/domain/entities/app_config.dart';
import 'profile_section_card.dart';

/// Support contacts and legal links from `/vendor/config`. Renders nothing
/// when the server sent none of them.
class SupportLegalSection extends StatelessWidget {
  const SupportLegalSection({super.key, required this.config});

  final AppConfig config;

  Future<void> _open(BuildContext context, Uri uri) async {
    bool opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // No app can handle the link; reported below.
    }
    if (!opened && context.mounted) {
      showBrandSnackBar(context, Strings.linkOpenFailed, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!config.hasSupport && !config.hasLegal) return const SizedBox.shrink();
    final String whatsappDigits = config.supportWhatsapp.replaceAll(
      RegExp(r'\D'),
      '',
    );

    final List<Widget> tiles = <Widget>[
      if (config.supportPhone.isNotEmpty)
        _LinkTile(
          icon: Icons.call_outlined,
          label: Strings.callSupport,
          value: config.supportPhone,
          onTap: () =>
              _open(context, Uri(scheme: 'tel', path: config.supportPhone)),
        ),
      if (whatsappDigits.isNotEmpty)
        _LinkTile(
          icon: Icons.chat_outlined,
          label: Strings.whatsappSupport,
          value: config.supportWhatsapp,
          onTap: () => _open(context, Uri.https('wa.me', '/$whatsappDigits')),
        ),
      if (config.supportEmail.isNotEmpty)
        _LinkTile(
          icon: Icons.mail_outline_rounded,
          label: Strings.emailSupport,
          value: config.supportEmail,
          onTap: () =>
              _open(context, Uri(scheme: 'mailto', path: config.supportEmail)),
        ),
      if (config.privacyPolicyUrl.isNotEmpty)
        _LinkTile(
          icon: Icons.privacy_tip_outlined,
          label: Strings.privacyPolicy,
          onTap: () => _open(context, Uri.parse(config.privacyPolicyUrl)),
        ),
      if (config.termsUrl.isNotEmpty)
        _LinkTile(
          icon: Icons.description_outlined,
          label: Strings.termsOfService,
          onTap: () => _open(context, Uri.parse(config.termsUrl)),
        ),
    ];

    return ProfileSectionCard(
      title: Strings.helpAndLegal,
      icon: Icons.support_agent_rounded,
      children: <Widget>[
        for (int i = 0; i < tiles.length; i++) ...<Widget>[
          if (i > 0) Divider(height: 1, color: context.colors.border),
          tiles[i],
        ],
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (value != null) ...<Widget>[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            // chevron_right mirrors itself under RTL.
            Icon(Icons.chevron_right, size: 20, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
