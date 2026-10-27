import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/services/customer_session.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import '../domain/booking.dart';
import 'controllers/bookings_controller.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({
    super.key,
    this.controller,
  });

  final BookingsController? controller;

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
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
        const SnackBar(content: Text('Please enter your phone number to find your reservations.')),
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
        title: const Text('Cancel Reservation?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel booking ${booking.confirmationNo}?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Keep Booking'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Confirm Cancellation'),
          ),
        ],
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
              backgroundColor: Colors.green.shade800,
            ),
          );
        } else if (_controller.cancelError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_controller.cancelError!),
              backgroundColor: Colors.red.shade800,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Bookings',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontFamily: 'serif',
                            fontSize: 32,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage your reservations, view pricing breakdown & references.',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    _buildPhoneLookupHeader(hasPhone),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (hasPhone) _buildFilterTabs(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (CustomerSession.instance.phone != null) {
                      await _controller.loadBookings();
                    }
                  },
                  color: AppColors.burgundy,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_pin_circle_outlined, color: AppColors.burgundy, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _phoneInputController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Enter phone number (+251...)',
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _searchBookings(),
            ),
          ),
          FilledButton.tonal(
            onPressed: _searchBookings,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text('Find'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabButton(0, 'Active (${_controller.activeBookings.length})'),
          _tabButton(1, 'Past (${_controller.pastBookings.length})'),
          _tabButton(2, 'Cancelled (${_controller.cancelledBookings.length})'),
        ],
      ),
    );
  }

  Widget _tabButton(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.burgundy : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isLoading, String? error, List<Booking> bookings, bool hasPhone) {
    if (!hasPhone) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.muted),
                SizedBox(height: 12),
                Text(
                  'Customer Verification Required',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                SizedBox(height: 6),
                Text(
                  'Enter your booking phone number above to access your verified reservations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.burgundy),
            SizedBox(height: 12),
            Text('Loading reservations...', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    }

    if (error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(Icons.error_outline_rounded, size: 44, color: Colors.red.shade700),
                const SizedBox(height: 12),
                Text(
                  'Error loading reservations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                ),
                const SizedBox(height: 6),
                Text(error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _controller.loadBookings(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (bookings.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                const Icon(Icons.bookmark_border_rounded, size: 48, color: AppColors.muted),
                const SizedBox(height: 12),
                Text(
                  _selectedTabIndex == 0
                      ? 'No active reservations'
                      : _selectedTabIndex == 1
                          ? 'No past stays'
                          : 'No cancelled reservations',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your confirmed Ras Hotel bookings will appear here.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color badgeColor;
    Color badgeTextColor;
    switch (booking.status) {
      case 'CONFIRMED':
        badgeColor = const Color(0xFFE8F5E9);
        badgeTextColor = const Color(0xFF2E7D32);
        break;
      case 'CHECKED_IN':
        badgeColor = const Color(0xFFE3F2FD);
        badgeTextColor = const Color(0xFF1565C0);
        break;
      case 'CANCELLED':
        badgeColor = const Color(0xFFFFEBEE);
        badgeTextColor = const Color(0xFFC62828);
        break;
      default:
        badgeColor = const Color(0xFFFFF3E0);
        badgeTextColor = const Color(0xFFE65100);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.burgundy,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.muted),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: booking.confirmationNo));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reference copied!'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          // Room info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  booking.room.imageAssetPath,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${booking.room.type} (Room ${booking.room.number})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.checkInDate.day}/${booking.checkInDate.month} – ${booking.checkOutDate.day}/${booking.checkOutDate.month} (${booking.nights} ${booking.nights == 1 ? "night" : "nights"})',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.adults} Adults${booking.children > 0 ? ", ${booking.children} Children" : ""}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Total & Permitted Cancellation Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total ETB (inc. VAT)', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                  Text(
                    '${formatEtb(booking.totalEtb.round())} ETB',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.burgundy,
                    ),
                  ),
                ],
              ),
              if (booking.isCancellable)
                OutlinedButton(
                  onPressed: () => _confirmAndCancel(booking),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Cancel Stay', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
