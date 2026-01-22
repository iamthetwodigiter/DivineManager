import 'package:animate_do/animate_do.dart';
import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDevPage extends StatefulWidget {
  const AboutDevPage({super.key});

  @override
  State<AboutDevPage> createState() => _AboutDevPageState();
}

class _AboutDevPageState extends State<AboutDevPage>
    with TickerProviderStateMixin {
  late AnimationController _coffeeController;
  late Animation<double> _coffeeAnimation;
  int _coffeeCount = 0;

  @override
  void initState() {
    super.initState();
    _coffeeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _coffeeAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _coffeeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _coffeeController.dispose();
    super.dispose();
  }

  void _animateCoffee() {
    setState(() {
      _coffeeCount++;
    });
    _coffeeController.forward().then((_) {
      _coffeeController.reverse();
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse('https://github.com/iamthetwodigiter');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open GitHub link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchRepo() async {
    final Uri url = Uri.parse(
      'https://github.com/iamthetwodigiter/DivineManager',
    );
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open repository link'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Widget _buildSection(String title, String content, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(content, style: TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildLinkButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About the Developer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.1),
                        AppTheme.primaryColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text('👨‍💻', style: TextStyle(fontSize: 40)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'thetwodigiter',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Flutter Developer & Coffee Enthusiast',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: _buildSection(
                  '🎭 The Story Behind Divine Manager',
                  'As a regular customer at Cafe Divine, I witnessed firsthand the daily challenges they faced with manual inventory tracking and order management. Instead of just being another customer, I decided to create a custom solution tailored specifically for their unique needs and workflow.\n\nDivine Manager isn\'t a one-size-fits-all solution – it\'s a carefully crafted system designed around the specific requirements, menu, and operations of this particular coffee shop in my neighborhood.',
                  isDark,
                ),
              ),

              const SizedBox(height: 20),

              FadeInRight(
                delay: const Duration(milliseconds: 400),
                child: _buildSection(
                  '🛠️ Technical Skills',
                  'Flutter Development ⭐⭐⭐⭐⭐\nDart Programming ⭐⭐⭐⭐⭐\nUI/UX Design ⭐⭐⭐⭐\nState Management ⭐⭐⭐⭐\nAPI Integration ⭐⭐⭐⭐\nCoffee Brewing ⭐⭐⭐⭐⭐',
                  isDark,
                ),
              ),

              const SizedBox(height: 20),

              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryBrown),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '☕ Coffee Fueled Development',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _animateCoffee,
                        child: AnimatedBuilder(
                          animation: _coffeeAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _coffeeAnimation.value,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBrown.withValues(
                                    alpha: 0.2,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primaryBrown,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.local_cafe,
                                  size: 40,
                                  color: AppTheme.primaryBrown,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap for more caffeine!',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cups consumed during development: $_coffeeCount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              FadeInLeft(
                delay: const Duration(milliseconds: 800),
                child: _buildSection(
                  '📱 About Divine Manager',
                  'Divine Manager is a custom-built café management solution designed specifically for a local coffee shop. Rather than creating a generic system, every feature has been tailored to match their exact workflow, menu items, and business processes.\n\nThe app handles their specific inventory needs, order patterns, and provides analytics that matter to their daily operations. It\'s a personalized approach to café management technology.',
                  isDark,
                ),
              ),

              const SizedBox(height: 20),

              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🔗 Connect With Me',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildLinkButton(
                        icon: Icons.code,
                        label: 'GitHub Profile',
                        subtitle: '@iamthetwodigiter',
                        color: Colors.purple,
                        onTap: _launchGitHub,
                      ),

                      const SizedBox(height: 12),

                      _buildLinkButton(
                        icon: Icons.folder_open,
                        label: 'DivineManager Repo',
                        subtitle: 'View the source code',
                        color: AppTheme.primaryColor,
                        onTap: _launchRepo,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              FadeIn(
                delay: const Duration(milliseconds: 1200),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '⚠️ Disclaimer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This app is designed to enhance café operations and improve business efficiency. Features are continuously updated based on real-world usage and feedback from coffee shop owners.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '💝 Built with passion and precision',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
