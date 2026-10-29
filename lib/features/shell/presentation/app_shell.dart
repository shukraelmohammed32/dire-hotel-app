import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../bookings/presentation/bookings_screen.dart';
import '../../bookings/presentation/controllers/bookings_controller.dart';
import '../../discover/presentation/discover_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../profile/presentation/profile_screen.dart';

/// Callback type given to child screens so they can request a tab switch
/// (and optional post-switch action) without knowing about AppShell directly.
typedef NavigateToTabCallback = void Function(int tabIndex, {VoidCallback? afterSwitch});

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  /// Single BookingsController instance shared across the shell so that a
  /// successful booking in HomeScreen / RoomDetailScreen can trigger a reload
  /// in the Bookings tab without rebuilding or re-creating anything.
  final BookingsController _bookingsController = BookingsController();

  /// Switches to [tabIndex] and, after the frame settles, fires [afterSwitch].
  void _navigateToTab(int tabIndex, {VoidCallback? afterSwitch}) {
    setState(() => _selectedIndex = tabIndex);
    if (afterSwitch != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => afterSwitch());
    }
  }

  @override
  void dispose() {
    _bookingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToTab: _navigateToTab, bookingsController: _bookingsController),
      const DiscoverScreen(),
      BookingsScreen(controller: _bookingsController),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: IndexedStack(index: _selectedIndex, children: screens),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.blush,
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
