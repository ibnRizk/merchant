import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// One line item inside [NewOrderDetailCard]: name on the right, price on
/// the left.
class OrderItemRow extends StatelessWidget {
  const OrderItemRow({super.key, required this.name, required this.price});

  final String name;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              name,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: BrandColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: BrandColors.textGray,
            ),
          ),
        ],
      ),
    );
  }
}
