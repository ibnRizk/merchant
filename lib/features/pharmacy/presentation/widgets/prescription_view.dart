import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../cubit/request/pharmacy_request_cubit.dart';

/// The prescription image, with loading and retry states. Tapping the
/// image opens it full screen with pinch-zoom.
class PrescriptionView extends StatelessWidget {
  const PrescriptionView({
    super.key,
    required this.status,
    required this.bytes,
    required this.onRetry,
  });

  final PrescriptionStatus status;
  final Uint8List? bytes;
  final VoidCallback onRetry;

  void _openFull(BuildContext context, Uint8List image) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            body: InteractiveViewer(
              maxScale: 5,
              child: Center(child: Image.memory(image)),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final Uint8List? image = bytes;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 220,
        color: colors.background,
        alignment: Alignment.center,
        child: switch (status) {
          PrescriptionStatus.loaded when image != null => GestureDetector(
            onTap: () => _openFull(context, image),
            child: Image.memory(
              image,
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (_, __, ___) => _Retry(onRetry: onRetry),
            ),
          ),
          PrescriptionStatus.failed ||
          PrescriptionStatus.loaded => _Retry(onRetry: onRetry),
          PrescriptionStatus.none || PrescriptionStatus.loading =>
            CircularProgressIndicator(color: colors.primary),
        },
      ),
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.broken_image_outlined, color: colors.textSecondary),
        const SizedBox(height: 6),
        Text(
          Strings.prescriptionLoadFailed,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.5,
            color: colors.textSecondary,
          ),
        ),
        TextButton(onPressed: onRetry, child: Text(Strings.retry)),
      ],
    );
  }
}
