import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/theme/rs_components.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../bookings/presentation/booking_flow_sheet.dart';
import '../../bookings/presentation/controllers/bookings_controller.dart';
import '../../shell/presentation/app_shell.dart';
import '../domain/room.dart';

class RoomDetailScreenV2 extends StatefulWidget {
  const RoomDetailScreenV2({
    required this.room,
    super.key,
    this.apiClient,
    this.onNavigateToTab,
    this.bookingsController,
  });

  final Room room;
  final ApiClient? apiClient;
  final NavigateToTabCallback? onNavigateToTab;
  final BookingsController? bookingsController;

  @override
  State<RoomDetailScreenV2> createState() => _RoomDetailScreenV2State();
}

class _RoomDetailScreenV2State extends State<RoomDetailScreenV2> {
  late final ApiClient _apiClient;
  DateTimeRange? _selectedDates;
  bool _isCheckingAvailability = false;
  bool? _isAvailableForDates;
  String? _availabilityMessage;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();
  }

  Future<void> _checkAvailability(DateTimeRange dates) async {
    setState(() {
      _selectedDates = dates;
      _isCheckingAvailability = true;
      _isAvailableForDates = null;
      _availabilityMessage = null;
    });

    try {
      final result = await _apiClient.checkAvailability(
        checkIn: dates.start,
        checkOut: dates.end,
        roomId: widget.room.id,
      );

      final isAvailable = result.rooms.any((r) => r.id == widget.room.id);
      if (mounted) {
        setState(() {
          _isAvailableForDates = isAvailable;
          _availabilityMessage = isAvailable
              ? 'Room is available for ${dates.start.day}/${dates.start.month} - ${dates.end.day}/${dates.end.month}!'
              : 'Room is already booked or reserved for those dates.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAvailableForDates = widget.room.isAvailable;
          _availabilityMessage = widget.room.isAvailable
              ? 'Room is currently listed as Available.'
              : 'Room is currently marked as ${widget.room.status}.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingAvailability = false);
      }
    }
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _selectedDates,
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
      await _checkAvailability(picked);
    }
  }

  void _openBookingSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingFlowSheet(
        room: widget.room,
        initialDates: _selectedDates,
        apiClient: _apiClient,
        onBookingSuccess: (booking) {
          if (_selectedDates != null) {
            _checkAvailability(_selectedDates!);
          }
          widget.onNavigateToTab?.call(2, afterSwitch: () {
            widget.bookingsController?.onBookingCreated(phone: booking.guestPhone);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          // ── Hero Image with App Bar ───────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'room-photo-${room.id}',
                    child: Image.asset(room.imageAssetPath, fit: BoxFit.cover),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Badge overlay
                  Positioned(
                    top: RSSpacing.xl + MediaQuery.of(context).padding.top,
                    left: RSSpacing.xl,
                    child: RSAnimatedFade(
                      delay: const Duration(milliseconds: 200),
                      child: RSBadge(
                        label: room.badge,
                        variant: RSBadgeVariant.primary,
                        size: RSBadgeSize.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: RSAnimatedFade(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.all(RSSpacing.sm),
                child: RSIconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  size: RSIconButtonSize.medium,
                  style: RSIconButtonStyle.ghost,
                ),
              ),
            ),
            actions: [
              RSAnimatedFade(
                delay: const Duration(milliseconds: 150),
                child: Padding(
                  padding: const EdgeInsets.all(RSSpacing.sm),
                  child: RSIconButton(
                    icon: const Icon(Icons.favorite_border_rounded),
                    onPressed: () {}, // TODO: Add to favorites
                    size: RSIconButtonSize.medium,
                    style: RSIconButtonStyle.ghost,
                    tooltip: 'Add to favorites',
                    semanticLabel: 'Add to favorites',
                  ),
                ),
              ),
            ],
          ),

          // ── Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: RSAnimatedSlide(
              begin: const Offset(0, 30),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  RSSpacing.xl,
                  RSSpacing.xl,
                  RSSpacing.xl,
                  RSSpacing.massive,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badges row
                    _buildStatusRow(context),

                    const SizedBox(height: RSSpacing.lg),

                    // Room name
                    RSAnimatedFade(
                      delay: const Duration(milliseconds: 250),
                      child: Text(
                        room.name,
                        style: RSTypography.displaySmall.copyWith(
                          fontSize: 32,
                        ),
                      ),
                    ),

                    const SizedBox(height: RSSpacing.sm),

                    // Description
                    RSAnimatedFade(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        room.description,
                        style: RSTypography.bodyLarge.copyWith(
                          color: RSColors.onSurfaceVariant,
                        ),
                      ),
                    ),

                    const SizedBox(height: RSSpacing.xl),

                    // Info pills
                    RSAnimatedSlide(
                      delay: const Duration(milliseconds: 350),
                      begin: const Offset(0, 20),
                      child: Wrap(
                        spacing: RSSpacing.sm,
                        runSpacing: RSSpacing.sm,
                        children: [
                          _InfoPillV2(icon: Icons.people_outline_rounded, value: '${room.capacity} guests'),
                          _InfoPillV2(icon: Icons.space_dashboard_outlined, value: '${room.sizeInSquareMeters} m²'),
                          _InfoPillV2(icon: Icons.layers_outlined, value: 'Floor ${room.floor}'),
                          if (room.number.isNotEmpty)
                            _InfoPillV2(icon: Icons.meeting_room_outlined, value: 'Room ${room.number}'),
                        ],
                      ),
                    ),

                    const SizedBox(height: RSSpacing.xxxl),

                    // Nightly rate card
                    RSAnimatedSlide(
                      delay: const Duration(milliseconds: 400),
                      begin: const Offset(0, 20),
                      child: _buildRateCard(context),
                    ),

                    const SizedBox(height: RSSpacing.lg),

                    // Availability check card
                    RSAnimatedSlide(
                      delay: const Duration(milliseconds: 450),
                      begin: const Offset(0, 20),
                      child: _buildAvailabilityCard(context),
                    ),

                    const SizedBox(height: RSSpacing.xl),

                    // Book button
                    RSAnimatedScale(
                      delay: const Duration(milliseconds: 500),
                      child: RSButton(
                        label: 'Book this room',
                        icon: const Icon(Icons.arrow_forward_rounded),
                        style: RSButtonStyle.primary,
                        size: RSButtonSize.large,
                        fullWidth: true,
                        onPressed: _openBookingSheet,
                      ),
                    ),

                    const SizedBox(height: RSSpacing.lg),

                    // Trust indicators
                    _buildTrustIndicators(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// STATUS ROW
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildStatusRow(BuildContext context) {
    final room = widget.room;
    return Row(
      children: [
        RSBadge(
          label: room.badge,
          variant: RSBadgeVariant.primary,
          size: RSBadgeSize.medium,
        ),
        const SizedBox(width: RSSpacing.sm),
        RSBadge(
          label: room.status,
          variant: room.isAvailable ? RSBadgeVariant.success : RSBadgeVariant.error,
          size: RSBadgeSize.medium,
          icon: Icon(
            room.isAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: RSIconSizes.sm,
          ),
        ),
        const Spacer(),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: RSColors.gold, size: RSIconSizes.md),
            const SizedBox(width: RSSpacing.xs),
            Text(
              room.rating.toStringAsFixed(1),
              style: RSTypography.titleMedium.copyWith(
                color: RSColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// RATE CARD
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildRateCard(BuildContext context) {
    final room = widget.room;
    return RSCard(
      variant: RSCardVariant.outlined,
      padding: const EdgeInsets.all(RSSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nightly rate',
                  style: RSTypography.labelMedium.copyWith(
                    color: RSColors.muted,
                  ),
                ),
                const SizedBox(height: RSSpacing.xs),
                Text(
                  '${formatEtb(room.pricePerNight)} ETB',
                  style: RSTypography.priceLarge.copyWith(fontSize: 28),
                ),
              ],
            ),
          ),
          Container(
            height: 56,
            width: 1,
            color: RSColors.border,
          ),
          const SizedBox(width: RSSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total (est.)',
                style: RSTypography.labelMedium.copyWith(
                  color: RSColors.muted,
                ),
              ),
              const SizedBox(height: RSSpacing.xs),
              Text(
                '${formatEtb((room.pricePerNight * 3).round())} ETB',
                style: RSTypography.priceMedium.copyWith(
                  color: RSColors.burgundy,
                ),
              ),
              Text(
                '3 nights • incl. VAT',
                style: RSTypography.caption.copyWith(
                  color: RSColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// AVAILABILITY CARD
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildAvailabilityCard(BuildContext context) {
    return RSCard(
      variant: RSCardVariant.tonal,
      padding: const EdgeInsets.all(RSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: RSIconSizes.md,
                color: RSColors.burgundy,
              ),
              const SizedBox(width: RSSpacing.sm),
              Text(
                'Check dates availability',
                style: RSTypography.titleMedium.copyWith(
                  color: RSColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              RSButton(
                label: _selectedDates == null ? 'Select dates' : 'Change dates',
                style: RSButtonStyle.outline,
                size: RSButtonSize.small,
                onPressed: _pickDates,
              ),
            ],
          ),
          if (_isCheckingAvailability) ...[
            const SizedBox(height: RSSpacing.md),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: RSColors.burgundy),
                ),
                const SizedBox(width: RSSpacing.sm),
                Text(
                  'Checking availability…',
                  style: RSTypography.bodySmall.copyWith(color: RSColors.muted),
                ),
              ],
            ),
          ] else if (_availabilityMessage != null) ...[
            const SizedBox(height: RSSpacing.md),
            Row(
              children: [
                Icon(
                  _isAvailableForDates == true
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: RSIconSizes.sm,
                  color: _isAvailableForDates == true ? RSColors.success : RSColors.error,
                ),
                const SizedBox(width: RSSpacing.xs),
                Expanded(
                  child: Text(
                    _availabilityMessage!,
                    style: RSTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _isAvailableForDates == true
                          ? RSColors.success
                          : RSColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// TRUST INDICATORS
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildTrustIndicators(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _TrustIndicator(icon: Icons.verified_rounded, label: 'Verified'),
        _TrustIndicator(icon: Icons.shield_rounded, label: 'Secure booking'),
        _TrustIndicator(icon: Icons.support_agent_rounded, label: '24/7 support'),
        _TrustIndicator(icon: Icons.cancel_outlined, label: 'Free cancellation'),
      ],
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// INFO PILL V2
/// ════════════════════════════════════════════════════════════════════════

class _InfoPillV2 extends StatelessWidget {
  const _InfoPillV2({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RSSpacing.md,
        vertical: RSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: RSColors.rose100,
        borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
        border: Border.all(color: RSColors.border, width: RSBorders.thin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: RSIconSizes.sm, color: RSColors.burgundy),
          const SizedBox(width: RSSpacing.xs),
          Text(
            value,
            style: RSTypography.bodyMedium.copyWith(color: RSColors.ink),
          ),
        ],
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// TRUST INDICATOR
/// ════════════════════════════════════════════════════════════════════════

class _TrustIndicator extends StatelessWidget {
  const _TrustIndicator({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(RSSpacing.md),
          decoration: BoxDecoration(
            color: RSColors.rose100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: RSColors.burgundy, size: RSIconSizes.md),
        ),
        const SizedBox(height: RSSpacing.xs),
        Text(
          label,
          style: RSTypography.caption.copyWith(
            color: RSColors.muted,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}