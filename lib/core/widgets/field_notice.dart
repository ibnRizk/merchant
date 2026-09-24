import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';

/// Field-shaped box that stands in for an input when there is nothing to
/// enter yet: options still loading, failed to load, or none available.
class FieldNotice extends StatelessWidget {
  const FieldNotice({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.text,
    this.trailing,
    this.errorText,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final Widget? trailing;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 8, 8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText == null ? colors.border : colors.error,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 8),
                trailing!,
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, top: 6),
            child: Text(
              errorText!,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: colors.error,
              ),
            ),
          ),
      ],
    );
  }
}
