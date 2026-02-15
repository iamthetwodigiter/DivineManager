import 'package:divine_manager/features/analytics/model/analytics_model.dart';
import 'package:divine_manager/features/order/services/order_service.dart';
import 'package:divine_manager/features/inventory/services/inventory_service.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  final OrderService _orderService;
  final InventoryService _inventoryService;

  AnalyticsService({
    required OrderService orderService,
    required InventoryService inventoryService,
  }) : _orderService = orderService,
       _inventoryService = inventoryService;

  // Cash Flow Analysis Methods
  Future<List<CashFlowData>> getCashFlowData(
    AnalyticsPeriod period, [
    DateTimeRange? customRange,
  ]) async {
    final now = DateTime.now();
    final allOrders = await _orderService.getAllOrders();
    List<CashFlowData> cashFlowData = [];
    double runningCash = 0.0;

    switch (period) {
      case AnalyticsPeriod.daily:
        for (int i = 29; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final cashFlow = await _calculateDailyCashFlow(date, allOrders);
          runningCash += cashFlow.netCashFlow;
          cashFlowData.add(
            CashFlowData(
              date: date,
              cashInflow: cashFlow.cashInflow,
              cashOutflow: cashFlow.cashOutflow,
              netCashFlow: cashFlow.netCashFlow,
              cumulativeCash: runningCash,
            ),
          );
        }
        break;
      case AnalyticsPeriod.weekly:
        for (int i = 11; i >= 0; i--) {
          final endDate = now.subtract(Duration(days: i * 7));
          final startDate = endDate.subtract(const Duration(days: 6));
          final cashFlow = await _calculateWeeklyCashFlow(
            startDate,
            endDate,
            allOrders,
          );
          runningCash += cashFlow.netCashFlow;
          cashFlowData.add(
            CashFlowData(
              date: endDate,
              cashInflow: cashFlow.cashInflow,
              cashOutflow: cashFlow.cashOutflow,
              netCashFlow: cashFlow.netCashFlow,
              cumulativeCash: runningCash,
            ),
          );
        }
        break;
      case AnalyticsPeriod.monthly:
        for (int i = 11; i >= 0; i--) {
          final date = DateTime(now.year, now.month - i, 1);
          final cashFlow = await _calculateMonthlyCashFlow(date, allOrders);
          runningCash += cashFlow.netCashFlow;
          cashFlowData.add(
            CashFlowData(
              date: date,
              cashInflow: cashFlow.cashInflow,
              cashOutflow: cashFlow.cashOutflow,
              netCashFlow: cashFlow.netCashFlow,
              cumulativeCash: runningCash,
            ),
          );
        }
        break;
      case AnalyticsPeriod.custom:
        if (customRange != null) {
          final daysDifference =
              customRange.end.difference(customRange.start).inDays + 1;
          for (int i = 0; i < daysDifference; i++) {
            final date = customRange.start.add(Duration(days: i));
            final cashFlow = await _calculateDailyCashFlow(date, allOrders);
            runningCash += cashFlow.netCashFlow;
            cashFlowData.add(
              CashFlowData(
                date: date,
                cashInflow: cashFlow.cashInflow,
                cashOutflow: cashFlow.cashOutflow,
                netCashFlow: cashFlow.netCashFlow,
                cumulativeCash: runningCash,
              ),
            );
          }
        }
        break;
      default:
        break;
    }

    return cashFlowData;
  }

  Future<CashFlowData> _calculateDailyCashFlow(
    DateTime date,
    List<dynamic> allOrders,
  ) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final dayOrders = allOrders
        .where(
          (order) =>
              order.timestamp.isAfter(dayStart) &&
              order.timestamp.isBefore(dayEnd) &&
              order.status ==
                  'completed', // Only count completed orders as cash inflow
        )
        .toList();

    final cashInflow = dayOrders.fold<double>(
      0,
      (sum, order) => sum + order.totalPrice,
    );
    final cashOutflow =
        0.0; // For now, we can extend this to include expenses later

    return CashFlowData(
      date: date,
      cashInflow: cashInflow,
      cashOutflow: cashOutflow,
      netCashFlow: cashInflow - cashOutflow,
      cumulativeCash: 0.0, // This will be calculated in the calling method
    );
  }

  Future<CashFlowData> _calculateWeeklyCashFlow(
    DateTime startDate,
    DateTime endDate,
    List<dynamic> allOrders,
  ) async {
    final weekOrders = allOrders
        .where(
          (order) =>
              order.timestamp.isAfter(startDate) &&
              order.timestamp.isBefore(endDate.add(const Duration(days: 1))) &&
              order.status == 'completed',
        )
        .toList();

    final cashInflow = weekOrders.fold<double>(
      0,
      (sum, order) => sum + order.totalPrice,
    );
    final cashOutflow = 0.0;

    return CashFlowData(
      date: endDate,
      cashInflow: cashInflow,
      cashOutflow: cashOutflow,
      netCashFlow: cashInflow - cashOutflow,
      cumulativeCash: 0.0,
    );
  }

  Future<CashFlowData> _calculateMonthlyCashFlow(
    DateTime date,
    List<dynamic> allOrders,
  ) async {
    final monthStart = DateTime(date.year, date.month, 1);
    final monthEnd = DateTime(date.year, date.month + 1, 1);

    final monthOrders = allOrders
        .where(
          (order) =>
              order.timestamp.isAfter(monthStart) &&
              order.timestamp.isBefore(monthEnd) &&
              order.status == 'completed',
        )
        .toList();

    final cashInflow = monthOrders.fold<double>(
      0,
      (sum, order) => sum + order.totalPrice,
    );
    final cashOutflow = 0.0;

    return CashFlowData(
      date: date,
      cashInflow: cashInflow,
      cashOutflow: cashOutflow,
      netCashFlow: cashInflow - cashOutflow,
      cumulativeCash: 0.0,
    );
  }

  Future<List<PaymentMethodBreakdown>> getPaymentMethodBreakdown([
    DateTimeRange? customRange,
  ]) async {
    final allOrders = await _orderService.getAllOrders();

    List<dynamic> filteredOrders = allOrders;
    if (customRange != null) {
      filteredOrders = allOrders
          .where(
            (order) =>
                order.timestamp.isAfter(customRange.start) &&
                order.timestamp.isBefore(
                  customRange.end.add(const Duration(days: 1)),
                ),
          )
          .toList();
    }

    final cashOrders = filteredOrders
        .where((o) => o.paymentMethod == 'Cash')
        .toList();
    final upiOrders = filteredOrders
        .where((o) => o.paymentMethod == 'UPI')
        .toList();

    return [
      PaymentMethodBreakdown(
        method: 'Cash',
        amount: cashOrders.fold<double>(
          0,
          (sum, order) => sum + order.totalPrice,
        ),
        orderCount: cashOrders.length,
      ),
      PaymentMethodBreakdown(
        method: 'UPI',
        amount: upiOrders.fold<double>(
          0,
          (sum, order) => sum + order.totalPrice,
        ),
        orderCount: upiOrders.length,
      ),
    ];
  }

  Future<Map<String, dynamic>> getDailyBusinessMetrics(DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final allOrders = await _orderService.getAllOrders();
    final dayOrders = allOrders
        .where(
          (order) =>
              order.timestamp.isAfter(dayStart) &&
              order.timestamp.isBefore(dayEnd),
        )
        .toList();

    final totalRevenue = dayOrders.fold<double>(
      0,
      (sum, order) => sum + order.totalPrice,
    );
    final cashRevenue = dayOrders
        .where((o) => o.paymentMethod == 'Cash')
        .fold<double>(0, (sum, order) => sum + order.totalPrice);
    final upiRevenue = dayOrders
        .where((o) => o.paymentMethod == 'UPI')
        .fold<double>(0, (sum, order) => sum + order.totalPrice);

    final totalItems = dayOrders.fold<int>(
      0,
      (sum, order) =>
          sum +
          order.items.fold<int>(0, (itemSum, item) => itemSum + item.quantity),
    );

    final avgOrderValue = dayOrders.isNotEmpty
        ? totalRevenue / dayOrders.length
        : 0.0;

    final hourlySales = <int, double>{};
    for (int hour = 0; hour < 24; hour++) {
      hourlySales[hour] = 0.0;
    }

    for (final order in dayOrders) {
      final hour = order.timestamp.hour;
      hourlySales[hour] = (hourlySales[hour] ?? 0) + order.totalPrice;
    }

    return {
      'totalRevenue': totalRevenue,
      'cashRevenue': cashRevenue,
      'upiRevenue': upiRevenue,
      'totalOrders': dayOrders.length,
      'totalItems': totalItems,
      'avgOrderValue': avgOrderValue,
      'peakHour': _findPeakHour(hourlySales),
      'hourlySales': hourlySales,
    };
  }

  int _findPeakHour(Map<int, double> hourlySales) {
    var maxRevenue = 0.0;
    var peakHour = 0;

    hourlySales.forEach((hour, revenue) {
      if (revenue > maxRevenue) {
        maxRevenue = revenue;
        peakHour = hour;
      }
    });

    return peakHour;
  }

  Future<List<SalesData>> getSalesData(
    AnalyticsPeriod period, [
    DateTimeRange? customRange,
  ]) async {
    final now = DateTime.now();
    List<SalesData> data = [];

    try {
      final allOrders = await _orderService.getAllOrders();

      switch (period) {
        case AnalyticsPeriod.custom:
          if (customRange != null) {
            final startDate = customRange.start;
            final endDate = customRange.end;
            final daysDifference = endDate.difference(startDate).inDays + 1;

            for (int i = 0; i < daysDifference; i++) {
              final date = startDate.add(Duration(days: i));
              final dayStart = DateTime(date.year, date.month, date.day);
              final dayEnd = dayStart.add(const Duration(days: 1));

              final dayOrders = allOrders
                  .where(
                    (order) =>
                        order.timestamp.isAfter(dayStart) &&
                        order.timestamp.isBefore(dayEnd),
                  )
                  .toList();

              final dayRevenue = dayOrders.fold(
                0.0,
                (sum, order) => sum + order.totalPrice,
              );
              int dayItemsSold = 0;
              for (final order in dayOrders) {
                for (final orderItem in order.items) {
                  dayItemsSold += orderItem.quantity;
                }
              }

              data.add(
                SalesData(
                  date: date,
                  revenue: dayRevenue,
                  orderCount: dayOrders.length,
                  itemsSold: dayItemsSold,
                ),
              );
            }
          }
          break;
        case AnalyticsPeriod.daily:
          for (int i = 6; i >= 0; i--) {
            final date = now.subtract(Duration(days: i));
            final dayStart = DateTime(date.year, date.month, date.day);
            final dayEnd = dayStart.add(const Duration(days: 1));

            final dayOrders = allOrders
                .where(
                  (order) =>
                      order.timestamp.isAfter(dayStart) &&
                      order.timestamp.isBefore(dayEnd),
                )
                .toList();

            final dayRevenue = dayOrders.fold(
              0.0,
              (sum, order) => sum + order.totalPrice,
            );
            int dayItemsSold = 0;
            for (final order in dayOrders) {
              for (final orderItem in order.items) {
                dayItemsSold += orderItem.quantity;
              }
            }

            data.add(
              SalesData(
                date: date,
                revenue: dayRevenue,
                orderCount: dayOrders.length,
                itemsSold: dayItemsSold,
              ),
            );
          }
          break;

        case AnalyticsPeriod.weekly:
          for (int i = 7; i >= 0; i--) {
            final weekStart = now.subtract(
              Duration(days: i * 7 + now.weekday - 1),
            );
            final weekEnd = weekStart.add(const Duration(days: 7));

            final weekOrders = allOrders
                .where(
                  (order) =>
                      order.timestamp.isAfter(weekStart) &&
                      order.timestamp.isBefore(weekEnd),
                )
                .toList();

            final weekRevenue = weekOrders.fold(
              0.0,
              (sum, order) => sum + order.totalPrice,
            );
            int weekItemsSold = 0;
            for (final order in weekOrders) {
              for (final orderItem in order.items) {
                weekItemsSold += orderItem.quantity;
              }
            }

            data.add(
              SalesData(
                date: weekStart,
                revenue: weekRevenue,
                orderCount: weekOrders.length,
                itemsSold: weekItemsSold,
              ),
            );
          }
          break;

        case AnalyticsPeriod.monthly:
          for (int i = 5; i >= 0; i--) {
            final monthStart = DateTime(now.year, now.month - i, 1);
            final monthEnd = DateTime(now.year, now.month - i + 1, 1);

            final monthOrders = allOrders
                .where(
                  (order) =>
                      order.timestamp.isAfter(monthStart) &&
                      order.timestamp.isBefore(monthEnd),
                )
                .toList();

            final monthRevenue = monthOrders.fold(
              0.0,
              (sum, order) => sum + order.totalPrice,
            );
            int monthItemsSold = 0;
            for (final order in monthOrders) {
              for (final orderItem in order.items) {
                monthItemsSold += orderItem.quantity;
              }
            }

            data.add(
              SalesData(
                date: monthStart,
                revenue: monthRevenue,
                orderCount: monthOrders.length,
                itemsSold: monthItemsSold,
              ),
            );
          }
          break;

        case AnalyticsPeriod.yearly:
          for (int i = 2; i >= 0; i--) {
            final yearStart = DateTime(now.year - i, 1, 1);
            final yearEnd = DateTime(now.year - i + 1, 1, 1);

            final yearOrders = allOrders
                .where(
                  (order) =>
                      order.timestamp.isAfter(yearStart) &&
                      order.timestamp.isBefore(yearEnd),
                )
                .toList();

            final yearRevenue = yearOrders.fold(
              0.0,
              (sum, order) => sum + order.totalPrice,
            );
            int yearItemsSold = 0;
            for (final order in yearOrders) {
              for (final orderItem in order.items) {
                yearItemsSold += orderItem.quantity;
              }
            }

            data.add(
              SalesData(
                date: yearStart,
                revenue: yearRevenue,
                orderCount: yearOrders.length,
                itemsSold: yearItemsSold,
              ),
            );
          }
          break;
      }
    } catch (e) {
      data = _generateEmptySalesData(period);
    }

    return data;
  }

  Future<List<OrderAnalytics>> getTopSellingItems() async {
    try {
      final orders = await _orderService.getAllOrders();
      final Map<String, Map<String, dynamic>> itemStats = {};

      for (final order in orders) {
        for (final orderItem in order.items) {
          final itemName = orderItem.item.name;
          final quantity = orderItem.quantity;
          final itemRevenue = orderItem.item.price * quantity;

          if (itemStats.containsKey(itemName)) {
            itemStats[itemName]!['quantitySold'] += quantity;
            itemStats[itemName]!['revenue'] += itemRevenue;
            itemStats[itemName]!['orderCount'] += 1;
          } else {
            itemStats[itemName] = {
              'quantitySold': quantity,
              'revenue': itemRevenue,
              'orderCount': 1,
            };
          }
        }
      }

      final sortedItems =
          itemStats.entries
              .map(
                (entry) => OrderAnalytics(
                  itemName: entry.key,
                  quantitySold: entry.value['quantitySold'] as int,
                  revenue: entry.value['revenue'] as double,
                  orderCount: entry.value['orderCount'] as int,
                ),
              )
              .toList()
            ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

      return sortedItems.take(5).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<InventoryAnalytics>> getInventoryAnalytics() async {
    try {
      final inventoryItems = await _inventoryService.getAllInventoryItems();
      final orders = await _orderService.getAllOrders();
      final Map<String, int> itemUsage = {};

      for (final order in orders) {
        for (final orderItem in order.items) {
          final itemName = orderItem.item.name;
          itemUsage[itemName] = (itemUsage[itemName] ?? 0) + orderItem.quantity;
        }
      }

      return inventoryItems.map((item) {
        final timesOrdered = itemUsage[item.name] ?? 0;
        final stockUsed = timesOrdered * 0.1;

        return InventoryAnalytics(
          itemName: item.name,
          currentStock: item.currentStock,
          lowStockThreshold: item.minStockLevel,
          isLowStock: item.currentStock <= item.minStockLevel,
          stockUsed: stockUsed,
          stockValue: item.currentStock * item.pricePerUnit,
          timesOrdered: timesOrdered,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<AnalyticsOverview> getOverview(
    AnalyticsPeriod period, [
    DateTimeRange? customRange,
  ]) async {
    try {
      final salesData = await getSalesData(period, customRange);
      final lowStockItems = await _inventoryService.getLowStockItems();
      final topItems = await getTopSellingItems();

      final totalRevenue = salesData.fold(
        0.0,
        (sum, data) => sum + data.revenue,
      );
      final totalOrders = salesData.fold(
        0,
        (sum, data) => sum + data.orderCount,
      );
      final totalItemsSold = salesData.fold(
        0,
        (sum, data) => sum + data.itemsSold,
      );
      final averageOrderValue = totalOrders > 0
          ? totalRevenue / totalOrders
          : 0.0;
      final totalInventoryValue = await _inventoryService
          .getTotalInventoryValue();

      final revenueGrowth = salesData.length >= 2 && salesData.first.revenue > 0
          ? ((salesData.last.revenue - salesData.first.revenue) /
                    salesData.first.revenue) *
                100
          : 0.0;

      return AnalyticsOverview(
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        totalItemsSold: totalItemsSold,
        averageOrderValue: averageOrderValue,
        topSellingItem: topItems.isNotEmpty
            ? topItems.first.itemName
            : 'No sales yet',
        revenueGrowth: revenueGrowth,
        lowStockItems: lowStockItems.length,
        totalInventoryValue: totalInventoryValue,
      );
    } catch (e) {
      return AnalyticsOverview(
        totalRevenue: 0.0,
        totalOrders: 0,
        totalItemsSold: 0,
        averageOrderValue: 0.0,
        topSellingItem: 'No sales yet',
        revenueGrowth: 0.0,
        lowStockItems: 0,
        totalInventoryValue: 0.0,
      );
    }
  }

  List<SalesData> _generateEmptySalesData(AnalyticsPeriod period) {
    final now = DateTime.now();
    List<SalesData> data = [];

    switch (period) {
      case AnalyticsPeriod.daily:
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          data.add(
            SalesData(date: date, revenue: 0.0, orderCount: 0, itemsSold: 0),
          );
        }
        break;
      case AnalyticsPeriod.weekly:
        for (int i = 7; i >= 0; i--) {
          final date = now.subtract(Duration(days: i * 7));
          data.add(
            SalesData(date: date, revenue: 0.0, orderCount: 0, itemsSold: 0),
          );
        }
        break;
      case AnalyticsPeriod.monthly:
        for (int i = 5; i >= 0; i--) {
          final date = DateTime(now.year, now.month - i, 1);
          data.add(
            SalesData(date: date, revenue: 0.0, orderCount: 0, itemsSold: 0),
          );
        }
        break;
      case AnalyticsPeriod.yearly:
        for (int i = 2; i >= 0; i--) {
          final date = DateTime(now.year - i, 1, 1);
          data.add(
            SalesData(date: date, revenue: 0.0, orderCount: 0, itemsSold: 0),
          );
        }
        break;
      case AnalyticsPeriod.custom:
        break;
    }
    return data;
  }
}
