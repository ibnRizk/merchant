import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/price_format.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_toggle.dart';
import '../../../app_config/presentation/cubit/app_config_cubit.dart';
import '../../domain/entities/product.dart';

/// One row in the menu list: photo, name/category/price, the availability
/// switch and a kebab menu. Tapping the card opens the product for editing.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isBusy,
    required this.onTap,
    required this.onAvailabilityChanged,
    required this.onMoreTap,
  });

  final Product product;

  /// A status change or delete is in flight: controls are locked.
  final bool isBusy;
  final VoidCallback onTap;
  final ValueChanged<bool> onAvailabilityChanged;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final String? categoryName = product.category?.name;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isBusy ? 0.6 : 1,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isBusy ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 4, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: <Widget>[
                _ProductThumbnail(imageUrl: product.imageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (categoryName != null && categoryName.isNotEmpty)
                        Text(
                          categoryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5,
                            color: colors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        formatMoney(product.price, context.currency),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _AvailabilitySwitch(
                  isActive: product.isActive,
                  isBusy: isBusy,
                  onChanged: onAvailabilityChanged,
                ),
                IconButton(
                  onPressed: isBusy ? null : onMoreTap,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.imageUrl});

  final String? imageUrl;

  static const double _size = 64;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final Widget placeholder = ColoredBox(
      color: colors.background,
      child: Icon(
        Icons.fastfood_outlined,
        size: 26,
        color: colors.textSecondary,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox.square(
        dimension: _size,
        child: imageUrl == null
            ? placeholder
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                memCacheHeight: (_size * 3).round(),
                placeholder: (_, __) => placeholder,
                errorWidget: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}

/// "متوفر / غير متوفر" switch, wired straight to the status endpoint.
class _AvailabilitySwitch extends StatelessWidget {
  const _AvailabilitySwitch({
    required this.isActive,
    required this.isBusy,
    required this.onChanged,
  });

  final bool isActive;
  final bool isBusy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return IgnorePointer(
      ignoring: isBusy,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BrandToggle(value: isActive, onChanged: onChanged),
          const SizedBox(height: 4),
          Text(
            isActive ? Strings.available : Strings.unavailable,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isActive ? colors.success : colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
