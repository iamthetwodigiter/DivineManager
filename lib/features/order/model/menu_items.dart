import 'package:hive/hive.dart';

part 'menu_items.g.dart';

@HiveType(typeId: 9)
enum MenuItemsType {
  @HiveField(0)
  tea,
  @HiveField(1)
  coffee,
  @HiveField(2)
  mocktails,
  @HiveField(3)
  momo,
  @HiveField(4)
  breadToast,
  @HiveField(5)
  friesAndBites,
}

@HiveType(typeId: 3)
class MenuItems extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double price;

  @HiveField(2)
  final String assetPath;

  @HiveField(3)
  final bool isNonVeg;

  @HiveField(4)
  final MenuItemsType? type;

  MenuItems({
    required this.name,
    required this.price,
    required this.assetPath,
    required this.isNonVeg,
    this.type,
  });

  MenuItems copyWith({
    String? name,
    double? price,
    String? assetPath,
    bool? isNonVeg,
    MenuItemsType? type,
  }) {
    return MenuItems(
      name: name ?? this.name,
      price: price ?? this.price,
      assetPath: assetPath ?? this.assetPath,
      isNonVeg: isNonVeg ?? this.isNonVeg,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'MenuItems(name: $name, price: $price, isNonVeg: $isNonVeg, type: $type)';
  }
}
