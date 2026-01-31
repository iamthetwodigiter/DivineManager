import 'package:divine_manager/core/services/util_service.dart';
import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:divine_manager/features/order/model/order.dart';
import 'package:divine_manager/features/order/view/widgets/order_detail_dialog.dart';
import 'package:flutter/material.dart';

class PreviousOrderCard extends StatelessWidget {
  final Order order;
  final Function(Order)? onUpdate;
  final VoidCallback? onRefresh;

  const PreviousOrderCard({
    super.key,
    required this.order,
    this.onUpdate,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.brightnessOf(context) == Brightness.dark;
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
                  border: Border.all(color: AppTheme.primaryGreen),
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
                            fontSize: 10,
                          ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total Amount: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        order.paymentMethod == 'Cash'
                            ? Icons.money
                            : order.paymentMethod == 'UPI'
                            ? Icons.payment
                            : Icons.pending_actions,
                        size: 14,
                        color: order.paymentMethod == 'Cash'
                            ? AppTheme.primaryGreen
                            : order.paymentMethod == 'UPI'
                            ? AppTheme.primaryBlue
                            : AppTheme.primaryOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${order.paymentMethod} • ${order.status}',
                        style: TextStyle(
                          fontSize: 10,
                          color: order.paymentMethod == 'Cash'
                              ? AppTheme.primaryGreen
                              : order.paymentMethod == 'UPI'
                              ? AppTheme.primaryBlue
                              : AppTheme.primaryOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  if (order.paymentMethod == 'Pending' ||
                      order.status == 'pending')
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              _showPaymentDialog(context, 'Cash', isDarkMode),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppTheme.primaryGreen,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.money,
                                  size: 12,
                                  color: AppTheme.primaryGreen,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Cash',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () =>
                              _showPaymentDialog(context, 'UPI', isDarkMode),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppTheme.primaryBlue,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.payment,
                                  size: 12,
                                  color: AppTheme.primaryBlue,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'UPI',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _showOrderDetail(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit,
                            size: 12,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Update',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    String paymentMethod,
    bool isDarkMode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode
            ? AppTheme.darkBackgroundColor
            : AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Payment',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text('Mark this order as paid via $paymentMethod?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final updatedOrder = order.copyWith(
                paymentMethod: paymentMethod,
                status: 'completed',
              );
              if (onUpdate != null) {
                onUpdate!(updatedOrder);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: paymentMethod == 'Cash'
                  ? AppTheme.primaryGreen
                  : AppTheme.primaryBlue,
              foregroundColor: AppTheme.cardColor,
            ),
            child: Text('Confirm $paymentMethod'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailDialog(
        order: order,
        isEdit: true,
        onUpdate: (updatedOrder) {
          if (onUpdate != null) {
            onUpdate!(updatedOrder);
          }
          if (onRefresh != null) {
            onRefresh!();
          }
        },
      ),
    );
  }
}
