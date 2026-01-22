import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:divine_manager/features/order/model/order.dart';
import 'package:divine_manager/features/order/model/menu_items.dart';
import 'package:divine_manager/features/order/services/order_service.dart';
import 'package:divine_manager/features/order/services/menu_service.dart';
import 'package:divine_manager/features/order/viewmodel/order_viewmodel.dart';
import 'package:flutter_riverpod/legacy.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final menuServiceProvider = Provider<MenuService>((ref) {
  return MenuService();
});

final orderViewModelProvider = Provider<OrderViewModel>((ref) {
  return OrderViewModel(
    ref.read(orderServiceProvider),
    ref.read(menuServiceProvider),
  );
});

final menuItemsProvider = StateNotifierProvider<MenuItemsNotifier, AsyncValue<List<MenuItems>>>((ref) {
  return MenuItemsNotifier(ref.read(orderViewModelProvider));
});

final ordersProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<List<Order>>>((ref) {
  return OrdersNotifier(ref.read(orderViewModelProvider));
});

final currentOrderProvider = StateNotifierProvider<CurrentOrderNotifier, List<OrderItem>>((ref) {
  return CurrentOrderNotifier(ref.read(orderViewModelProvider));
});

final selectedMenuItemProvider = StateProvider<MenuItems?>((ref) => null);

final selectedQuantityProvider = StateProvider<int>((ref) => 1);

final currentOrderTotalProvider = Provider<double>((ref) {
  final currentOrder = ref.watch(currentOrderProvider);
  return currentOrder.fold(0.0, (total, orderItem) => 
      total + (orderItem.item.price * orderItem.quantity));
});

class MenuItemsNotifier extends StateNotifier<AsyncValue<List<MenuItems>>> {
  final OrderViewModel _viewModel;

  MenuItemsNotifier(this._viewModel) : super(const AsyncValue.loading()) {
    loadMenuItems();
  }

  Future<void> loadMenuItems() async {
    try {
      state = const AsyncValue.loading();
      final items = await _viewModel.loadAllMenuItems();
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addMenuItem(MenuItems item) async {
    try {
      await _viewModel.addNewMenuItem(item);
      await loadMenuItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateMenuItem(int index, MenuItems updatedItem) async {
    try {
      await _viewModel.updateExistingMenuItem(index, updatedItem);
      await loadMenuItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteMenuItem(int index) async {
    try {
      await _viewModel.removeMenuItem(index);
      await loadMenuItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class OrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderViewModel _viewModel;

  OrdersNotifier(this._viewModel) : super(const AsyncValue.loading()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      state = const AsyncValue.loading();
      final orders = await _viewModel.loadAllOrders();
      state = AsyncValue.data(orders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addOrder(Order order) async {
    try {
      await _viewModel.createNewOrder(order);
      await loadOrders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateOrder(int index, Order updatedOrder) async {
    try {
      await _viewModel.updateExistingOrder(index, updatedOrder);
      await loadOrders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteOrder(int index) async {
    try {
      await _viewModel.removeOrder(index);
      await loadOrders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class CurrentOrderNotifier extends StateNotifier<List<OrderItem>> {
  final OrderViewModel _viewModel;

  CurrentOrderNotifier(this._viewModel) : super([]);

  void addItem(OrderItem orderItem) {
    state = _viewModel.addItemToCurrentOrder(state, orderItem);
  }

  void removeItem(int index) {
    state = _viewModel.removeItemFromCurrentOrder(state, index);
  }

  void updateItemQuantity(int index, int newQuantity) {
    state = _viewModel.updateOrderItemQuantity(state, index, newQuantity);
  }

  void clearOrder() {
    state = [];
  }

  double get totalPrice => _viewModel.calculateOrderTotal(state);
}