import 'package:animate_do/animate_do.dart';
import 'package:divine_manager/core/services/util_service.dart';
import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:divine_manager/core/widgets/custom_form_widgets.dart';
import 'package:divine_manager/features/analytics/model/analytics_model.dart';
import 'package:divine_manager/features/analytics/providers/analytics_providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  Widget _periodChip(
    AnalyticsPeriod period,
    AnalyticsPeriod selectedPeriod,
    WidgetRef ref,
  ) {
    final isSelected = period == selectedPeriod;
    String label;
    IconData icon;

    switch (period) {
      case AnalyticsPeriod.daily:
        label = 'Daily';
        icon = Icons.today_rounded;
        break;
      case AnalyticsPeriod.weekly:
        label = 'Weekly';
        icon = Icons.view_week_rounded;
        break;
      case AnalyticsPeriod.monthly:
        label = 'Monthly';
        icon = Icons.calendar_month_rounded;
        break;
      case AnalyticsPeriod.yearly:
        label = 'Yearly';
        icon = Icons.calendar_month_rounded;
        break;
      case AnalyticsPeriod.custom:
        label = 'Custom';
        icon = Icons.calendar_month_rounded;
    }

    return InkWell(
      onTap: () => ref.read(selectedPeriodProvider.notifier).state = period,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.cardColor : AppTheme.primaryColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.cardColor : AppTheme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(title, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(List<SalesData> salesData, AnalyticsPeriod period) {
    if (salesData.isEmpty || salesData.every((data) => data.revenue == 0)) {
      return _buildEmptyChart();
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
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
                Icon(
                  Icons.show_chart_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Revenue Trend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (_getMaxRevenue(salesData) / 5).clamp(
                      1.0,
                      double.infinity,
                    ),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${(value / 1000).toStringAsFixed(0)}K',
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < salesData.length) {
                            final date = salesData[index].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                _formatChartDate(date, period),
                                style: TextStyle(fontSize: 12),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: salesData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.revenue,
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.primaryColor,
                            strokeWidth: 2,
                            strokeColor: AppTheme.cardColor,
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
    );
  }

  Widget _buildTopItemsWidget(
    BuildContext context,
    List<OrderAnalytics> topItems,
  ) {
    final displayItems = topItems.take(5).toList();
    final hasMore = topItems.length > 5;

    return FadeInLeft(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
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
                CustomIconContainer(
                  icon: Icons.star_rounded,
                  iconColor: AppTheme.primaryOrange,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Selling Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Best performing products',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (hasMore)
                  IconButton(
                    onPressed: () => _showAllTopItems(context, topItems),
                    icon: Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    tooltip: 'Show all items',
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (topItems.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        size: 64,
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No sales data yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Start placing orders to see top selling items',
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...displayItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomRankContainer(rank: index + 1),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.itemName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.shopping_cart_outlined, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.quantitySold} sold',
                                  style: TextStyle(fontSize: 13),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.currency_rupee_rounded,
                                  size: 14,
                                  color: AppTheme.primaryGreen,
                                ),
                                Text(
                                  item.revenue.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: UtilService.getRankColor(index).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: UtilService.getRankColor(index),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => _showAllTopItems(context, topItems),
                    icon: Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    label: Text(
                      'Show ${topItems.length - 5} more items',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryWidget(
    BuildContext context,
    List<InventoryAnalytics> inventoryData,
  ) {
    final displayItems = inventoryData.take(5).toList();
    final hasMore = inventoryData.length > 5;

    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
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
                CustomIconContainer(
                  icon: Icons.inventory_2_rounded,
                  iconColor: AppTheme.primaryBlue,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventory Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Stock levels and values',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (hasMore)
                  IconButton(
                    onPressed: () =>
                        _showAllInventoryItems(context, inventoryData),
                    icon: Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    tooltip: 'Show all items',
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (inventoryData.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No inventory data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Add items to your inventory to see analytics',
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...displayItems.map((item) {
                final maxStock = item.currentStock + item.stockUsed;
                final stockPercentage = maxStock > 0
                    ? (item.currentStock / maxStock) * 100
                    : 0.0;
                final stockColor = stockPercentage > 50
                    ? AppTheme.primaryGreen
                    : stockPercentage > 25
                    ? AppTheme.primaryOrange
                    : AppTheme.primaryRed;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomIconContainer(
                            icon: Icons.inventory_2_outlined,
                            iconColor: stockColor,
                            size: 40,
                            iconSize: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.itemName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.currency_rupee_rounded,
                                      size: 14,
                                      color: AppTheme.primaryColor,
                                    ),
                                    Text(
                                      item.stockValue.toStringAsFixed(0),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.inventory_outlined, size: 14),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${item.currentStock.toStringAsFixed(1)} units',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: stockColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${stockPercentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: stockColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Stock Level',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                stockPercentage > 50
                                    ? 'Healthy'
                                    : stockPercentage > 25
                                    ? 'Low Stock'
                                    : 'Critical',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: stockColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (stockPercentage / 100).clamp(
                                0.0,
                                1.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: stockColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        _showAllInventoryItems(context, inventoryData),
                    icon: Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    label: Text(
                      'Show ${inventoryData.length - 5} more items',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCustomDatePicker(WidgetRef ref) async {
    final customDateRange = ref.read(customDateRangeProvider);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: customDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
              onPrimary: AppTheme.cardColor,
              surface: AppTheme.cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(customDateRangeProvider.notifier).state = picked;
      ref.read(selectedPeriodProvider.notifier).state = AnalyticsPeriod.custom;
    }
  }

  Future<void> _exportAnalyticsData(WidgetRef ref) async {
    try {
      final selectedPeriod = ref.read(selectedPeriodProvider);
      final customDateRange = ref.read(customDateRangeProvider);
      final overviewAsync = ref.read(autoRefreshOverviewProvider);
      final topItemsAsync = ref.read(topSellingItemsProvider);
      final inventoryDataAsync = ref.read(inventoryAnalyticsProvider);

      if (!overviewAsync.hasValue ||
          !topItemsAsync.hasValue ||
          !inventoryDataAsync.hasValue) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please wait for data to load before exporting'),
              backgroundColor: AppTheme.primaryOrange,
            ),
          );
        }
        return;
      }

      final overview = overviewAsync.value!;
      final topItems = topItemsAsync.value!;
      final inventoryData = inventoryDataAsync.value!;

      final viewModel = ref.read(analyticsViewModelProvider);
      final exportData = viewModel.generateExportData(
        overview,
        topItems,
        inventoryData,
        selectedPeriod,
        customDateRange,
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${exportData['filename']}');
      await file.writeAsString(exportData['csvContent']);

      await SharePlus.instance.share(
        ShareParams(
          text: 'Divine Manager Analytics Report',
          subject: 'Analytics Export - ${viewModel.formatPeriodDisplayName(selectedPeriod)}',
          files: [XFile(file.path)],
        ),
      );

      if (mounted) {
        UtilService.showSuccessSnackBar(
          context,
          'Analytics data exported successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        UtilService.showErrorSnackBar(
          context,
          'Error exporting data: $e',
        );
      }
    }
  }

  void _showAllTopItems(BuildContext context, List<OrderAnalytics> topItems) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: AppTheme.primaryOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All Top Selling Items',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: topItems.length,
                  itemBuilder: (context, index) {
                    final item = topItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomRankContainer(rank: index + 1),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.itemName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.quantitySold} sold',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.currency_rupee_rounded,
                                      size: 14,
                                      color: AppTheme.primaryGreen,
                                    ),
                                    Text(
                                      item.revenue.toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllInventoryItems(
    BuildContext context,
    List<InventoryAnalytics> inventoryData,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_rounded,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All Inventory Items',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: inventoryData.length,
                  itemBuilder: (context, index) {
                    final item = inventoryData[index];
                    final maxStock = item.currentStock + item.stockUsed;
                    final stockPercentage = maxStock > 0
                        ? (item.currentStock / maxStock) * 100
                        : 0.0;
                    final stockColor = stockPercentage > 50
                        ? AppTheme.primaryGreen
                        : stockPercentage > 25
                        ? AppTheme.primaryOrange
                        : AppTheme.primaryRed;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconContainer(
                                icon: Icons.inventory_2_outlined,
                                iconColor: stockColor,
                                size: 40,
                                iconSize: 20,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.itemName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.currency_rupee_rounded,
                                          size: 14,
                                          color: AppTheme.primaryColor,
                                        ),
                                        Text(
                                          item.stockValue.toStringAsFixed(0),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.inventory_outlined,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item.currentStock.toStringAsFixed(1)} units',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: stockColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${stockPercentage.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: stockColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (stockPercentage / 100).clamp(
                                0.0,
                                1.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: stockColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getMaxRevenue(List<SalesData> salesData) {
    if (salesData.isEmpty) return 1000.0;

    final maxRevenue = salesData
        .map((data) => data.revenue)
        .reduce((a, b) => a > b ? a : b);
    return maxRevenue > 0 ? maxRevenue : 1000.0;
  }

  String _formatChartDate(DateTime date, AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.daily:
      case AnalyticsPeriod.custom:
        return '${date.day}/${date.month}';
      case AnalyticsPeriod.weekly:
        return 'W${_getWeekOfYear(date)}';
      case AnalyticsPeriod.monthly:
        return _getMonthName(date.month);
      case AnalyticsPeriod.yearly:
        return '${date.year}';
    }
  }

  int _getWeekOfYear(DateTime date) {
    int dayOfYear = int.parse(date.strftime("%j"));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildLoadingOverview() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      child: SizedBox(
        height: 68,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingChart() {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 240,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(String title) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 2,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppTheme.primaryRed.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: 64,
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No sales data available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start placing orders to see analytics',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final customDateRange = ref.watch(customDateRangeProvider);
    final overviewAsync = ref.watch(autoRefreshOverviewProvider);
    final salesDataAsync = ref.watch(autoRefreshSalesDataProvider);
    final topItemsAsync = ref.watch(autoRefreshTopItemsProvider);
    final inventoryDataAsync = ref.watch(autoRefreshInventoryProvider);

    final isDarkMode = Theme.brightnessOf(context) == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Business Analytics',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () => _exportAnalyticsData(ref),
            icon: Icon(
              Icons.file_download_rounded,
              color: AppTheme.primaryColor,
            ),
            tooltip: 'Export Data',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 600),
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
                          Icon(
                            Icons.calendar_month_rounded,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Analysis Period',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...AnalyticsPeriod.values
                              .where((p) => p != AnalyticsPeriod.custom)
                              .map((period) {
                                return _periodChip(period, selectedPeriod, ref);
                              }),
                          InkWell(
                            onTap: () => _showCustomDatePicker(ref),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selectedPeriod == AnalyticsPeriod.custom
                                    ? AppTheme.primaryColor
                                    : AppTheme.primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.date_range_rounded,
                                    color:
                                        selectedPeriod == AnalyticsPeriod.custom
                                        ? AppTheme.cardColor
                                        : AppTheme.primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    customDateRange != null
                                        ? '${customDateRange.start.day}/${customDateRange.start.month} - ${customDateRange.end.day}/${customDateRange.end.month}'
                                        : 'Custom',
                                    style: TextStyle(
                                      color:
                                          selectedPeriod ==
                                              AnalyticsPeriod.custom
                                          ? AppTheme.cardColor
                                          : AppTheme.primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              overviewAsync.when(
                data: (overview) => Column(
                  children: [
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: Row(
                        children: [
                          Expanded(
                            child: _overviewCard(
                              'Revenue',
                              '₹${overview.totalRevenue.toStringAsFixed(0)}',
                              Icons.currency_rupee_rounded,
                              AppTheme.primaryGreen,
                              '${overview.revenueGrowth > 0 ? '+' : ''}${overview.revenueGrowth.toStringAsFixed(1)}%',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _overviewCard(
                              'Orders',
                              '${overview.totalOrders}',
                              Icons.shopping_bag_rounded,
                              AppTheme.primaryBlue,
                              overview.totalOrders > 0
                                  ? '+${(overview.totalOrders * 0.12).toInt()}'
                                  : '0%',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 100),
                      child: Row(
                        children: [
                          Expanded(
                            child: _overviewCard(
                              'Items Sold',
                              '${overview.totalItemsSold}',
                              Icons.inventory_2_rounded,
                              AppTheme.primaryOrange,
                              overview.totalItemsSold > 0
                                  ? '+${(overview.totalItemsSold * 0.08).toInt()}'
                                  : '0%',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _overviewCard(
                              'Avg Order',
                              '₹${overview.averageOrderValue.toStringAsFixed(0)}',
                              Icons.trending_up_rounded,
                              AppTheme.primaryPurple,
                              overview.averageOrderValue > 0
                                  ? '+${(overview.averageOrderValue * 0.05).toStringAsFixed(0)}'
                                  : '0%',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                loading: () => _buildLoadingOverview(),
                error: (error, stack) =>
                    _buildErrorWidget('Failed to load overview'),
              ),
              const SizedBox(height: 20),

              salesDataAsync.when(
                data: (salesData) =>
                    _buildRevenueChart(salesData, selectedPeriod),
                loading: () => _buildLoadingChart(),
                error: (error, stack) =>
                    _buildErrorWidget('Failed to load sales data'),
              ),
              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  topItemsAsync.when(
                    data: (topItems) => _buildTopItemsWidget(context, topItems),
                    loading: () => _buildLoadingWidget('Top Items'),
                    error: (error, stack) =>
                        _buildErrorWidget('Failed to load top items'),
                  ),
                  const SizedBox(height: 20),
                  inventoryDataAsync.when(
                    data: (inventoryData) =>
                        _buildInventoryWidget(context, inventoryData),
                    loading: () => _buildLoadingWidget('Inventory'),
                    error: (error, stack) =>
                        _buildErrorWidget('Failed to load inventory'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  String strftime(String format) {
    switch (format) {
      case "%j":
        return (difference(DateTime(year, 1, 1)).inDays + 1).toString().padLeft(
          3,
          '0',
        );
      default:
        return toString();
    }
  }
}
