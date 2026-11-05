import 'package:finalrahman/features/portal/portal_controller.dart';
import 'package:finalrahman/ui/fees/fees_screen.dart';
import 'package:finalrahman/ui/home/home_screen.dart';
import 'package:finalrahman/ui/profile/profile_screen.dart';
import 'package:finalrahman/ui/results/results_screen.dart';
import 'package:finalrahman/ui/shell/shell_scope.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _openTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final student = context.watch<PortalController>().selected;
    return ShellScope(
      openTab: _openTab,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(key: ValueKey('home-${student?.id}')),
            FeesScreen(key: ValueKey('fees-${student?.id}')),
            ResultsScreen(key: ValueKey('results-${student?.id}')),
            ProfileScreen(key: ValueKey('profile-${student?.id}')),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _openTab,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Fees',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: 'Results',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
