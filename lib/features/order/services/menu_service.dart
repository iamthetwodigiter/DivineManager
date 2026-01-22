import 'package:divine_manager/core/services/hive_service.dart';
import 'package:divine_manager/features/order/model/menu_items.dart';

class MenuService {
  Future<List<MenuItems>> getAllMenuItems() async {
    final box = HiveService.menuItemsBox;
    return box.values.toList();
  }

  Future<void> addMenuItem(MenuItems item) async {
    final box = HiveService.menuItemsBox;
    await box.add(item);
  }

  Future<void> updateMenuItem(int index, MenuItems updatedItem) async {
    final box = HiveService.menuItemsBox;
    await box.putAt(index, updatedItem);
  }

  Future<void> deleteMenuItem(int index) async {
    final box = HiveService.menuItemsBox;
    await box.deleteAt(index);
  }

  Future<MenuItems?> getMenuItemByName(String name) async {
    final box = HiveService.menuItemsBox;
    try {
      return box.values.firstWhere(
        (item) => item.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<MenuItems>> getVegItems() async {
    final items = await getAllMenuItems();
    return items.where((item) => !item.isNonVeg).toList();
  }

  Future<List<MenuItems>> getNonVegItems() async {
    final items = await getAllMenuItems();
    return items.where((item) => item.isNonVeg).toList();
  }
}