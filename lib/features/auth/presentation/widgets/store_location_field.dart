import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../pages/location_picker_screen.dart';

/// Read-only tile that shows the picked coordinates; tapping it opens the
/// map picker through [onTap].
class StoreLocationField extends StatelessWidget {
  const StoreLocationField({
    super.key,
    required this.location,
    required this.onTap,
    this.errorText,
  });

  final LatLng? location;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final LatLng? picked = location;
    return LabeledField(
      label: Strings.storeLocationSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: errorText == null ? colors.border : colors.error,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.map_outlined, color: colors.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        picked == null
                            ? Strings.pickStoreLocation
                            : formatLatLng(picked),
                        textDirection: picked == null
                            ? null
                            : TextDirection.ltr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: picked == null
                              ? colors.textSecondary
                              : colors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (errorText != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              errorText!,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: colors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
