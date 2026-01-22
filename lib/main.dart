import 'package:divine_manager/core/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:divine_manager/core/services/hive_service.dart';
import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:divine_manager/core/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initHive();
  await HiveService.initializeDefaultData();
  
  runApp(const ProviderScope(child: DivineManager()));
}

class DivineManager extends ConsumerWidget {
  const DivineManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Divine Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
