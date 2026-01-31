import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:divine_manager/core/services/util_service.dart';
import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:divine_manager/features/order/model/order.dart';
import 'package:divine_manager/features/order/services/order_service.dart';
import 'package:divine_manager/features/order/view/widgets/order_detail_dialog.dart';
import 'package:divine_manager/features/order/view/widgets/order_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class OrderListPage extends ConsumerStatefulWidget {
  const OrderListPage({super.key});

  @override
  ConsumerState<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends ConsumerState<OrderListPage> {
  final OrderService _orderService = OrderService();
  List<Order> orders = [];
  bool isLoading = true;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);
    try {
      final loadedOrders = selectedDate != null
          ? await _orderService.getOrdersByDateRange(
              DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day,
              ),
              DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day + 1,
              ),
            )
          : await _orderService.getAllOrders();

      setState(() {
        orders = loadedOrders;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        UtilService.showErrorSnackBar(context, 'Failed to load orders: $e');
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      _loadOrders();
    }
  }

  void _clearDateFilter() {
    setState(() => selectedDate = null);
    _loadOrders();
  }

  Future<void> _deleteOrder(Order order) async {
    try {
      final box = _orderService.getAllOrders();
      final allOrders = await box;
      final index = allOrders.indexWhere(
        (o) =>
            o.id == order.id &&
            o.timestamp.millisecondsSinceEpoch ==
                order.timestamp.millisecondsSinceEpoch,
      );

      if (index != -1) {
        await _orderService.deleteOrder(index);
        _loadOrders();
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

  Future<void> _updateOrder(Order updatedOrder) async {
    try {
      final box = _orderService.getAllOrders();
      final allOrders = await box;
      final index = allOrders.indexWhere(
        (o) =>
            o.id == updatedOrder.id &&
            o.timestamp.millisecondsSinceEpoch ==
                updatedOrder.timestamp.millisecondsSinceEpoch,
      );

      if (index != -1) {
        await _orderService.updateOrder(index, updatedOrder);
        _loadOrders();
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

  Future<void> _exportOrders() async {
    try {
      final StringBuffer csvBuffer = StringBuffer();
      csvBuffer.writeln(
        'Order ID,Date,Time,Items,Total Amount,Payment Method,Status',
      );

      for (final order in orders) {
        final date =
            '${order.timestamp.day}/${order.timestamp.month}/${order.timestamp.year}';
        final time =
            '${order.timestamp.hour}:${order.timestamp.minute.toString().padLeft(2, '0')}';
        final items = order.items
            .map((item) => '${item.item.name}(${item.quantity})')
            .join(';');

        csvBuffer.writeln(
          '${order.id},$date,$time,"$items",${order.totalPrice.toStringAsFixed(2)},${order.paymentMethod},${order.status}',
        );
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'divine_manager_orders_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvBuffer.toString());

      await SharePlus.instance.share(
        ShareParams(
          text: 'Divine Manager Orders Export',
          subject: 'Divine Manager Orders Export',
          files: [XFile(file.path)],
        ),
      );

      if (mounted) {
        UtilService.showSuccessSnackBar(
          context,
          'Orders exported successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        UtilService.showErrorSnackBar(context, 'Failed to export orders: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.brightnessOf(context) == Brightness.dark;
    final totalRevenue = orders.fold<double>(
      0,
      (sum, order) => sum + order.totalPrice,
    );
    final cashRevenue = orders
        .where((o) => o.paymentMethod == 'Cash')
        .fold<double>(0, (sum, order) => sum + order.totalPrice);
    final upiRevenue = orders
        .where((o) => o.paymentMethod == 'UPI')
        .fold<double>(0, (sum, order) => sum + order.totalPrice);
    final pendingRevenue = orders
        .where((o) => o.paymentMethod == 'Pending')
        .fold<double>(0, (sum, order) => sum + order.totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Management',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download, color: AppTheme.primaryColor),
            onPressed: orders.isNotEmpty ? _exportOrders : null,
            tooltip: 'Export Orders',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppTheme.darkBackgroundColor
                  : AppTheme.cardColor,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              boxShadow: !isDarkMode
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: BorderSide(
                            color: AppTheme.primaryColor,
                          ),
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.05,
                          ),
                        ),
                        icon: Icon(
                          Icons.calendar_today,
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                        label: Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Select Date',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onPressed: _selectDate,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (selectedDate != null)
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.errorColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.clear, color: AppTheme.errorColor),
                          onPressed: _clearDateFilter,
                          tooltip: 'Clear Filter',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRevenueCard(
                        'Total',
                        totalRevenue,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildRevenueCard(
                        'Cash',
                        cashRevenue,
                        AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildRevenueCard(
                        'UPI',
                        upiRevenue,
                        AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildRevenueCard(
                        'Pending',
                        pendingRevenue,
                        AppTheme.primaryOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          selectedDate != null
                              ? 'No orders found for selected date'
                              : 'No orders found',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return FadeInUp(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        child: OrderListCard(
                          order: order,
                          onTap: () => _showOrderDetail(order),
                          onDelete: () => _confirmDelete(order, isDarkMode),
                          onUpdate: () => _showOrderDetail(order, isEdit: true),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetail(Order order, {bool isEdit = false}) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailDialog(
        order: order,
        isEdit: isEdit,
        onUpdate: _updateOrder,
      ),
    );
  }

  void _confirmDelete(Order order, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode
            ? AppTheme.darkBackgroundColor
            : AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.primaryRed),
        ),
        title: Text(
          'Delete Order',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete order #${order.id}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOrder(order);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
