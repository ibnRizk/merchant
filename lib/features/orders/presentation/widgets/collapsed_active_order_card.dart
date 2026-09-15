import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// Compact active-order row: order id + plain status label on top, a
/// store/time subtitle underneath. Used for active orders that don't need
/// the full detail card on screen.
class CollapsedActiveOrderCard extends StatelessWidget {
  const CollapsedActiveOrderCard({
    super.key,
    required this.orderId,
    required this.statusLabel,
    required this.subtitle,
    this.onTap,
  });

  final String orderId;
  final String statusLabel;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEFF1F4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      orderId,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: BrandColors.navy,
                      ),
                    ),
                  ),
                  Text(
                    statusLabel,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: BrandColors.textGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
