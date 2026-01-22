import 'package:divine_manager/core/services/util_service.dart';
import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:divine_manager/features/inventory/model/inventory_item.dart';
import 'package:flutter/material.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback showUpdateStockDialog;
  final VoidCallback showDeleteConfirmDialog;
  final bool isDarkMode;
  const InventoryItemCard({
    super.key,
    required this.item,
    required this.showUpdateStockDialog,
    required this.showDeleteConfirmDialog,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: item.currentStock <= 0
              ? AppTheme.errorColor.withValues(alpha: 0.3)
              : item.currentStock <= item.minStockLevel
              ? AppTheme.primaryOrange.withValues(alpha: 0.3)
              : AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
        boxShadow: !isDarkMode
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset(item.assetPath, height: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.currentStock <= 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'OUT OF STOCK',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.errorColor,
                            ),
                          ),
                        )
                      else if (item.currentStock <= item.minStockLevel)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'LOW STOCK',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${item.pricePerUnit.toStringAsFixed(2)} per ${item.unit.name}',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.currentStock.toStringAsFixed(1)} ${item.unit.name}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: item.currentStock <= 0
                          ? AppTheme.errorColor
                          : item.currentStock <= item.minStockLevel
                          ? AppTheme.primaryOrange
                          : AppTheme.primaryColor,
                    ),
                  ),
                  if (item.expiryDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Expires: ${UtilService.formatExpiryDate(item.expiryDate!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            item.expiryDate!
                                    .difference(DateTime.now())
                                    .inDays <=
                                3
                            ? AppTheme.errorColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: showUpdateStockDialog,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: showDeleteConfirmDialog,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_rounded,
                      color: AppTheme.errorColor,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
