import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:divine_manager/features/order/model/order.dart';
import 'package:flutter/material.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItem orderItem;
  final VoidCallback removeItemFromOrder;
  const OrderItemCard({
    super.key,
    required this.orderItem,
    required this.removeItemFromOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                orderItem.item.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.fastfood_rounded,
                    color: AppTheme.primaryColor,
                    size: 12,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: orderItem.item.isNonVeg
                  ? AppTheme.nonVegColor
                  : AppTheme.vegColor,
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  orderItem.item.name,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  '₹${orderItem.item.price}/item',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          Text(
            '₹${(orderItem.item.price * orderItem.quantity).toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),

          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${orderItem.quantity}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 8),

          InkWell(
            onTap: removeItemFromOrder,
            child: Icon(Icons.close, color: AppTheme.primaryColor, size: 16),
          ),
        ],
      ),
    );
  }
}
