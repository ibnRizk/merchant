import 'package:flutter/material.dart';

import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/pharmacy_request.dart';
import '../utils/pharmacy_display.dart';

/// One request in the inbox: number, customer, note preview and status.
class PharmacyRequestCard extends StatelessWidget {
  const PharmacyRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  final PharmacyRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final (Color background, Color text) = request.status.pillColors(colors);
    final DateTime? createdAt = request.createdAt;
    final String meta = <String>[
      if (createdAt != null)
        formatRequestTime(
          createdAt,
          Localizations.localeOf(context).languageCode,
        ),
      if (request.customerName.isNotEmpty) request.customerName.bidiIsolated,
    ].join(' · ');

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${Strings.pharmacyRequestPrefix}${'#${request.id}'.ltrIsolated}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  StatusPill(
                    label: request.status.label,
                    background: background,
                    textColor: text,
                  ),
                ],
              ),
              if (meta.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
              if (request.customerNote.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  request.customerNote.bidiIsolated,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: colors.textPrimary,
                  ),
                ),
              ],
              if (request.hasPrescription) ...<Widget>[
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Strings.prescriptionAttached,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
