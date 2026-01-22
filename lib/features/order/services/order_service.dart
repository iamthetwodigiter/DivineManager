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

  String generateOrderId() {
    final box = HiveService.ordersBox;
    final orderCount = box.length;
    return (orderCount + 1).toString();
  }
}
