import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:divine_manager/features/order/model/order.dart';
import 'package:flutter/material.dart';

class OrderListCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const OrderListCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = order.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final timeString =
        '${order.timestamp.hour}:${order.timestamp.minute.toString().padLeft(2, '0')}';

    final isDarkMode = Theme.brightnessOf(context) == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.cardColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppTheme.primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: AppTheme.primaryColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryColor),
                    ),
                    child: Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(timeString, style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  PopupMenuButton(
                    color: isDarkMode
                        ? AppTheme.darkBackgroundColor
                        : AppTheme.cardColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: const [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 16,
                              color: AppTheme.errorColor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: AppTheme.errorColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        onUpdate();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shopping_bag, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$itemCount items',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              order.paymentMethod == 'Cash'
                                  ? Icons.money
                                  : Icons.payment,
                              size: 16,
                              color: order.paymentMethod == 'Cash'
                                  ? AppTheme.primaryGreen
                                  : AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.paymentMethod,
                              style: TextStyle(
                                color: order.paymentMethod == 'Cash'
                                    ? AppTheme.primaryGreen
                                    : AppTheme.primaryBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${order.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                _getItemsPreview(),
                style: TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (order.status.toLowerCase()) {
      case 'completed':
        return AppTheme.primaryGreen;
      case 'pending':
        return AppTheme.primaryOrange;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  String _getItemsPreview() {
    if (order.items.isEmpty) return 'No items';

    final itemNames = order.items
        .take(3)
        .map((item) => '${item.item.name} (${item.quantity})')
        .toList();

    if (order.items.length > 3) {
      itemNames.add('...');
    }

    return itemNames.join(', ');
  }
}
