import 'package:hive/hive.dart';
import 'package:divine_manager/features/order/model/menu_items.dart';

part 'order.g.dart';

@HiveType(typeId: 4)
class OrderItem extends HiveObject {
  @HiveField(0)
  final MenuItems item;

  @HiveField(1)
  final int quantity;

  OrderItem({
    required this.item,
    required this.quantity,
  });

  OrderItem copyWith({
    MenuItems? item,
    int? quantity,
  }) {
    return OrderItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'OrderItem(item: ${item.name}, quantity: $quantity)';
  }
}

@HiveType(typeId: 5)
class Order extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<OrderItem> items;

  @HiveField(2)
  final double totalPrice;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final String paymentMethod;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.timestamp,
    this.status = 'pending',
    this.paymentMethod = 'Pending',
  });

  List<OrderItem> get menuItems => items;

  Order copyWith({
    String? id,
    List<OrderItem>? items,
    double? totalPrice,
    DateTime? timestamp,
    String? status,
    String? paymentMethod,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, totalPrice: $totalPrice, itemCount: ${items.length})';
  }
}