import 'package:divine_manager/features/analytics/model/analytics_model.dart';
import 'package:divine_manager/features/analytics/service/analytics_service.dart';
import 'package:flutter/material.dart';

class AnalyticsViewModel {
  final AnalyticsService _analyticsService;
  AnalyticsViewModel(this._analyticsService);

  Future<List<SalesData>> getSalesDataForPeriod(
    AnalyticsPeriod period,
    DateTimeRange? customRange,
  ) async {
    return await _analyticsService.getSalesData(period, customRange);
  }

  Future<List<OrderAnalytics>> getTopSellingItems() async {
    return await _analyticsService.getTopSellingItems();
  }

  Future<List<InventoryAnalytics>> getInventoryAnalytics() async {
    return await _analyticsService.getInventoryAnalytics();
  }

  Future<AnalyticsOverview> getAnalyticsOverview(
    AnalyticsPeriod period,
    DateTimeRange? customRange,
  ) async {
    return await _analyticsService.getOverview(period, customRange);
  }


  bool isValidDateRange(DateTimeRange? dateRange) {
    if (dateRange == null) return false;
    return dateRange.start.isBefore(dateRange.end) && 
           dateRange.end.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  String formatPeriodDisplayName(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.daily:
        return 'Daily';
      case AnalyticsPeriod.weekly:
        return 'Weekly';
      case AnalyticsPeriod.monthly:
        return 'Monthly';
      case AnalyticsPeriod.yearly:
        return 'Yearly';
      case AnalyticsPeriod.custom:
        return 'Custom Range';
    }
  }

  Map<String, dynamic> generateExportData(
    AnalyticsOverview overview,
    List<OrderAnalytics> topItems,
    List<InventoryAnalytics> inventoryData,
    AnalyticsPeriod selectedPeriod,
    DateTimeRange? customDateRange,
  ) {
    final StringBuffer csvBuffer = StringBuffer();
    
    csvBuffer.writeln('Divine Manager Analytics Report');
    csvBuffer.writeln('Generated: ${DateTime.now().toString().split('.').first}');
    csvBuffer.writeln('Period: ${formatPeriodDisplayName(selectedPeriod)}');
    if (selectedPeriod == AnalyticsPeriod.custom && customDateRange != null) {
      csvBuffer.writeln('Date Range: ${customDateRange.start.toString().split(' ').first} to ${customDateRange.end.toString().split(' ').first}');
    }
    csvBuffer.writeln('');

    csvBuffer.writeln('OVERVIEW');
    csvBuffer.writeln('Metric,Value');
    csvBuffer.writeln('Total Revenue,₹${overview.totalRevenue.toStringAsFixed(2)}');
    csvBuffer.writeln('Total Orders,${overview.totalOrders}');
    csvBuffer.writeln('Items Sold,${overview.totalItemsSold}');
    csvBuffer.writeln('Average Order Value,₹${overview.averageOrderValue.toStringAsFixed(2)}');
    csvBuffer.writeln('');

    csvBuffer.writeln('TOP SELLING ITEMS');
    csvBuffer.writeln('Rank,Item Name,Quantity Sold,Revenue');
    for (int i = 0; i < topItems.length; i++) {
      final item = topItems[i];
      csvBuffer.writeln('${i + 1},"${item.itemName}",${item.quantitySold},₹${item.revenue.toStringAsFixed(2)}');
    }
    csvBuffer.writeln('');

    csvBuffer.writeln('INVENTORY ANALYTICS');
    csvBuffer.writeln('Item Name,Current Stock,Stock Value,Stock Usage');
    for (final item in inventoryData) {
      final maxStock = item.currentStock + item.stockUsed;
      final stockPercentage = maxStock > 0 ? (item.currentStock / maxStock) * 100 : 0.0;
      csvBuffer.writeln('"${item.itemName}",${item.currentStock.toStringAsFixed(1)},₹${item.stockValue.toStringAsFixed(2)},${(100 - stockPercentage).toStringAsFixed(1)}%');
    }

    return {
      'csvContent': csvBuffer.toString(),
      'filename': _generateFileName(selectedPeriod),
    };
  }

  String _generateFileName(AnalyticsPeriod period) {
    final now = DateTime.now();
    final timestamp = '${now.day.toString().padLeft(2, '0')}_${now.month.toString().padLeft(2, '0')}_${now.year.toString().substring(2)}_${now.hour.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}_${now.second.toString().padLeft(2, '0')}';
    return 'divine_manager_analytics_$timestamp.csv';
  }


  double calculateGrowthPercentage(double current, double previous) {
    if (previous == 0) return 0.0;
    return ((current - previous) / previous) * 100;
  }

  List<OrderAnalytics> filterTopItems(List<OrderAnalytics> items, int count) {
    final sorted = List<OrderAnalytics>.from(items);
    sorted.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
    return sorted.take(count).toList();
  }

  List<InventoryAnalytics> filterLowStockItems(List<InventoryAnalytics> items, double threshold) {
    return items.where((item) {
      final maxStock = item.currentStock + item.stockUsed;
      final stockPercentage = maxStock > 0 ? (item.currentStock / maxStock) * 100 : 0.0;
      return stockPercentage < threshold;
    }).toList();
  }


  bool validateDataForExport(
    AnalyticsOverview? overview,
    List<OrderAnalytics>? topItems,
    List<InventoryAnalytics>? inventoryData,
  ) {
    return overview != null && topItems != null && inventoryData != null;
  }

  String? validateCustomDateRange(DateTimeRange? dateRange) {
    if (dateRange == null) return 'Please select a date range';
    if (dateRange.start.isAfter(dateRange.end)) return 'Start date must be before end date';
    if (dateRange.end.isAfter(DateTime.now())) return 'End date cannot be in the future';
    if (dateRange.start.isBefore(DateTime.now().subtract(const Duration(days: 365 * 2)))) {
      return 'Start date cannot be more than 2 years ago';
    }
    return null;
  }
}