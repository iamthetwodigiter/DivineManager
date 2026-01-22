import 'package:divine_manager/core/services/hive_service.dart';
import 'package:divine_manager/features/inventory/model/inventory_item.dart';

class InventoryService {
  Future<List<InventoryItem>> getAllInventoryItems() async {
    final box = HiveService.inventoryBox;
    return box.values.toList();
  }

  Future<void> addInventoryItem(InventoryItem item) async {
    final box = HiveService.inventoryBox;
    await box.add(item);
  }

  Future<void> updateInventoryItem(int index, InventoryItem updatedItem) async {
    final box = HiveService.inventoryBox;
    await box.putAt(index, updatedItem);
  }

  Future<void> deleteInventoryItem(int index) async {
    final box = HiveService.inventoryBox;
    await box.deleteAt(index);
  }

  Future<InventoryItem?> getInventoryItemByName(String name) async {
    final box = HiveService.inventoryBox;
    return box.values.firstWhere(
      (item) => item.name.toLowerCase() == name.toLowerCase(),
      orElse: () => throw Exception('Item not found'),
    );
  }

  Future<void> updateItemStock(String itemName, double newStock) async {
    final box = HiveService.inventoryBox;
    final items = box.values.toList();

    for (int i = 0; i < items.length; i++) {
      if (items[i].name == itemName) {
        final updatedItem = items[i].copyWith(
          currentStock: newStock,
          lastUpdated: DateTime.now(),
        );
        await box.putAt(i, updatedItem);
        break;
      }
    }
  }

  Future<List<InventoryItem>> getLowStockItems() async {
    final items = await getAllInventoryItems();
    return items.where((item) => item.isLowStock).toList();
  }

  Future<List<InventoryItem>> getOutOfStockItems() async {
    final items = await getAllInventoryItems();
    return items.where((item) => item.isOutOfStock).toList();
  }

  Future<List<InventoryItem>> getExpiringItems() async {
    final items = await getAllInventoryItems();
    return items.where((item) => item.isExpiring).toList();
  }

  Future<List<InventoryItem>> getItemsByCategory(
    InventoryCategory category,
  ) async {
    final items = await getAllInventoryItems();
    return items.where((item) => item.category == category).toList();
  }

  Future<double> getTotalInventoryValue() async {
    final items = await getAllInventoryItems();
    return items.fold<double>(
      0.0,
      (total, item) => total + (item.currentStock * item.pricePerUnit),
    );
  }
}