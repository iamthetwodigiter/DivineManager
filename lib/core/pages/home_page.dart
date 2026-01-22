import 'package:animate_do/animate_do.dart';
import 'package:divine_manager/core/pages/about_dev_page.dart';
import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:divine_manager/features/analytics/view/pages/analytics_page.dart';
import 'package:divine_manager/features/inventory/view/pages/inventory_page.dart';
import 'package:divine_manager/features/order/view/pages/order_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _homePageCards(
    double width,
    String title,
    String assetPath,
    String subtitle,
    int delay,
    Widget page,
  ) => FadeInUp(
    duration: const Duration(milliseconds: 500),
    delay: Duration(milliseconds: 150 * delay),
    child: Container(
      height: 120,
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        highlightColor: AppTheme.primaryColor.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.75),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(assetPath, fit: BoxFit.contain),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.01),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.coffee_rounded,
                color: AppTheme.primaryColor,
                size: 65,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Cafe Divine',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              'Management System',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      floatingActionButton: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AboutDevPage()),
          );
        },
        icon: Icon(
          Icons.qr_code_scanner_rounded,
          size: 30,
          color: AppTheme.primaryColor,
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    _homePageCards(
                      size.width,
                      'Inventory',
                      'assets/images/inventory.png',
                      'Manage your stock and supplies',
                      0,
                      InventoryPage(),
                    ),
                    _homePageCards(
                      size.width,
                      'Orders',
                      'assets/images/order.png',
                      'Process and track customer orders',
                      1,
                      OrderPage(),
                    ),
                    _homePageCards(
                      size.width,
                      'Analytics',
                      'assets/images/analytics.png',
                      'View sales reports and insights',
                      2,
                      AnalyticsPage(),
                    ),
                  ],
                ),
              ),
              Spacer(),
              SlideInLeft(child: Text("Created with ❤️ by thetwodigiter")),
            ],
          ),
        ),
      ),
    );
  }
}
