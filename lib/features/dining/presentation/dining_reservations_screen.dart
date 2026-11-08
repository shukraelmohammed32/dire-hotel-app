import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/services/customer_session.dart';
import 'package:mobile/core/theme/app_theme.dart';
import '../domain/dining_reservation.dart';
import 'controllers/dining_reservations_controller.dart';

class DiningReservationsScreen extends StatefulWidget {
  const DiningReservationsScreen({
    super.key,
    this.controller,
  });

  final DiningReservationsController? controller;

  @override
  State<DiningReservationsScreen> createState() => _DiningReservationsScreenState();
}

class _DiningReservationsScreenState extends State<DiningReservationsScreen> {
  late final DiningReservationsController _controller;
  final _phoneInputController = TextEditingController();
  int _selectedTabIndex = 0; // 0 = Pending, 1 = Confirmed, 2 = Past

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? DiningReservationsController();

    final sessionPhone = CustomerSession.instance.phone;
    if (sessionPhone != null && sessionPhone.isNotEmpty) {
      _phoneInputController.text = sessionPhone;
      _controller.loadReservations(phone: sessionPhone);
    }
    _controller.startPolling(intervalSeconds: 30);
  }

  @override
  void dispose() {
    _controller.stopPolling();
    _phoneInputController.dispose();
    super.dispose();
  }

  void _searchReservations() {
    final phone = _phoneInputController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number to find your reservations.')),
      );
      return;
    }
    CustomerSession.instance.setCustomer(phone: phone);
    _controller.loadReservations(phone: phone);
  }

  List<DiningReservation> _getCurrentTabReservations() {
    switch (_selectedTabIndex) {
      case 0:
        return _controller.pendingReservations;
      case 1:
        return _controller.confirmedReservations;
      case 2:
        return _controller.pastReservations;
      default:
        return _controller.pendingReservations;
    }
  }

  String _getTabLabel(int index) {
    switch (index) {
      case 0:
        return 'Pending (${_controller.pendingReservations.length})';
      case 1:
        return 'Confirmed (${_controller.confirmedReservations.length})';
      case 2:
        return 'Past (${_controller.pastReservations.length})';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final currentReservations = _getCurrentTabReservations();
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
                      'My Dining Reservations',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontFamily: 'serif',
                            fontSize: 32,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage your table reservations at Ras Restaurant & Bar.',
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
                      await _controller.loadReservations();
                    }
                  },
                  color: AppColors.burgundy,
                  child: _buildBody(isLoading, error, currentReservations, hasPhone),
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
          const Icon(Icons.restaurant_outlined, color: AppColors.burgundy, size: 22),
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
              onSubmitted: (_) => _searchReservations(),
            ),
          ),
          FilledButton.tonal(
            onPressed: _searchReservations,
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
          _tabButton(0, _getTabLabel(0)),
          _tabButton(1, _getTabLabel(1)),
          _tabButton(2, _getTabLabel(2)),
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

  Widget _buildBody(bool isLoading, String? error, List<DiningReservation> reservations, bool hasPhone) {
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
                  'Enter your phone number above to access your dining reservations.',
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
                  onPressed: () => _controller.loadReservations(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (reservations.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                const Icon(Icons.restaurant_outlined, size: 48, color: AppColors.muted),
                const SizedBox(height: 12),
                Text(
                  _selectedTabIndex == 0
                      ? 'No pending reservations'
                      : _selectedTabIndex == 1
                          ? 'No confirmed reservations'
                          : 'No past reservations',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your table reservations will appear here.',
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
      itemCount: reservations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return _buildReservationCard(reservation);
      },
    );
  }

  Widget _buildReservationCard(DiningReservation reservation) {
    Color badgeColor;
    Color badgeTextColor;
    switch (reservation.status) {
      case 'PENDING':
        badgeColor = const Color(0xFFFFF3E0);
        badgeTextColor = const Color(0xFFE65100);
        break;
      case 'CONFIRMED':
        badgeColor = const Color(0xFFE8F5E9);
        badgeTextColor = const Color(0xFF2E7D32);
        break;
      case 'CANCELLED':
        badgeColor = const Color(0xFFFFEBEE);
        badgeTextColor = const Color(0xFFC62828);
        break;
      case 'COMPLETED':
        badgeColor = const Color(0xFFE3F2FD);
        badgeTextColor = const Color(0xFF1565C0);
        break;
      default:
        badgeColor = const Color(0xFFF5F5F5);
        badgeTextColor = const Color(0xFF757575);
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
                    reservation.confirmationNo,
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
                      Clipboard.setData(ClipboardData(text: reservation.confirmationNo));
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
                  reservation.status,
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
          // Reservation details
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.burgundy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restaurant_outlined, color: AppColors.burgundy, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ras Restaurant & Bar',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${reservation.date.day}/${reservation.date.month}/${reservation.date.year} at ${reservation.time}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${reservation.guests} ${reservation.guests == 1 ? "Guest" : "Guests"}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (reservation.notes != null && reservation.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reservation.notes!,
                      style: const TextStyle(fontSize: 12, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}