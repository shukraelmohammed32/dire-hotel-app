import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/price_formatter.dart';
import '../../bookings/presentation/booking_flow_sheet.dart';
import '../domain/room.dart';

class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({
    required this.room,
    super.key,
    this.apiClient,
  });

  final Room room;
  final ApiClient? apiClient;

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
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
        onBookingSuccess: (_) {
          if (_selectedDates != null) {
            _checkAvailability(_selectedDates!);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: AppColors.canvas,
            foregroundColor: Colors.white,
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
                          Colors.black.withValues(alpha: .08),
                          Colors.black.withValues(alpha: .62),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.blush,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          room.badge,
                          style: const TextStyle(
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: room.isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          room.status,
                          style: TextStyle(
                            color: room.isAvailable ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
                      const SizedBox(width: 4),
                      Text(room.rating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.name,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontFamily: 'serif',
                          fontSize: 32,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    room.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoPill(icon: Icons.people_outline_rounded, value: '${room.capacity} guests'),
                      _InfoPill(icon: Icons.space_dashboard_outlined, value: '${room.sizeInSquareMeters} m²'),
                      _InfoPill(icon: Icons.layers_outlined, value: 'Floor ${room.floor}'),
                      if (room.number.isNotEmpty)
                        _InfoPill(icon: Icons.meeting_room_outlined, value: 'Room ${room.number}'),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Nightly rate',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ),
                        Text(
                          '${formatEtb(room.pricePerNight)} ETB',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.burgundy,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Availability check card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.burgundy),
                            const SizedBox(width: 8),
                            const Text(
                              'Check dates availability',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _pickDates,
                              child: Text(_selectedDates == null ? 'Select dates' : 'Change dates'),
                            ),
                          ],
                        ),
                        if (_isCheckingAvailability) ...[
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.burgundy),
                              ),
                              SizedBox(width: 8),
                              Text('Checking server booking conflicts...', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                            ],
                          ),
                        ] else if (_availabilityMessage != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _isAvailableForDates == true ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                size: 16,
                                color: _isAvailableForDates == true ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _availabilityMessage!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _isAvailableForDates == true ? Colors.green.shade800 : Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _openBookingSheet,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: AppColors.burgundy,
                    ),
                    child: const Text('Book this room'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.burgundy),
          const SizedBox(width: 8),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.ink)),
        ],
      ),
    );
  }
}
