import 'package:divine_manager/features/inventory/model/inventory_item.dart';

class InventoryConstants {
  static final List<InventoryItem> inventoryItems = [
    InventoryItem(
      name: 'Coffee Beans',
      category: InventoryCategory.beverageIngredients,
      currentStock: 5.0,
      minStockLevel: 2.0,
      maxStockLevel: 20.0,
      unit: InventoryUnit.kg,
      pricePerUnit: 800.0,
      lastUpdated: DateTime.now(),
      assetPath: 'assets/images/coffee-beans.png',
    ),
    InventoryItem(
      name: 'Tea Leaves',
      category: InventoryCategory.beverageIngredients,
      currentStock: 3.0,
      minStockLevel: 1.0,
      maxStockLevel: 10.0,
      unit: InventoryUnit.kg,
      pricePerUnit: 400.0,
      lastUpdated: DateTime.now(),
      assetPath: 'assets/images/tea-leaves.png',
    ),
    InventoryItem(
      name: 'Milk',
      category: InventoryCategory.beverageIngredients,
      currentStock: 20.0,
      minStockLevel: 5.0,
      maxStockLevel: 50.0,
      unit: InventoryUnit.liters,
      pricePerUnit: 60.0,
      expiryDate: DateTime.now().add(const Duration(days: 3)),
      lastUpdated: DateTime.now(),
      assetPath: 'assets/images/milk.png',
    ),
    InventoryItem(
      name: 'Sugar',
      category: InventoryCategory.beverageIngredients,
      currentStock: 10.0,
      minStockLevel: 2.0,
      maxStockLevel: 25.0,
      unit: InventoryUnit.kg,
      pricePerUnit: 45.0,
      lastUpdated: DateTime.now(),
      assetPath: 'assets/images/sugar.png',
    ),
    
    InventoryItem(
      name: 'Bread Slices',
      category: InventoryCategory.foodIngredients,
      currentStock: 50.0,
      minStockLevel: 20.0,
      maxStockLevel: 100.0,
      unit: InventoryUnit.pieces,
      pricePerUnit: 3.0,
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      lastUpdated: DateTime.now(),
      assetPath: 'assets/images/bread.png',
    ),
    InventoryItem(
      name: 'Potatoes',
      category: InventoryCategory.foodIngredients,
      currentStock: 15.0,
      minStockLevel: 5.0,
      maxStockLevel: 50.0,
      unit: InventoryUnit.kg,
      pricePerUnit: 25.0,
      lastUpdated: DateTime.now(),
      assetPath: 'assets/images/potatoes.png',
    ),
    
    InventoryItem(
      name: 'Coffee Cups',
      category: InventoryCategory.packaging,
      currentStock: 150.0,
      minStockLevel: 50.0,
      maxStockLevel: 500.0,
      unit: InventoryUnit.pieces,
      pricePerUnit: 2.0,
      lastUpdated: DateTime.now(),
      assetPath: 'assets/images/coffee-cup.png',
    ),
  ];

  static List<InventoryItem> getLowStockItems() {
    return inventoryItems.where((item) => item.isLowStock).toList();
  }

  static List<InventoryItem> getOutOfStockItems() {
    return inventoryItems.where((item) => item.isOutOfStock).toList();
  }

  static List<InventoryItem> getExpiringItems() {
    return inventoryItems.where((item) => item.isExpiring).toList();
  }
}