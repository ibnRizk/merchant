import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/labeled_field.dart';

/// Labeled tile that picks an image from the gallery and previews it.
/// Reports the picked file's local path through [onChanged].
class StoreImagePickerField extends StatelessWidget {
  const StoreImagePickerField({
    super.key,
    required this.label,
    required this.path,
    required this.onChanged,
    this.errorText,
    this.height = 132,
  });

  static final ImagePicker _picker = ImagePicker();

  final String label;
  final String? path;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final double height;

  Future<void> _pick(BuildContext context) async {
    try {
      // Downscaled so uploads stay small and within server size limits.
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (file != null) onChanged(file.path);
    } on PlatformException {
      // Usually denied photo-library access.
      if (context.mounted) {
        showBrandSnackBar(context, Strings.somethingWentWrong, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final String? currentPath = path;
    return LabeledField(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _pick(context),
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: errorText == null ? colors.border : colors.error,
                  ),
                ),
                child: currentPath == null
                    ? _Placeholder(colors: colors)
                    : Image.file(
                        File(currentPath),
                        fit: BoxFit.cover,
                        cacheHeight: (height * 3).round(),
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

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.add_a_photo_outlined, size: 28, color: colors.textSecondary),
        const SizedBox(height: 8),
        Text(
          Strings.tapToChooseImage,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
