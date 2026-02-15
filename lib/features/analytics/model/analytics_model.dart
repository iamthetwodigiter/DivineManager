import 'package:hive/hive.dart';
part 'analytics_model.g.dart';

@HiveType(typeId: 6)
enum AnalyticsPeriod {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
  @HiveField(4)
  custom,
}

@HiveType(typeId: 7)
enum AnalyticsType {
  @HiveField(0)
  orders,
  @HiveField(1)
  inventory,
  @HiveField(2)
  revenue,
}

@HiveType(typeId: 8)
class DailySalesRecord extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double revenue;

  @HiveField(2)
  final int orderCount;

  @HiveField(3)
  final int itemsSold;

  @HiveField(4)
  final Map<String, int> itemsSoldBreakdown;

  DailySalesRecord({
    required this.date,
    required this.revenue,
    required this.orderCount,
    required this.itemsSold,
    required this.itemsSoldBreakdown,
  });

  DailySalesRecord copyWith({
    DateTime? date,
    double? revenue,
    int? orderCount,
    int? itemsSold,
    Map<String, int>? itemsSoldBreakdown,
  }) {
    return DailySalesRecord(
      date: date ?? this.date,
      revenue: revenue ?? this.revenue,
      orderCount: orderCount ?? this.orderCount,
      itemsSold: itemsSold ?? this.itemsSold,
      itemsSoldBreakdown: itemsSoldBreakdown ?? this.itemsSoldBreakdown,
    );
  }
}

class SalesData {
  final DateTime date;
  final double revenue;
  final int orderCount;
  final int itemsSold;

  SalesData({
    required this.date,
    required this.revenue,
    required this.orderCount,
    required this.itemsSold,
  });
}

class OrderAnalytics {
  final String itemName;
  final int quantitySold;
  final double revenue;
  final int orderCount;

  OrderAnalytics({
    required this.itemName,
    required this.quantitySold,
    required this.revenue,
    required this.orderCount,
  });
}

class InventoryAnalytics {
  final String itemName;
  final double currentStock;
  final double lowStockThreshold;
  final bool isLowStock;
  final double stockUsed;
  final double stockValue;
  final int timesOrdered;

  InventoryAnalytics({
    required this.itemName,
    required this.currentStock,
    required this.lowStockThreshold,
    required this.isLowStock,
    required this.stockUsed,
    required this.stockValue,
    required this.timesOrdered,
  });
}

class CashFlowData {
  final DateTime date;
  final double cashInflow; // Money coming in (completed orders)
  final double cashOutflow; // Money going out (expenses, refunds)
  final double netCashFlow; // Net cash flow (inflow - outflow)
  final double cumulativeCash; // Running total of cash

  CashFlowData({
    required this.date,
    required this.cashInflow,
    required this.cashOutflow,
    required this.netCashFlow,
    required this.cumulativeCash,
  });
}

class PaymentMethodBreakdown {
  final String method;
  final double amount;
  final int orderCount;

  PaymentMethodBreakdown({
    required this.method,
    required this.amount,
    required this.orderCount,
  });
}

class AnalyticsOverview {
  final double totalRevenue;
  final int totalOrders;
  final int totalItemsSold;
  final double averageOrderValue;
  final String topSellingItem;
  final double revenueGrowth;
  final int lowStockItems;
  final double totalInventoryValue;

  AnalyticsOverview({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalItemsSold,
    required this.averageOrderValue,
    required this.topSellingItem,
    required this.revenueGrowth,
    required this.lowStockItems,
    required this.totalInventoryValue,
  });
}
