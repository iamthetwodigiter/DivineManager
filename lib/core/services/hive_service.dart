import 'package:hive_flutter/hive_flutter.dart';
import 'package:divine_manager/features/inventory/model/inventory_item.dart';
import 'package:divine_manager/features/order/model/menu_items.dart';
import 'package:divine_manager/features/order/model/order.dart';
import 'package:divine_manager/features/analytics/model/analytics_model.dart';
import 'package:divine_manager/features/order/constants/constants.dart';
import 'package:divine_manager/features/inventory/constants/inventory_constants.dart';

class HiveService {
  static const String inventoryBoxName = 'inventory_box';
  static const String menuItemsBoxName = 'menu_items_box';
  static const String ordersBoxName = 'orders_box';
  static const String analyticsBoxName = 'analytics_box';
  static const String settingsBoxName = 'settings_box';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(InventoryCategoryAdapter());
    Hive.registerAdapter(InventoryUnitAdapter());
    Hive.registerAdapter(InventoryItemAdapter());
    Hive.registerAdapter(MenuItemsTypeAdapter());
    Hive.registerAdapter(MenuItemsAdapter());
    Hive.registerAdapter(OrderItemAdapter());
    Hive.registerAdapter(OrderAdapter());
    Hive.registerAdapter(AnalyticsPeriodAdapter());
    Hive.registerAdapter(AnalyticsTypeAdapter());
    Hive.registerAdapter(DailySalesRecordAdapter());

    await Future.wait([
      Hive.openBox<InventoryItem>(inventoryBoxName),
      Hive.openBox<MenuItems>(menuItemsBoxName),
      Hive.openBox<Order>(ordersBoxName),
      Hive.openBox<DailySalesRecord>(analyticsBoxName),
      Hive.openBox<dynamic>(settingsBoxName),
    ]);
  }

  static Box<InventoryItem> get inventoryBox => 
      Hive.box<InventoryItem>(inventoryBoxName);

  static Box<MenuItems> get menuItemsBox => 
      Hive.box<MenuItems>(menuItemsBoxName);

  static Box<Order> get ordersBox => 
      Hive.box<Order>(ordersBoxName);

  static Box<DailySalesRecord> get analyticsBox => 
      Hive.box<DailySalesRecord>(analyticsBoxName);

  static Box<dynamic> get settingsBox => 
      Hive.box<dynamic>(settingsBoxName);

  static Future<void> closeAllBoxes() async {
    await Hive.close();
  }

  static Future<void> initializeDefaultData() async {
    if (menuItemsBox.isEmpty) {
      await _initializeDefaultMenuItems();
    }

    if (inventoryBox.isEmpty) {
      await _initializeDefaultInventoryItems();
    }
  }

  static Future<void> _initializeDefaultMenuItems() async {
    final defaultMenuItems = MenuConstants.menuItems;

    for (final item in defaultMenuItems) {
      await menuItemsBox.add(item);
    }
  }

  static Future<void> _initializeDefaultInventoryItems() async {
    final defaultInventoryItems = InventoryConstants.inventoryItems;

    for (final item in defaultInventoryItems) {
      await inventoryBox.add(item);
    }
  }

  static Future<void> clearAllData() async {
    await Future.wait([
      inventoryBox.clear(),
      menuItemsBox.clear(),
      ordersBox.clear(),
      analyticsBox.clear(),
    ]);
  }
}