import 'package:hive/hive.dart';
part 'inventory_item.g.dart';

@HiveType(typeId: 0)
enum InventoryCategory {
  @HiveField(0)
  beverageIngredients,
  @HiveField(1)
  foodIngredients,
  @HiveField(2)
  packaging,
  @HiveField(3)
  equipment,
  @HiveField(4)
  cleaning,
  @HiveField(5)
  none
}

@HiveType(typeId: 1)
enum InventoryUnit {
  @HiveField(0)
  kg,
  @HiveField(1)
  grams,
  @HiveField(2)
  liters,
  @HiveField(3)
  ml,
  @HiveField(4)
  pieces,
  @HiveField(5)
  packets,
  @HiveField(6)
  bottles
}

@HiveType(typeId: 2)
class InventoryItem extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final InventoryCategory category;

  @HiveField(2)
  final double currentStock;

  @HiveField(3)
  final double minStockLevel;

  @HiveField(4)
  final double maxStockLevel;

  @HiveField(5)
  final InventoryUnit unit;

  @HiveField(6)
  final double pricePerUnit;

  @HiveField(7)
  final DateTime? expiryDate;

  @HiveField(8)
  final DateTime lastUpdated;

  @HiveField(9)
  final String assetPath;

  InventoryItem({
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minStockLevel,
    required this.maxStockLevel,
    required this.unit,
    required this.pricePerUnit,
    this.expiryDate,
    required this.lastUpdated,
    required this.assetPath,
  });

  bool get isLowStock => currentStock <= minStockLevel;
  bool get isOutOfStock => currentStock <= 0;
  bool get isExpiring {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate!.difference(now).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  }
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }
  double get stockPercentage {
    if (maxStockLevel == 0) return 0;
    return (currentStock / maxStockLevel) * 100;
  }
  double get totalValue => currentStock * pricePerUnit;

  InventoryItem copyWith({
    String? name,
    InventoryCategory? category,
    double? currentStock,
    double? minStockLevel,
    double? maxStockLevel,
    InventoryUnit? unit,
    double? pricePerUnit,
    DateTime? expiryDate,
    DateTime? lastUpdated,
    String? assetPath,
  }) {
    return InventoryItem(
      name: name ?? this.name,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      expiryDate: expiryDate ?? this.expiryDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      assetPath: assetPath ?? this.assetPath,
    );
  }

  @override
  String toString() {
    return 'InventoryItem(name: $name, currentStock: $currentStock, category: $category)';
  }
}