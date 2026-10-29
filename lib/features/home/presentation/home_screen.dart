import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../bookings/presentation/controllers/bookings_controller.dart';
import '../../shell/presentation/app_shell.dart';
import '../domain/room.dart';
import 'controllers/rooms_controller.dart';
import 'room_detail_screen.dart';
import 'room_list_screen.dart';
import 'widgets/room_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.controller,
    this.onNavigateToTab,
    this.bookingsController,
  });

  final RoomsController? controller;
  /// Callback that lets this screen request a tab switch in AppShell.
  final NavigateToTabCallback? onNavigateToTab;
  /// Shared BookingsController so booking success triggers an immediate reload.
  final BookingsController? bookingsController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final RoomsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RoomsController();
    _controller.loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 380 ? 18.0 : 24.0;
              return RefreshIndicator(
                onRefresh: () => _controller.loadRooms(refresh: true),
                color: AppColors.burgundy,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 18, horizontalPadding, 0),
                      sliver: SliverToBoxAdapter(child: _buildTopRow(context)),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
                      sliver: SliverToBoxAdapter(child: _buildHeroBanner(context)),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 18, horizontalPadding, 0),
                      sliver: SliverToBoxAdapter(child: _buildSearchCard(context)),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 28, horizontalPadding, 12),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Text(
                              'Featured stays',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontFamily: 'serif',
                                    fontSize: 24,
                                  ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _openAllRooms,
                              child: const Text('View all'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildFeaturedSection(horizontalPadding),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 28)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 6),
              Text(
                'Find your signature stay.',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontFamily: 'serif',
                      fontSize: 34,
                    ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: _showNotificationsPlaceholder,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.blush,
            foregroundColor: AppColors.burgundy,
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          Image.asset(
            'assets/images/hero_architecture.png',
            height: 210,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: .16),
                    Colors.black.withValues(alpha: .62),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ras Hotel • Dire Dawa',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elegant comfort, curated for city stays.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontFamily: 'serif',
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    final dates = _controller.selectedDates;
    final dateText = dates == null
        ? 'Choose dates'
        : '${dates.start.day}/${dates.start.month} - ${dates.end.day}/${dates.end.month}';

    final availability = _controller.availabilityResult;
    final isChecking = _controller.isCheckingAvailability;
    final availabilityError = _controller.availabilityError;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SelectionButton(
                  icon: Icons.calendar_month_outlined,
                  title: 'Dates',
                  value: dateText,
                  onTap: _pickDates,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelectionButton(
                  icon: Icons.people_outline_rounded,
                  title: 'Guests',
                  value: '${_controller.guestsCount} guests',
                  onTap: _openGuestSelector,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isChecking ? null : _handleSearch,
              icon: isChecking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.search_rounded),
              label: Text(isChecking ? 'Checking availability...' : 'Check availability & rooms'),
            ),
          ),
          if (availability != null || availabilityError != null) ...[
            const SizedBox(height: 12),
            _buildAvailabilityBanner(availability, availabilityError),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityBanner(dynamic availability, String? error) {
    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red.shade900, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final bool hasRooms = availability.hasAvailableRooms;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasRooms ? const Color(0xFFF3F7F2) : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasRooms ? const Color(0xFFC7DBC5) : Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(
            hasRooms ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
            color: hasRooms ? const Color(0xFF2E7D32) : Colors.amber.shade800,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              availability.message,
              style: TextStyle(
                color: hasRooms ? const Color(0xFF1B5E20) : Colors.amber.shade900,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (hasRooms)
            TextButton(
              onPressed: () => _openFilteredRooms(availability.rooms),
              child: const Text('View rooms', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(double horizontalPadding) {
    if (_controller.isLoading && _controller.rooms.isEmpty) {
      return SizedBox(
        height: 320,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.burgundy),
              const SizedBox(height: 12),
              Text('Loading hotel rooms...', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    if (_controller.errorMessage != null && _controller.rooms.isEmpty) {
      return Container(
        height: 200,
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hotel_outlined, size: 36, color: AppColors.muted),
            const SizedBox(height: 8),
            const Text(
              'Rooms unavailable right now.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.ink, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _controller.loadRooms(refresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final rooms = _controller.featuredRooms;
    if (rooms.isEmpty) {
      return Container(
        height: 180,
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        alignment: Alignment.center,
        child: const Text('No rooms currently available', style: TextStyle(color: AppColors.muted)),
      );
    }

    return SizedBox(
      height: 320,
      child: ListView.builder(
        padding: EdgeInsets.only(left: horizontalPadding),
        scrollDirection: Axis.horizontal,
        itemCount: rooms.length,
        itemBuilder: (_, index) {
          final room = rooms[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 350 + (index * 120)),
            tween: Tween(begin: .95, end: 1),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: Opacity(opacity: value, child: child),
            ),
            child: RoomCard(
              room: room,
              onTap: () => _openRoom(room),
            ),
          );
        },
      ),
    );
  }

  void _showNotificationsPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No new notifications.')),
    );
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _controller.selectedDates,
    );
    if (picked != null) {
      _controller.setDates(picked);
      await _controller.checkAvailability(picked);
    }
  }

  void _openGuestSelector() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Guests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: [1, 2, 3, 4, 6].map((count) {
                final isSelected = _controller.guestsCount == count;
                return ChoiceChip(
                  label: Text('$count ${count == 1 ? "Guest" : "Guests"}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _controller.setGuests(count);
                      Navigator.of(sheetContext).pop();
                      if (_controller.selectedDates != null) {
                        _controller.checkAvailability(_controller.selectedDates!);
                      }
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearch() {
    if (_controller.selectedDates == null) {
      _pickDates();
    } else {
      _controller.checkAvailability(_controller.selectedDates!);
    }
  }

  void _openAllRooms() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoomListScreen(
          initialController: _controller,
          onNavigateToTab: widget.onNavigateToTab,
          bookingsController: widget.bookingsController,
        ),
      ),
    );
  }

  void _openFilteredRooms(List<Room> rooms) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoomListScreen(
          initialRooms: rooms,
          initialController: _controller,
          onNavigateToTab: widget.onNavigateToTab,
          bookingsController: widget.bookingsController,
        ),
      ),
    );
  }

  void _openRoom(Room room) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoomDetailScreen(
          room: room,
          onNavigateToTab: widget.onNavigateToTab,
          bookingsController: widget.bookingsController,
        ),
      ),
    );
  }
}

class _SelectionButton extends StatelessWidget {
  const _SelectionButton({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.burgundy, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.ink,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
