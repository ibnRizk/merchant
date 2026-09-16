import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// One line item inside [NewOrderDetailCard]: name on the right, price on
/// the left.
class OrderItemRow extends StatelessWidget {
  const OrderItemRow({super.key, required this.name, required this.price});

  final String name;
  final String price;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              name,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
