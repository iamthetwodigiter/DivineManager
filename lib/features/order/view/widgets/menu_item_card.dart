import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:divine_manager/features/order/model/menu_items.dart';
import 'package:flutter/material.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItems item;
  final Color typeColor;
  final IconData typeIcon;
  final String typeName;
  final VoidCallback showEditItemDialog;
  final VoidCallback showDeleteConfirmDialog;
  const MenuItemCard({
    super.key,
    required this.item,
    required this.typeColor,
    required this.typeIcon,
    required this.typeName,
    required this.showEditItemDialog,
    required this.showDeleteConfirmDialog,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.brightnessOf(context) == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
        boxShadow: !isDarkMode
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: typeColor.withValues(alpha: 0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(typeIcon, color: typeColor, size: 24);
              },
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item.isNonVeg ? AppTheme.nonVegColor : AppTheme.vegColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isNonVeg
                      ? AppTheme.nonVegColor
                      : AppTheme.vegColor,
                  width: 1,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    typeName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${item.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: showEditItemDialog,
              icon: Icon(
                Icons.edit_rounded,
                color: AppTheme.primaryOrange,
                size: 20,
              ),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: showDeleteConfirmDialog,
              icon: Icon(
                Icons.delete_rounded,
                color: AppTheme.primaryRed,
                size: 20,
              ),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
