import 'package:flutter/material.dart';
import '../pages/home/home_page.dart';
import '../pages/savings/savings_hub_page.dart';

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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.savings_outlined), selectedIcon: Icon(Icons.savings_rounded), label: 'Savings'),
        ],
      ),
    );
  }
}