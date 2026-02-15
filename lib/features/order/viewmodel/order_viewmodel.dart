import 'package:divine_manager/features/order/model/order.dart';
import 'package:divine_manager/features/order/model/menu_items.dart';
import 'package:divine_manager/features/order/services/order_service.dart';
import 'package:divine_manager/features/order/services/menu_service.dart';

class OrderViewModel {
  final OrderService _orderService;
  final MenuService _menuService;

  OrderViewModel(this._orderService, this._menuService);

  Future<List<MenuItems>> loadAllMenuItems() async {
    return await _menuService.getAllMenuItems();
  }

  Future<void> addNewMenuItem(MenuItems item) async {
    final validationError = validateMenuItem(item);
    if (validationError != null) {
      throw Exception(validationError);
    }
    await _menuService.addMenuItem(item);
  }

  Future<void> updateExistingMenuItem(int index, MenuItems updatedItem) async {
    final validationError = validateMenuItem(updatedItem);
    if (validationError != null) {
      throw Exception(validationError);
    }
    await _menuService.updateMenuItem(index, updatedItem);
  }

  Future<void> removeMenuItem(int index) async {
    await _menuService.deleteMenuItem(index);
  }

  Future<List<Order>> loadAllOrders() async {
    return await _orderService.getAllOrders();
  }

  Future<void> createNewOrder(Order order) async {
    final validationError = validateOrder(order);
    if (validationError != null) {
      throw Exception(validationError);
    }
    await _orderService.addOrder(order);
  }

  Future<void> updateExistingOrder(int index, Order updatedOrder) async {
    final validationError = validateOrder(updatedOrder);
    if (validationError != null) {
      throw Exception(validationError);
    }
    await _orderService.updateOrder(index, updatedOrder);
  }

  Future<void> removeOrder(int index) async {
    await _orderService.deleteOrder(index);
  }

  Future<String> generateOrderId() async {
    return await _orderService.generateOrderId();
  }

