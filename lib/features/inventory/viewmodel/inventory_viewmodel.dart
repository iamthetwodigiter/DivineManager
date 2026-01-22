import 'package:divine_manager/features/inventory/model/inventory_item.dart';
import 'package:divine_manager/features/inventory/services/inventory_service.dart';

class InventoryViewModel {
  final InventoryService _inventoryService;
  InventoryViewModel(this._inventoryService);

  Future<List<InventoryItem>> loadAllInventoryItems() async {
    return await _inventoryService.getAllInventoryItems();
  }

  Future<void> addNewInventoryItem(InventoryItem item) async {
    final validationError = validateInventoryItem(item);
    if (validationError != null) {
      throw Exception(validationError);
    }
    await _inventoryService.addInventoryItem(item);
  }

  Future<void> updateExistingInventoryItem(int index, InventoryItem updatedItem) async {
    final validationError = validateInventoryItem(updatedItem);
    if (validationError != null) {
      throw Exception(validationError);
    }
    await _inventoryService.updateInventoryItem(index, updatedItem);
  }

  Future<void> removeInventoryItem(int index) async {
    await _inventoryService.deleteInventoryItem(index);
  }

  Future<void> updateItemStock(String itemName, double newStock) async {
    if (newStock < 0) {
      throw Exception('Stock cannot be negative');
    }
    await _inventoryService.updateItemStock(itemName, newStock);
  }

  Future<List<InventoryItem>> getLowStockItems() async {
    return await _inventoryService.getLowStockItems();
  }

  Future<double> getTotalInventoryValue() async {
    return await _inventoryService.getTotalInventoryValue();
  }


  List<InventoryItem> filterItemsByCategory(
    List<InventoryItem> items,
    InventoryCategory? category,
  ) {
    if (category == null) return items;
    return items.where((item) => item.category == category).toList();
  }

  List<InventoryItem> searchItemsByName(
    List<InventoryItem> items,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return items;
    return items
        .where((item) => 
            item.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  List<InventoryItem> getItemsByStockStatus(
    List<InventoryItem> items,
    InventoryStockStatus status,
  ) {
    switch (status) {
      case InventoryStockStatus.lowStock:
        return items.where((item) => item.isLowStock).toList();
      case InventoryStockStatus.outOfStock:
        return items.where((item) => item.isOutOfStock).toList();
      case InventoryStockStatus.expiring:
        return items.where((item) => item.isExpiring).toList();
      case InventoryStockStatus.all:
        return items;
    }
  }

  List<InventoryItem> sortItemsByField(
    List<InventoryItem> items,
    InventorySortField field,
    bool ascending,
  ) {
    final sortedItems = List<InventoryItem>.from(items);
    
    switch (field) {
      case InventorySortField.name:
        sortedItems.sort((a, b) => ascending 
            ? a.name.compareTo(b.name) 
            : b.name.compareTo(a.name));
        break;
      case InventorySortField.stock:
        sortedItems.sort((a, b) => ascending 
            ? a.currentStock.compareTo(b.currentStock) 
            : b.currentStock.compareTo(a.currentStock));
        break;
      case InventorySortField.price:
        sortedItems.sort((a, b) => ascending 
            ? a.pricePerUnit.compareTo(b.pricePerUnit) 
            : b.pricePerUnit.compareTo(a.pricePerUnit));
        break;
      case InventorySortField.category:
        sortedItems.sort((a, b) => ascending 
            ? a.category.name.compareTo(b.category.name) 
            : b.category.name.compareTo(a.category.name));
        break;
      case InventorySortField.lastUpdated:
        sortedItems.sort((a, b) => ascending 
            ? a.lastUpdated.compareTo(b.lastUpdated) 
            : b.lastUpdated.compareTo(a.lastUpdated));
        break;
    }
    
    return sortedItems;
  }


  String? validateInventoryItem(InventoryItem item) {
    if (item.name.trim().isEmpty) {
      return 'Item name cannot be empty';
    }
    if (item.currentStock < 0) {
      return 'Current stock cannot be negative';
    }
    if (item.minStockLevel < 0) {
      return 'Minimum stock level cannot be negative';
    }
    if (item.maxStockLevel < item.minStockLevel) {
      return 'Maximum stock level must be greater than minimum stock level';
    }
    if (item.pricePerUnit < 0) {
      return 'Price per unit cannot be negative';
    }
    return null;
  }

  String? validateStockUpdate(double currentStock, double newStock) {
    if (newStock < 0) {
      return 'Stock cannot be negative';
    }
    return null;
  }


  double calculateStockValue(InventoryItem item) {
    return item.currentStock * item.pricePerUnit;
  }

  double calculateStockPercentage(InventoryItem item) {
    if (item.maxStockLevel <= 0) return 0.0;
    return (item.currentStock / item.maxStockLevel) * 100;
  }

  int getDaysUntilExpiry(InventoryItem item) {
    if (item.expiryDate == null) return -1;
    return item.expiryDate!.difference(DateTime.now()).inDays;
  }

  bool shouldReorder(InventoryItem item) {
    return item.currentStock <= item.minStockLevel;
  }

  double calculateReorderQuantity(InventoryItem item) {
    return item.maxStockLevel - item.currentStock;
  }


  Map<InventoryCategory, int> getCategoryDistribution(List<InventoryItem> items) {
    final Map<InventoryCategory, int> distribution = {};
    for (final item in items) {
      distribution[item.category] = (distribution[item.category] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, dynamic> generateInventoryReport(List<InventoryItem> items) {
    final totalItems = items.length;
    final totalValue = items.fold(0.0, (sum, item) => sum + calculateStockValue(item));
    final lowStockItems = items.where((item) => item.isLowStock).length;
    final outOfStockItems = items.where((item) => item.isOutOfStock).length;
    final expiringItems = items.where((item) => item.isExpiring).length;
    
    return {
      'totalItems': totalItems,
      'totalValue': totalValue,
      'lowStockItems': lowStockItems,
      'outOfStockItems': outOfStockItems,
      'expiringItems': expiringItems,
      'categoryDistribution': getCategoryDistribution(items),
    };
  }
}

enum InventoryStockStatus {
  all,
  lowStock,
  outOfStock,
  expiring,
}

enum InventorySortField {
  name,
  stock,
  price,
  category,
  lastUpdated,
}