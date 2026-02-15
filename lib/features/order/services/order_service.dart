import 'package:divine_manager/core/services/hive_service.dart';
import 'package:divine_manager/features/order/model/order.dart';

class OrderService {
  Future<List<Order>> getAllOrders() async {
    final box = HiveService.ordersBox;
    return box.values.toList().reversed.toList();
  }

  Future<void> addOrder(Order order) async {
    final box = HiveService.ordersBox;
    await box.add(order);
  }

  Future<void> updateOrder(int index, Order updatedOrder) async {
    final box = HiveService.ordersBox;
    await box.putAt(index, updatedOrder);
  }

  Future<void> deleteOrder(int index) async {
    final box = HiveService.ordersBox;
    await box.deleteAt(index);
  }

  Future<List<Order>> getOrdersByDateRange(DateTime start, DateTime end) async {
    final orders = await getAllOrders();
    return orders
        .where(
          (order) =>
              order.timestamp.isAfter(start) && order.timestamp.isBefore(end),
        )
        .toList();
  }

  Future<List<Order>> getTodaysOrders() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getOrdersByDateRange(startOfDay, endOfDay);
  }

  Future<double> getTotalRevenue() async {
    final orders = await getAllOrders();
    return orders.fold<double>(0.0, (total, order) => total + order.totalPrice);
  }

  Future<double> getTodaysRevenue() async {
    final todaysOrders = await getTodaysOrders();
    return todaysOrders.fold<double>(
      0.0,
      (total, order) => total + order.totalPrice,
    );
  }

  Future<String> generateOrderId() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayOrders = await _getOrdersForDateAsync(today);
    return (todayOrders.length + 1).toString();
  }

  Future<List<Order>> _getOrdersForDateAsync(DateTime date) async {
    final box = HiveService.ordersBox;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return box.values
        .where(
          (order) =>
              order.timestamp.isAfter(startOfDay) &&
              order.timestamp.isBefore(endOfDay),
        )
        .toList();
  }

  List<Order> _getOrdersForDate(DateTime date) {
    final box = HiveService.ordersBox;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return box.values
        .where(
          (order) =>
              order.timestamp.isAfter(startOfDay) &&
              order.timestamp.isBefore(endOfDay),
        )
        .toList();
  }

  Future<void> updateOrderByKey(dynamic key, Order updatedOrder) async {
    final box = HiveService.ordersBox;
    await box.put(key, updatedOrder);
  }

  Future<void> deleteOrderByKey(dynamic key) async {
    final box = HiveService.ordersBox;
    await box.delete(key);
  }

  Future<Order?> getOrderByKey(dynamic key) async {
    final box = HiveService.ordersBox;
    return box.get(key);
  }

  Future<double> getRevenueByDate(DateTime date) async {
    final dateOrders = _getOrdersForDate(date);
    return dateOrders.fold<double>(
      0.0,
      (total, order) => total + order.totalPrice,
    );
  }

  Future<Map<String, double>> getRevenueByPaymentMethod() async {
    final orders = await getAllOrders();
    final Map<String, double> revenueByMethod = {};

    for (final order in orders) {
      revenueByMethod[order.paymentMethod] =
          (revenueByMethod[order.paymentMethod] ?? 0) + order.totalPrice;
    }

    return revenueByMethod;
  }
}
