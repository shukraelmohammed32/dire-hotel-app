import 'package:flutter/material.dart';

import '../../../../core/theme/app_design_system.dart';
import '../../../../core/theme/rs_components.dart';
import '../../bookings/presentation/controllers/bookings_controller.dart';
import '../../dining/presentation/dining_reservation_flow_sheet.dart';
import '../../delivery/presentation/delivery_order_flow_sheet.dart';
import '../../events/presentation/event_booking_flow_sheet.dart';
import '../../shell/presentation/app_shell.dart';
import '../domain/room.dart';
import 'controllers/rooms_controller.dart';
import 'room_detail_screen.dart';
import 'room_list_screen.dart';
import 'widgets/room_card.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({
    super.key,
    this.controller,
    this.onNavigateToTab,
    this.bookingsController,
  });

  final RoomsController? controller;
  final NavigateToTabCallback? onNavigateToTab;
  final BookingsController? bookingsController;

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> {
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
              final horizontalPadding =
                  constraints.maxWidth < 380 ? RSSpacing.lg : RSSpacing.xl;
              return RefreshIndicator(
                onRefresh: () => _controller.loadRooms(refresh: true),
                color: RSColors.burgundy,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ── Top Bar ─────────────────────────────────────────
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        RSSpacing.lg,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(child: _buildTopBar(context)),
                    ),

                    // ── Hero Banner ─────────────────────────────────────
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        RSSpacing.xl,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(child: _buildHeroBanner(context)),
                    ),

                    // ── Search Card ─────────────────────────────────────
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        RSSpacing.xl,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(child: _buildSearchCard(context)),
                    ),

                    // ── Featured Stays Section ──────────────────────────
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        RSSpacing.xxxl,
                        horizontalPadding,
                        RSSpacing.md,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: RSSectionHeader(
                          title: 'Featured stays',
                          subtitle: 'Handpicked rooms for your visit',
                          action: _openAllRooms,
                          actionLabel: 'View all',
                          icon: const Icon(Icons.star_rounded),
                          style: RSSectionHeaderStyle.defaultStyle,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildFeaturedSection(horizontalPadding),
                    ),

                    // ── Quick Actions Section ───────────────────────────
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        RSSpacing.xxxl,
                        horizontalPadding,
                        RSSpacing.md,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: RSSectionHeader(
                          title: 'Quick Actions',
                          subtitle: 'Everything you need at a tap',
                          icon: const Icon(Icons.flash_on_rounded),
                          style: RSSectionHeaderStyle.defaultStyle,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildQuickActionsSection(horizontalPadding),
                    ),

                    // ── Bottom spacing ──────────────────────────────────
                    const SliverPadding(padding: EdgeInsets.only(bottom: RSSpacing.massive)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// TOP BAR
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildTopBar(BuildContext context) {
    return RSAnimatedSlide(
      begin: const Offset(0, -20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RSAnimatedFade(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Welcome back',
                    style: RSTypography.bodyMedium.copyWith(
                      color: RSColors.muted,
                    ),
                  ),
                ),
                const SizedBox(height: RSSpacing.xs),
                RSAnimatedFade(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Find your signature stay.',
                    style: RSTypography.displaySmall.copyWith(
                      fontSize: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
          RSAnimatedScale(
            delay: const Duration(milliseconds: 300),
            child: RSIconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: _showNotificationsPlaceholder,
              size: RSIconButtonSize.medium,
              style: RSIconButtonStyle.tonal,
              tooltip: 'Notifications',
              semanticLabel: 'Notifications',
            ),
          ),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// HERO BANNER
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildHeroBanner(BuildContext context) {
    return RSAnimatedSlide(
      delay: const Duration(milliseconds: 150),
      begin: const Offset(0, 30),
      child: RSCard(
        variant: RSCardVariant.elevated,
        padding: EdgeInsets.zero,
        borderRadius: RSSpacing.radiusXxxl,
        onTap: null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(RSSpacing.radiusXxxl),
          child: Stack(
            children: [
              // Background image
              Image.asset(
                'assets/images/hero_architecture.png',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                left: RSSpacing.xl,
                right: RSSpacing.xl,
                bottom: RSSpacing.xl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RSAnimatedFade(
                      delay: const Duration(milliseconds: 250),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: RSSpacing.md,
                          vertical: RSSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: RSColors.rose100,
                          borderRadius: BorderRadius.circular(RSSpacing.radiusChip),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: RSColors.burgundy,
                              size: RSIconSizes.sm,
                            ),
                            const SizedBox(width: RSSpacing.xs),
                            Text(
                              'Ras Hotel • Dire Dawa',
                              style: RSTypography.labelMedium.copyWith(
                                color: RSColors.burgundy,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: RSSpacing.md),
                    RSAnimatedFade(
                      delay: const Duration(milliseconds: 350),
                      child: Text(
                        'Elegant comfort,\ncurated for city stays.',
                        style: RSTypography.displaySmall.copyWith(
                          color: Colors.white,
                          fontSize: 30,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// SEARCH CARD
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildSearchCard(BuildContext context) {
    final dates = _controller.selectedDates;
    final dateText = dates == null
        ? 'Choose dates'
        : '${dates.start.day}/${dates.start.month} - ${dates.end.day}/${dates.end.month}';

    final availability = _controller.availabilityResult;
    final isChecking = _controller.isCheckingAvailability;
    final availabilityError = _controller.availabilityError;

    return RSAnimatedSlide(
      delay: const Duration(milliseconds: 300),
      begin: const Offset(0, 30),
      child: RSCard(
        variant: RSCardVariant.outlined,
        padding: const EdgeInsets.all(RSSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Guest selectors
            Row(
              children: [
                Expanded(
                  child: _SelectionButtonV2(
                    icon: Icons.calendar_month_outlined,
                    title: 'Dates',
                    value: dateText,
                    onTap: _pickDates,
                    enabled: !isChecking,
                  ),
                ),
                const SizedBox(width: RSSpacing.md),
                Expanded(
                  child: _SelectionButtonV2(
                    icon: Icons.people_outline_rounded,
                    title: 'Guests',
                    value: '${_controller.guestsCount} guests',
                    onTap: _openGuestSelector,
                    enabled: !isChecking,
                  ),
                ),
              ],
            ),

            const SizedBox(height: RSSpacing.lg),

            // Search button
            RSButton(
              label: isChecking ? 'Checking availability...' : 'Check availability & rooms',
              icon: isChecking
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(RSColors.onPrimary),
                      ),
                    )
                  : const Icon(Icons.search_rounded),
              style: RSButtonStyle.primary,
              size: RSButtonSize.large,
              fullWidth: true,
              onPressed: isChecking ? null : _handleSearch,
              isLoading: isChecking,
            ),

            // Availability banner
            if (availability != null || availabilityError != null) ...[
              const SizedBox(height: RSSpacing.md),
              _buildAvailabilityBanner(availability, availabilityError),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityBanner(dynamic availability, String? error) {
    if (error != null) {
      return RSCard(
        variant: RSCardVariant.filled,
        padding: const EdgeInsets.all(RSSpacing.md),
        color: RSColors.errorLight,
        borderColor: RSColors.error.withValues(alpha: 0.3),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: RSColors.error,
              size: RSIconSizes.md,
            ),
            const SizedBox(width: RSSpacing.sm),
            Expanded(
              child: Text(
                error,
                style: RSTypography.bodySmall.copyWith(
                  color: RSColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bool hasRooms = availability.hasAvailableRooms;
    return RSCard(
      variant: RSCardVariant.filled,
      padding: const EdgeInsets.all(RSSpacing.md),
      color: hasRooms ? RSColors.successLight : RSColors.warningLight,
      borderColor: hasRooms
          ? RSColors.success.withValues(alpha: 0.3)
          : RSColors.warning.withValues(alpha: 0.3),
      child: Row(
        children: [
          Icon(
            hasRooms ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
            color: hasRooms ? RSColors.success : RSColors.warning,
            size: RSIconSizes.md,
          ),
          const SizedBox(width: RSSpacing.sm),
          Expanded(
            child: Text(
              availability.message,
              style: RSTypography.bodySmall.copyWith(
                color: hasRooms ? RSColors.success : RSColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (hasRooms)
            RSButton(
              label: 'View rooms',
              style: RSButtonStyle.tonal,
              size: RSButtonSize.small,
              onPressed: () => _openFilteredRooms(availability.rooms),
            ),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// FEATURED ROOMS SECTION
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildFeaturedSection(double horizontalPadding) {
    if (_controller.isLoading && _controller.rooms.isEmpty) {
      return _buildLoadingState();
    }

    if (_controller.errorMessage != null && _controller.rooms.isEmpty) {
      return _buildErrorState();
    }

    final rooms = _controller.featuredRooms;
    if (rooms.isEmpty) {
      return _buildEmptyState();
    }

    return RSStaggeredList(
      itemDelay: const Duration(milliseconds: 100),
      maxDelay: const Duration(milliseconds: 400),
      children: [
        SizedBox(
          height: 340,
          child: ListView.builder(
            padding: EdgeInsets.only(left: horizontalPadding),
            scrollDirection: Axis.horizontal,
            itemCount: rooms.length,
            itemBuilder: (_, index) {
              final room = rooms[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == rooms.length - 1 ? horizontalPadding : 0,
                ),
                child: RoomCard(
                  room: room,
                  onTap: () => _openRoom(room),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 320,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: RSColors.burgundy),
            const SizedBox(height: RSSpacing.md),
            Text(
              'Loading hotel rooms...',
              style: RSTypography.bodyMedium.copyWith(color: RSColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 0), // Handled by parent
      padding: const EdgeInsets.all(RSSpacing.xl),
      child: RSCard(
        variant: RSCardVariant.outlined,
        padding: const EdgeInsets.all(RSSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hotel_outlined, size: 48, color: RSColors.muted),
            const SizedBox(height: RSSpacing.md),
            Text(
              'Rooms unavailable right now.',
              textAlign: TextAlign.center,
              style: RSTypography.bodyMedium.copyWith(color: RSColors.ink),
            ),
            const SizedBox(height: RSSpacing.lg),
            RSButton(
              label: 'Retry',
              icon: const Icon(Icons.refresh_rounded),
              style: RSButtonStyle.primary,
              onPressed: () => _controller.loadRooms(refresh: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 180,
      margin: EdgeInsets.symmetric(horizontal: 0),
      alignment: Alignment.center,
      child: Text(
        'No rooms currently available',
        style: RSTypography.bodyMedium.copyWith(color: RSColors.muted),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// QUICK ACTIONS SECTION
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildQuickActionsSection(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: RSStaggeredList(
        itemDelay: const Duration(milliseconds: 80),
        maxDelay: const Duration(milliseconds: 350),
        children: [
          Row(
            children: [
              Expanded(
                child: _QuickActionCardV2(
                  icon: Icons.restaurant_outlined,
                  title: 'Reserve a Table',
                  subtitle: 'Ras Restaurant & Bar',
                  color: const Color(0xFF8B0000),
                  onTap: _openDiningReservation,
                ),
              ),
              const SizedBox(width: RSSpacing.md),
              Expanded(
                child: _QuickActionCardV2(
                  icon: Icons.event_outlined,
                  title: 'Plan an Event',
                  subtitle: 'Ras Hotel Events',
                  color: const Color(0xFF5D3A1A),
                  onTap: _openEventBooking,
                ),
              ),
            ],
          ),
          const SizedBox(height: RSSpacing.md),
          Row(
            children: [
              Expanded(
                child: _QuickActionCardV2(
                  icon: Icons.delivery_dining_outlined,
                  title: 'Order Delivery',
                  subtitle: 'Food to your door',
                  color: const Color(0xFF1B5E20),
                  onTap: _openDeliveryOrder,
                ),
              ),
              const SizedBox(width: RSSpacing.md),
              Expanded(
                child: _QuickActionCardV2(
                  icon: Icons.spa_outlined,
                  title: 'Spa & Wellness',
                  subtitle: 'Relax & rejuvenate',
                  color: const Color(0xFF0D47A1),
                  onTap: _openSpaPlaceholder,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// ACTION HANDLERS
  /// ═══════════════════════════════════════════════════════════════════════

  void _openDiningReservation() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DiningReservationFlowSheet(),
    );
  }

  void _openEventBooking() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EventBookingFlowSheet(),
    );
  }

  void _openDeliveryOrder() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DeliveryOrderFlowSheet(),
    );
  }

  void _openSpaPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Spa bookings coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
        ),
      ),
    );
  }

  void _showNotificationsPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('No new notifications.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
        ),
      ),
    );
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _controller.selectedDates,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: RSColors.burgundy,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
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
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RSSpacing.radiusSheet),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(RSSpacing.xl, RSSpacing.sm, RSSpacing.xl, RSSpacing.xxxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Guests',
                  style: RSTypography.titleLarge,
                ),
                const SizedBox(height: RSSpacing.lg),
                Wrap(
                  spacing: RSSpacing.sm,
                  runSpacing: RSSpacing.sm,
                  children: [1, 2, 3, 4, 6].map((count) {
                    final isSelected = _controller.guestsCount == count;
                    return RSChip(
                      label: '$count ${count == 1 ? "Guest" : "Guests"}',
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
                      style: RSChipStyle.choice,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
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

/// ════════════════════════════════════════════════════════════════════════
/// SELECTION BUTTON V2
/// ═══════════════════════════════════════════════════════════════════════

class _SelectionButtonV2 extends StatelessWidget {
  const _SelectionButtonV2({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(RSSpacing.radiusInput),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: RSSpacing.md,
            vertical: RSSpacing.md,
          ),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(RSSpacing.radiusInput),
            border: Border.all(
              color: enabled ? theme.colorScheme.outline : theme.colorScheme.outlineVariant,
              width: RSBorders.thin,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: enabled ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                size: RSIconSizes.md,
              ),
              const SizedBox(width: RSSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: RSTypography.labelSmall.copyWith(
                        color: enabled
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: RSSpacing.xs),
                    Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: RSTypography.titleSmall.copyWith(
                        color: enabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: enabled ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                size: RSIconSizes.md,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// QUICK ACTION CARD V2
/// ════════════════════════════════════════════════════════════════════════

class _QuickActionCardV2 extends StatelessWidget {
  const _QuickActionCardV2({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RSSpacing.radiusCard),
        child: RSCard(
          variant: RSCardVariant.elevated,
          padding: const EdgeInsets.all(RSSpacing.lg),
          elevation: 2,
          borderRadius: RSSpacing.radiusCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(RSSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
                ),
                child: Icon(icon, color: Colors.white, size: RSIconSizes.xl),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: RSTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: RSSpacing.xs),
                  Text(
                    subtitle,
                    style: RSTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
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