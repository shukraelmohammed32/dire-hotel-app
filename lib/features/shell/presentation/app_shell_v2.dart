import 'package:flutter/material.dart';

import '../../../core/theme/app_design_system.dart';
import '../../bookings/presentation/bookings_screen_v2.dart';
import '../../bookings/presentation/controllers/bookings_controller.dart';
import '../../dining/presentation/dining_reservations_screen.dart';
import '../../dining/presentation/controllers/dining_reservations_controller.dart';
import '../../delivery/presentation/delivery_orders_screen.dart';
import '../../delivery/presentation/controllers/delivery_orders_controller.dart';
import '../../discover/presentation/discover_screen.dart';
import '../../events/presentation/event_bookings_screen.dart';
import '../../events/presentation/controllers/event_bookings_controller.dart';
import '../../home/presentation/home_screen_v2.dart';
import '../../menu/presentation/menu_screen_v2.dart';
import '../../profile/presentation/profile_screen.dart';

/// Callback type given to child screens so they can request a tab switch
/// (and optional post-switch action) without knowing about AppShell directly.
typedef NavigateToTabCallback = void Function(int tabIndex, {VoidCallback? afterSwitch});

class AppShellV2 extends StatefulWidget {
  const AppShellV2({super.key});

  @override
  State<AppShellV2> createState() => _AppShellV2State();
}

class _AppShellV2State extends State<AppShellV2> {
  int _selectedIndex = 0;

  /// Single controller instances shared across the shell
  final BookingsController _bookingsController = BookingsController();
  final DiningReservationsController _diningController = DiningReservationsController();
  final EventBookingsController _eventsController = EventBookingsController();
  final DeliveryOrdersController _deliveryController = DeliveryOrdersController();

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
    _diningController.dispose();
    _eventsController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreenV2(onNavigateToTab: _navigateToTab, bookingsController: _bookingsController),
      const DiscoverScreen(),
      const MenuScreenV2(),
      BookingsScreenV2(controller: _bookingsController),
      DiningReservationsScreen(controller: _diningController),
      EventBookingsScreen(controller: _eventsController),
      DeliveryOrdersScreen(controller: _deliveryController),
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
        surfaceTintColor: Colors.transparent,
        indicatorColor: RSColors.rose100,
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_rounded),
            selectedIcon: const Icon(Icons.search_rounded),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu_outlined),
            selectedIcon: const Icon(Icons.restaurant_menu_rounded),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_note_outlined),
            selectedIcon: const Icon(Icons.event_note_rounded),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_outlined),
            selectedIcon: const Icon(Icons.restaurant_rounded),
            label: 'Dining',
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event_rounded),
            label: 'Events',
          ),
          NavigationDestination(
            icon: const Icon(Icons.delivery_dining_outlined),
            selectedIcon: const Icon(Icons.delivery_dining_rounded),
            label: 'Delivery',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}