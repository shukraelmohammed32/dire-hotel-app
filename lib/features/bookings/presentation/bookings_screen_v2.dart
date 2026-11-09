import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/customer_session.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/theme/rs_components.dart';
import '../../../../core/utils/price_formatter.dart';
import '../domain/booking.dart';
import 'controllers/bookings_controller.dart';
import 'payment_status_screen.dart';

class BookingsScreenV2 extends StatefulWidget {
  const BookingsScreenV2({
    super.key,
    this.controller,
  });

  final BookingsController? controller;

  @override
  State<BookingsScreenV2> createState() => _BookingsScreenV2State();
}

class _BookingsScreenV2State extends State<BookingsScreenV2> {
  late final BookingsController _controller;
  final _phoneInputController = TextEditingController();
  int _selectedTabIndex = 0; // 0 = Active, 1 = Past, 2 = Cancelled

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? BookingsController();

    final sessionPhone = CustomerSession.instance.phone;
    if (sessionPhone != null && sessionPhone.isNotEmpty) {
      _phoneInputController.text = sessionPhone;
      _controller.loadBookings(phone: sessionPhone);
    }
    // Auto-refresh every 30 s while the screen is open
    _controller.startPolling(intervalSeconds: 30);
  }

  @override
  void dispose() {
    _controller.stopPolling();
    _phoneInputController.dispose();
    super.dispose();
  }

  void _searchBookings() {
    final phone = _phoneInputController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your phone number to find your reservations.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
          ),
        ),
      );
      return;
    }
    CustomerSession.instance.setCustomer(phone: phone);
    _controller.loadBookings(phone: phone);
  }

  List<Booking> _getCurrentTabBookings() {
    switch (_selectedTabIndex) {
      case 0:
        return _controller.activeBookings;
      case 1:
        return _controller.pastBookings;
      case 2:
        return _controller.cancelledBookings;
      default:
        return _controller.activeBookings;
    }
  }

  Future<void> _confirmAndCancel(Booking booking) async {
    final reasonController = TextEditingController();
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Cancel Reservation?', style: RSTypography.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel booking ${booking.confirmationNo}?',
              style: RSTypography.bodyMedium,
            ),
            const SizedBox(height: RSSpacing.lg),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for cancellation (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RSSpacing.radiusInput),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Keep Booking'),
          ),
          RSButton(
            label: 'Confirm Cancellation',
            style: RSButtonStyle.outline,
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            semanticLabel: 'Confirm cancellation',
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusModal),
        ),
      ),
    );

    if (shouldCancel == true && mounted) {
      final success = await _controller.cancelBooking(
        confirmationNo: booking.confirmationNo,
        phone: booking.guestPhone,
        reason: reasonController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reservation ${booking.confirmationNo} cancelled.'),
              backgroundColor: RSColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
              ),
            ),
          );
        } else if (_controller.cancelError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_controller.cancelError!),
              backgroundColor: RSColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final currentBookings = _getCurrentTabBookings();
        final isLoading = _controller.isLoading;
        final error = _controller.errorMessage;
        final hasPhone = CustomerSession.instance.hasIdentity;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(RSSpacing.xl, RSSpacing.xl, RSSpacing.xl, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RSAnimatedFade(
                      child: Text(
                        'My Bookings',
                        style: RSTypography.displaySmall.copyWith(fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: RSSpacing.xs),
                    RSAnimatedFade(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        'Manage your reservations, view pricing breakdown & references.',
                        style: RSTypography.bodyMedium.copyWith(color: RSColors.muted),
                      ),
                    ),
                    const SizedBox(height: RSSpacing.lg),
                    _buildPhoneLookupHeader(hasPhone),
                  ],
                ),
              ),

              const SizedBox(height: RSSpacing.md),

              // ── Filter Tabs ───────────────────────────────────────────
              if (hasPhone) _buildFilterTabs(),

              // ── Content ───────────────────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (CustomerSession.instance.phone != null) {
                      await _controller.loadBookings();
                    }
                  },
                  color: RSColors.burgundy,
                  child: _buildBody(isLoading, error, currentBookings, hasPhone),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhoneLookupHeader(bool hasPhone) {
    return RSAnimatedSlide(
      begin: const Offset(0, 20),
      child: RSCard(
        variant: RSCardVariant.outlined,
        padding: const EdgeInsets.symmetric(horizontal: RSSpacing.md, vertical: RSSpacing.sm),
        child: Row(
          children: [
            const Icon(Icons.person_pin_circle_outlined, color: RSColors.burgundy, size: RSIconSizes.lg),
            const SizedBox(width: RSSpacing.md),
            Expanded(
              child: TextField(
                controller: _phoneInputController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter phone number (+251...)',
                  border: InputBorder.none,
                  isDense: true,
                  hintStyle: RSTypography.bodyMedium.copyWith(color: RSColors.mutedLight),
                ),
                onSubmitted: (_) => _searchBookings(),
              ),
            ),
            RSButton(
              label: 'Find',
              style: RSButtonStyle.tonal,
              size: RSButtonSize.small,
              onPressed: _searchBookings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return RSAnimatedSlide(
      begin: const Offset(0, 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: RSSpacing.xl),
        child: Container(
          decoration: BoxDecoration(
            color: RSColors.rose100,
            borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
          ),
          child: Row(
            children: [
              _tabButton(0, 'Active', _controller.activeBookings.length),
              _tabButton(1, 'Past', _controller.pastBookings.length),
              _tabButton(2, 'Cancelled', _controller.cancelledBookings.length),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(int index, String label, int count) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedTabIndex = index),
          borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: RSSpacing.md),
            decoration: BoxDecoration(
              color: isSelected ? RSColors.burgundy : Colors.transparent,
              borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: RSTypography.labelMedium.copyWith(
                    color: isSelected ? Colors.white : RSColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: RSSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: RSSpacing.sm, vertical: RSSpacing.xs),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.2) : RSColors.surface,
                    borderRadius: BorderRadius.circular(RSSpacing.radiusChip),
                  ),
                  child: Text(
                    count.toString(),
                    style: RSTypography.labelSmall.copyWith(
                      color: isSelected ? Colors.white : RSColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isLoading, String? error, List<Booking> bookings, bool hasPhone) {
    if (!hasPhone) {
      return _buildEmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Customer Verification Required',
        message: 'Enter your booking phone number above to access your verified reservations.',
      );
    }

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: RSColors.burgundy),
            SizedBox(height: RSSpacing.md),
            Text('Loading reservations...', style: TextStyle(color: RSColors.muted)),
          ],
        ),
      );
    }

    if (error != null) {
      return _buildErrorState(error);
    }

    if (bookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_border_rounded,
        title: _selectedTabIndex == 0
            ? 'No active reservations'
            : _selectedTabIndex == 1
                ? 'No past stays'
                : 'No cancelled reservations',
        message: 'Your confirmed Ras Hotel bookings will appear here.',
      );
    }

    return RSAnimatedSlide(
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(RSSpacing.xl, RSSpacing.md, RSSpacing.xl, RSSpacing.massive),
        itemCount: bookings.length,
        separatorBuilder: (_, _) => const SizedBox(height: RSSpacing.md),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return RSAnimatedSlide(
            delay: Duration(milliseconds: (index * 60).clamp(0, 300)),
            begin: const Offset(0, 20),
            child: _buildBookingCard(booking),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return ListView(
      padding: const EdgeInsets.all(RSSpacing.xl),
      children: [
        const SizedBox(height: RSSpacing.massive),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(RSSpacing.xxl),
                decoration: BoxDecoration(
                  color: RSColors.rose100,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: RSIconSizes.xxxl, color: RSColors.muted),
              ),
              const SizedBox(height: RSSpacing.lg),
              Text(
                title,
                style: RSTypography.titleLarge.copyWith(color: RSColors.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: RSSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: RSTypography.bodyMedium.copyWith(color: RSColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return ListView(
      padding: const EdgeInsets.all(RSSpacing.xl),
      children: [
        const SizedBox(height: RSSpacing.massive),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(RSSpacing.xxl),
                decoration: BoxDecoration(
                  color: RSColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded, size: RSIconSizes.xxxl, color: RSColors.error),
              ),
              const SizedBox(height: RSSpacing.lg),
              Text(
                'Error loading reservations',
                style: RSTypography.titleLarge.copyWith(color: RSColors.error),
              ),
              const SizedBox(height: RSSpacing.sm),
              Text(
                error,
                textAlign: TextAlign.center,
                style: RSTypography.bodyMedium.copyWith(color: RSColors.muted),
              ),
              const SizedBox(height: RSSpacing.lg),
              RSButton(
                label: 'Retry',
                icon: const Icon(Icons.refresh_rounded),
                style: RSButtonStyle.primary,
                onPressed: () => _controller.loadBookings(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(Booking booking) {
    RSBadgeVariant badgeVariant;

    switch (booking.status) {
      case 'CONFIRMED':
        badgeVariant = RSBadgeVariant.success;
        break;
      case 'CHECKED_IN':
        badgeVariant = RSBadgeVariant.info;
        break;
      case 'CANCELLED':
        badgeVariant = RSBadgeVariant.error;
        break;
      default:
        badgeVariant = RSBadgeVariant.warning;
    }

    return RSCard(
      variant: RSCardVariant.outlined,
      padding: const EdgeInsets.all(RSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Reference & Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    booking.confirmationNo,
                    style: RSTypography.titleMedium.copyWith(
                      color: RSColors.burgundy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: RSSpacing.sm),
                  RSIconButton(
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: booking.confirmationNo));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Reference copied!'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
                          ),
                        ),
                      );
                    },
                    size: RSIconButtonSize.small,
                    style: RSIconButtonStyle.ghost,
                    tooltip: 'Copy reference',
                  ),
                ],
              ),
              RSBadge(
                label: booking.status,
                variant: badgeVariant,
                size: RSBadgeSize.medium,
              ),
            ],
          ),

          const Divider(height: RSSpacing.xl, color: RSColors.divider),

          // Room info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
                child: Image.asset(
                  booking.room.imageAssetPath,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: RSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${booking.room.type} (Room ${booking.room.number})',
                      style: RSTypography.titleMedium.copyWith(
                        color: RSColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: RSSpacing.xs),
                    Text(
                      '${booking.checkInDate.day}/${booking.checkInDate.month} – ${booking.checkOutDate.day}/${booking.checkOutDate.month} (${booking.nights} ${booking.nights == 1 ? "night" : "nights"})',
                      style: RSTypography.bodySmall.copyWith(color: RSColors.muted),
                    ),
                    const SizedBox(height: RSSpacing.xs),
                    Text(
                      '${booking.adults} Adults${booking.children > 0 ? ", ${booking.children} Children" : ""}',
                      style: RSTypography.bodySmall.copyWith(color: RSColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: RSSpacing.lg),

          // Total & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total ETB (inc. VAT)',
                    style: RSTypography.labelSmall.copyWith(color: RSColors.muted),
                  ),
                  Text(
                    '${formatEtb(booking.totalEtb.round())} ETB',
                    style: RSTypography.priceMedium.copyWith(
                      color: RSColors.burgundy,
                    ),
                  ),
                ],
              ),
              if (booking.isCancellable)
                RSButton(
                  label: 'Cancel Stay',
                  icon: const Icon(Icons.cancel_outlined),
                  style: RSButtonStyle.outline,
                  size: RSButtonSize.small,
                  onPressed: () => _confirmAndCancel(booking),
                ),
            ],
          ),

          // Payment button
          if (booking.invoiceId != null &&
              booking.paymentAccessToken != null &&
              booking.invoiceStatus != 'PAID' &&
              booking.invoiceStatus != 'VOID' &&
              booking.invoiceStatus != 'REFUNDED') ...[
            const SizedBox(height: RSSpacing.md),
            RSButton(
              label: 'Pay or check payment status',
              icon: const Icon(Icons.lock_outline_rounded),
              style: RSButtonStyle.primary,
              fullWidth: true,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PaymentStatusScreen(booking: booking),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}