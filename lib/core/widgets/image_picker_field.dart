import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/values/app_colors.dart';
import '../utils/values/strings.dart';
import 'brand_snack_bar.dart';
import 'labeled_field.dart';

/// Labeled tile that picks an image from the gallery and previews it.
/// Reports the picked file's local path through [onChanged].
///
/// Shows, in order of preference: the newly picked [path], the already
/// uploaded [imageUrl], or a placeholder.
class ImagePickerField extends StatelessWidget {
  const ImagePickerField({
    super.key,
    required this.label,
    required this.path,
    required this.onChanged,
    this.imageUrl,
    this.errorText,
    this.height = 132,
  });

  static final ImagePicker _picker = ImagePicker();

  final String label;
  final String? path;
  final ValueChanged<String> onChanged;
  final String? imageUrl;
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
    final String? currentUrl = imageUrl;
    final Widget placeholder = _Placeholder(colors: colors);
    final int cacheHeight = (height * 3).round();

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
                child: currentPath != null
                    ? Image.file(
                        File(currentPath),
                        fit: BoxFit.cover,
                        cacheHeight: cacheHeight,
                      )
                    : currentUrl != null
                    ? CachedNetworkImage(
                        imageUrl: currentUrl,
                        fit: BoxFit.cover,
                        memCacheHeight: cacheHeight,
                        placeholder: (_, __) => placeholder,
                        errorWidget: (_, __, ___) => placeholder,
                      )
                    : placeholder,
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
