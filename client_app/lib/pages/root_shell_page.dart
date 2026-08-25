import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home/home_page.dart';
import '../pages/savings/savings_hub_page.dart';
import '../pages/analytics/analytics_page.dart';
import '../pages/reminders/reminders_page.dart';
import '../pages/profile/profile_page.dart';
import '../theme/app_colors.dart';

class RootShellPage extends StatefulWidget {
  const RootShellPage({super.key});

  @override
  State<RootShellPage> createState() => _RootShellPageState();
}

class _RootShellPageState extends State<RootShellPage> {
  int _currentIndex = 0;

  final _pages = const [
    HomePage(),
    SavingsHubPage(),
    AnalyticsPage(),
    RemindersPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/chat'),
        backgroundColor: AppColors.acidMint,
        foregroundColor: AppColors.accentText,
        child: const Icon(Icons.smart_toy_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.savings_outlined), selectedIcon: Icon(Icons.savings_rounded), label: 'Savings'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights_rounded), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}