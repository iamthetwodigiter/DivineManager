import 'package:divine_manager/core/services/util_service.dart';
import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:divine_manager/features/order/model/order.dart';
import 'package:flutter/material.dart';

class PreviousOrderCard extends StatelessWidget {
  final Order order;
  const PreviousOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.primaryGreen)
                ),
                child: Text(
                  'Order #${order.id}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${order.items.length} Items',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                UtilService.formatTimestamp(order.timestamp),
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...order.items.map(
            (orderItem) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.asset(
                      orderItem.item.assetPath,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.fastfood_rounded,
                          color: AppTheme.primaryColor,
                          size: 12,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: orderItem.item.isNonVeg
                          ? AppTheme.nonVegColor
                          : AppTheme.vegColor,
                    ),
                  ),
                  const SizedBox(width: 6),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          orderItem.item.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          '₹${orderItem.item.price}/item × ${orderItem.quantity}',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 10),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '₹${(orderItem.item.price * orderItem.quantity).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.only(top: 6),
            height: 1,
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  Text(
                    ' • ${order.items.fold(0, (sum, item) => sum + item.quantity)} Items',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
              Text(
                '₹${order.totalPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