  List<OrderItem> addItemToCurrentOrder(
    List<OrderItem> currentOrder,
    OrderItem newOrderItem,
  ) {
    final existingIndex = currentOrder.indexWhere(
      (item) => item.item.name == newOrderItem.item.name,
    );

    if (existingIndex >= 0) {
      final existingItem = currentOrder[existingIndex];
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + newOrderItem.quantity,
      );
      return [
        ...currentOrder.sublist(0, existingIndex),
        updatedItem,
        ...currentOrder.sublist(existingIndex + 1),
      ];
    } else {
      return [...currentOrder, newOrderItem];
    }
  }

  List<OrderItem> removeItemFromCurrentOrder(
    List<OrderItem> currentOrder,
    int index,
  ) {
    return [
      ...currentOrder.sublist(0, index),
      ...currentOrder.sublist(index + 1),
    ];
  }

  List<OrderItem> updateOrderItemQuantity(
    List<OrderItem> currentOrder,
    int index,
    int newQuantity,
  ) {
    if (newQuantity <= 0) {
      return removeItemFromCurrentOrder(currentOrder, index);
    }

    final updatedItem = currentOrder[index].copyWith(quantity: newQuantity);
    return [
      ...currentOrder.sublist(0, index),
      updatedItem,
      ...currentOrder.sublist(index + 1),
    ];
  }

  double calculateOrderTotal(List<OrderItem> orderItems) {
    return orderItems.fold(
      0.0,
      (total, orderItem) => total + (orderItem.item.price * orderItem.quantity),
    );
  }

  int calculateTotalItems(List<OrderItem> orderItems) {
    return orderItems.fold(0, (total, orderItem) => total + orderItem.quantity);
  }

  double calculateAverageItemPrice(List<OrderItem> orderItems) {
    if (orderItems.isEmpty) return 0.0;
    final total = calculateOrderTotal(orderItems);
    final totalItems = calculateTotalItems(orderItems);
    return totalItems > 0 ? total / totalItems : 0.0;
  }

  List<MenuItems> filterMenuItemsByType(List<MenuItems> items, String? type) {
    if (type == null) return items;
    return items.where((item) => item.type?.name == type).toList();
  }

  List<MenuItems> filterMenuItemsByVegType(List<MenuItems> items, bool? isVeg) {
    if (isVeg == null) return items;
    return items.where((item) => item.isNonVeg != isVeg).toList();
  }

  List<MenuItems> searchMenuItemsByName(
    List<MenuItems> items,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return items;
    return items
        .where(
          (item) => item.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<MenuItems> sortMenuItemsByField(
    List<MenuItems> items,
    MenuSortField field,
    bool ascending,
  ) {
    final sortedItems = List<MenuItems>.from(items);

    switch (field) {
      case MenuSortField.name:
        sortedItems.sort(
          (a, b) =>
              ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
        );
        break;
      case MenuSortField.price:
        sortedItems.sort(
          (a, b) => ascending
              ? a.price.compareTo(b.price)
              : b.price.compareTo(a.price),
        );
        break;
      case MenuSortField.type:
        sortedItems.sort(
          (a, b) => ascending
              ? a.type.toString().compareTo(b.type.toString())
              : b.type.toString().compareTo(a.type.toString()),
        );
        break;
    }

    return sortedItems;
  }

  List<Order> filterOrdersByStatus(List<Order> orders, String? status) {
    if (status == null) return orders;
    return orders.where((order) => order.status.toString() == status).toList();
  }

  List<Order> filterOrdersByDateRange(
    List<Order> orders,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null || endDate == null) return orders;
    return orders
        .where(
          (order) =>
              order.timestamp.isAfter(startDate) &&
              order.timestamp.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  List<Order> searchOrdersById(List<Order> orders, String searchQuery) {
    if (searchQuery.isEmpty) return orders;
    return orders
        .where(
          (order) => order.id.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  String? validateMenuItem(MenuItems item) {
    if (item.name.trim().isEmpty) {
      return 'Item name cannot be empty';
    }
    if (item.price < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }

  String? validateOrder(Order order) {
    if (order.id.trim().isEmpty) {
      return 'Order ID cannot be empty';
    }
    if (order.items.isEmpty) {
      return 'Order must contain at least one item';
    }
    if (order.totalPrice < 0) {
      return 'Total price cannot be negative';
    }
    return null;
  }

  String? validateOrderItem(OrderItem orderItem) {
    if (orderItem.quantity <= 0) {
      return 'Quantity must be greater than 0';
    }
    return null;
  }

  Map<String, int> getMenuItemTypeDistribution(List<MenuItems> items) {
    final Map<String, int> distribution = {};
    for (final item in items) {
      final type = item.type.toString();
      distribution[type] = (distribution[type] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, dynamic> generateOrderReport(List<Order> orders) {
    final totalOrders = orders.length;
    final totalRevenue = orders.fold(
      0.0,
      (sum, order) => sum + order.totalPrice,
    );
    final averageOrderValue = totalOrders > 0
        ? totalRevenue / totalOrders
        : 0.0;

    final statusDistribution = <String, int>{};
    for (final order in orders) {
      final status = order.status.toString();
      statusDistribution[status] = (statusDistribution[status] ?? 0) + 1;
    }

    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'averageOrderValue': averageOrderValue,
      'statusDistribution': statusDistribution,
    };
  }

  String getDefaultAssetPath(String type) {
    switch (type.toLowerCase()) {
      case 'appetizer':
        return 'assets/images/appetizer.png';
      case 'main course':
      case 'maincourse':
        return 'assets/images/main-course.png';
      case 'dessert':
        return 'assets/images/dessert.png';
      case 'beverage':
        return 'assets/images/beverage.png';
      case 'snack':
        return 'assets/images/snack.png';
      default:
        return 'assets/images/order.png';
    }
  }

  String formatOrderId(String id) {
    return id.padLeft(4, '0');
  }

  String formatPrice(double price) {
    return '₹${price.toStringAsFixed(2)}';
  }
}

enum MenuSortField { name, price, type }
