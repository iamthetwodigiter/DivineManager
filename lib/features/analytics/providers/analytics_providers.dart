import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:divine_manager/features/analytics/service/analytics_service.dart';
import 'package:divine_manager/features/analytics/model/analytics_model.dart';
import 'package:divine_manager/features/analytics/viewmodel/analytics_viewmodel.dart';
import 'package:divine_manager/features/order/services/order_service.dart';
import 'package:divine_manager/features/inventory/services/inventory_service.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/material.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(
    orderService: OrderService(),
    inventoryService: InventoryService(),
  );
});

final analyticsViewModelProvider = Provider<AnalyticsViewModel>((ref) {
  return AnalyticsViewModel(ref.read(analyticsServiceProvider));
});

final selectedPeriodProvider = StateProvider<AnalyticsPeriod>((ref) => AnalyticsPeriod.daily);

final customDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final salesDataProvider = FutureProvider<List<SalesData>>((ref) async {
  final viewModel = ref.read(analyticsViewModelProvider);
  final period = ref.watch(selectedPeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  return await viewModel.getSalesDataForPeriod(period, customRange);
});

final topSellingItemsProvider = FutureProvider<List<OrderAnalytics>>((ref) async {
  final viewModel = ref.read(analyticsViewModelProvider);
  return await viewModel.getTopSellingItems();
});

final inventoryAnalyticsProvider = FutureProvider<List<InventoryAnalytics>>((ref) async {
  final viewModel = ref.read(analyticsViewModelProvider);
  return await viewModel.getInventoryAnalytics();
});

final analyticsOverviewProvider = FutureProvider<AnalyticsOverview>((ref) async {
  final viewModel = ref.read(analyticsViewModelProvider);
  final period = ref.watch(selectedPeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  return await viewModel.getAnalyticsOverview(period, customRange);
});

final analyticsRefreshProvider = StateProvider<int>((ref) => 0);

final autoRefreshSalesDataProvider = FutureProvider<List<SalesData>>((ref) async {
  ref.watch(analyticsRefreshProvider);
  final viewModel = ref.read(analyticsViewModelProvider);
  final period = ref.watch(selectedPeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  return await viewModel.getSalesDataForPeriod(period, customRange);
});

final autoRefreshTopItemsProvider = FutureProvider<List<OrderAnalytics>>((ref) async {
  ref.watch(analyticsRefreshProvider);
  final viewModel = ref.read(analyticsViewModelProvider);
  return await viewModel.getTopSellingItems();
});

final autoRefreshInventoryProvider = FutureProvider<List<InventoryAnalytics>>((ref) async {
  ref.watch(analyticsRefreshProvider);
  final viewModel = ref.read(analyticsViewModelProvider);
  return await viewModel.getInventoryAnalytics();
});

final autoRefreshOverviewProvider = FutureProvider<AnalyticsOverview>((ref) async {
  ref.watch(analyticsRefreshProvider);
  final viewModel = ref.read(analyticsViewModelProvider);
  final period = ref.watch(selectedPeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  return await viewModel.getAnalyticsOverview(period, customRange);
});