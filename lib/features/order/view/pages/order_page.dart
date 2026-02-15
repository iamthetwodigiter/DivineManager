import 'package:animate_do/animate_do.dart';
import 'package:divine_manager/core/services/util_service.dart';
import 'package:divine_manager/core/services/hive_service.dart';
import 'package:divine_manager/features/analytics/providers/analytics_providers.dart';
import 'package:divine_manager/features/order/constants/constants.dart';
import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:divine_manager/features/order/model/menu_items.dart';
import 'package:divine_manager/features/order/model/order.dart';
import 'package:divine_manager/features/order/services/order_service.dart';
import 'package:divine_manager/features/order/view/pages/menu_management_page.dart';
import 'package:divine_manager/features/order/view/pages/order_list_page.dart';
import 'package:divine_manager/features/order/view/widgets/order_item_card.dart';
import 'package:divine_manager/features/order/view/widgets/previous_order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderPage extends ConsumerStatefulWidget {
  const OrderPage({super.key});

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage> {
  List<OrderItem> currentOrder = [];
  List<Order> previousOrders = [];
  final OrderService _orderService = OrderService();

  MenuItems? selectedItem;
  int selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    _loadPreviousOrders();
  }

  Future<void> _loadPreviousOrders() async {
    try {
      final orders = await _orderService.getAllOrders();
      setState(() {
        previousOrders = orders;
      });
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
  }

  void _addItemToOrder() {
    if (selectedItem != null) {
      setState(() {
        int existingIndex = currentOrder.indexWhere(
          (orderItem) => orderItem.item.name == selectedItem!.name,
        );

        if (existingIndex != -1) {
          final existingItem = currentOrder[existingIndex];
          final newOrderItem = OrderItem(
            item: existingItem.item,
            quantity: existingItem.quantity + selectedQuantity,
          );
          currentOrder[existingIndex] = newOrderItem;
        } else {
          currentOrder.add(
            OrderItem(item: selectedItem!, quantity: selectedQuantity),
          );
        }

        selectedItem = null;
        selectedQuantity = 1;
      });
    }
  }

  void _removeItemFromOrder(int index) {
    setState(() {
      currentOrder.removeAt(index);
    });
  }

  double _calculateTotal() {
    return currentOrder.fold(
      0.0,
      (sum, orderItem) => sum + (orderItem.item.price * orderItem.quantity),
    );
  }

  Future<void> _placeOrder() async {
    if (currentOrder.isNotEmpty) {
      try {
        final orderId = await _orderService.generateOrderId();
        final order = Order(
          id: orderId,
          items: List.from(currentOrder),
          timestamp: DateTime.now(),
          totalPrice: _calculateTotal(),
        );

        await _orderService.addOrder(order);

        ref.read(analyticsRefreshProvider.notifier).state++;

        setState(() {
          currentOrder.clear();
        });

        await _loadPreviousOrders();

        if (mounted) {
          UtilService.showSuccessSnackBar(
            context,
            'Order placed successfully!',
          );
        }
      } catch (e) {
        if (mounted) {
          UtilService.showErrorSnackBar(context, 'Error placing order: $e');
        }
      }
    }
  }

  Future<void> _updateOrder(Order updatedOrder) async {
    try {
      final box = HiveService.ordersBox;
      dynamic orderKey;

      // Find the order key by matching id and timestamp
      for (var key in box.keys) {
        final order = box.get(key);
        if (order != null &&
            order.id == updatedOrder.id &&
            order.timestamp.millisecondsSinceEpoch ==
                updatedOrder.timestamp.millisecondsSinceEpoch) {
          orderKey = key;
          break;
        }
      }

      if (orderKey != null) {
        await _orderService.updateOrderByKey(orderKey, updatedOrder);
        await _loadPreviousOrders();

        ref.read(analyticsRefreshProvider.notifier).state++;

        if (mounted) {
          UtilService.showSuccessSnackBar(
            context,
            'Order updated successfully',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        UtilService.showErrorSnackBar(context, 'Failed to update order: $e');
      }
    }
  }

  Future<void> _deleteOrder(Order orderToDelete) async {
    try {
      final box = HiveService.ordersBox;
      dynamic orderKey;

      // Find the order key by matching id and timestamp
      for (var key in box.keys) {
        final order = box.get(key);
        if (order != null &&
            order.id == orderToDelete.id &&
            order.timestamp.millisecondsSinceEpoch ==
                orderToDelete.timestamp.millisecondsSinceEpoch) {
          orderKey = key;
          break;
        }
      }

      if (orderKey != null) {
        await _orderService.deleteOrderByKey(orderKey);
        await _loadPreviousOrders();

        ref.read(analyticsRefreshProvider.notifier).state++;

        if (mounted) {
          UtilService.showSuccessSnackBar(
            context,
            'Order deleted successfully',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        UtilService.showErrorSnackBar(context, 'Failed to delete order: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.brightnessOf(context) == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Management',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderListPage()),
              );
            },
            icon: Icon(Icons.list_alt, color: AppTheme.primaryColor),
            tooltip: 'View Orders',
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MenuManagementPage(),
                ),
              );
              setState(() {});
            },
            icon: Icon(Icons.edit_rounded, color: AppTheme.primaryColor),
            tooltip: 'Manage Menu',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                  boxShadow: !isDarkMode
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (currentOrder.isNotEmpty) ...[
                      ...currentOrder.asMap().entries.map((entry) {
                        final index = entry.key;
                        final orderItem = entry.value;
                        return OrderItemCard(
                          orderItem: orderItem,
                          removeItemFromOrder: () =>
                              _removeItemFromOrder(index),
                        );
                      }),

                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Total:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₹${_calculateTotal().toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<MenuItems>(
                              initialValue: selectedItem,
                              isExpanded: true,
                              icon: Container(
                                margin: const EdgeInsets.only(right: 5),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppTheme.primaryColor,
                                  size: 18,
                                ),
                              ),
                              hint: Row(
                                children: [
                                  Icon(
                                    Icons.restaurant_menu_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Select item',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              style: TextStyle(
                                color: AppTheme.primaryOrange,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              menuMaxHeight: 300,
                              items: MenuConstants.menuItems.map((item) {
                                return DropdownMenuItem<MenuItems>(
                                  value: item,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 250,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: AppTheme.primaryColor
                                                  .withValues(alpha: 0.2),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: Image.asset(
                                              item.assetPath,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.fastfood_rounded,
                                                      color:
                                                          AppTheme.primaryColor,
                                                      size: 14,
                                                    );
                                                  },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: item.isNonVeg
                                                ? AppTheme.nonVegColor
                                                : AppTheme.vegColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        Flexible(
                                          flex: 5,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                item.name,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              Text(
                                                item.isNonVeg
                                                    ? 'Non-Veg'
                                                    : 'Veg',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                          width: 45,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            '₹${item.price.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedItem = value;
                                });
                              },
                              selectedItemBuilder: (BuildContext context) {
                                return MenuConstants.menuItems.map((item) {
                                  return Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: Image.asset(
                                            item.assetPath,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Icon(
                                                    Icons.fastfood_rounded,
                                                    color:
                                                        AppTheme.primaryColor,
                                                    size: 12,
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: item.isNonVeg
                                              ? AppTheme.nonVegColor
                                              : AppTheme.vegColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '₹${item.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: selectedQuantity > 1
                                    ? () {
                                        setState(() => selectedQuantity--);
                                      }
                                    : null,
                                child: SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: selectedQuantity > 1
                                        ? AppTheme.primaryColor
                                        : AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                child: Text(
                                  '$selectedQuantity',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() => selectedQuantity++),
                                child: SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        if (currentOrder.isNotEmpty)
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _placeOrder,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: AppTheme.cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Place Order',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        if (currentOrder.isNotEmpty) const SizedBox(width: 12),

                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: selectedItem != null
                                ? _addItemToOrder
                                : null,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              backgroundColor: isDarkMode
                                  ? AppTheme.darkBackgroundColor
                                  : AppTheme.lightBackgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: AppTheme.primaryColor),
                              ),
                              textStyle: TextStyle(
                                color: AppTheme.primaryGrey,
                                fontWeight: FontWeight.bold,
                              ),
                              disabledForegroundColor: AppTheme
                                  .lightBackgroundColor
                                  .withValues(alpha: 0.3),
                              disabledBackgroundColor: AppTheme.primaryColor
                                  .withValues(alpha: 0.3),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            child: Text(
                              'Add Item',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                    boxShadow: isDarkMode
                        ? null
                        : [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Previous Orders',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (previousOrders.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${previousOrders.length}',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: previousOrders.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_rounded,
                                      size: 48,
                                      color: AppTheme.primaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No previous orders',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Your order history will appear here',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: previousOrders.length,
                                itemBuilder: (context, index) {
                                  final order = previousOrders[index];
                                  return FadeInUp(
                                    duration: const Duration(milliseconds: 300),
                                    delay: Duration(milliseconds: index * 50),
                                    child: PreviousOrderCard(
                                      order: order,
                                      onUpdate: _updateOrder,
                                      onDelete: _deleteOrder,
                                      onRefresh: _loadPreviousOrders,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
