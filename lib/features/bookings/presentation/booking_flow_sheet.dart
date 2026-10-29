import 'package:flutter/material.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/services/customer_session.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import '../../home/domain/pricing.dart';
import '../../home/domain/room.dart';
import '../domain/booking.dart';
import '../domain/booking_request.dart';
import 'booking_confirmation_dialog.dart';

class BookingFlowSheet extends StatefulWidget {
  const BookingFlowSheet({
    required this.room,
    this.initialDates,
    this.initialGuests = 2,
    this.apiClient,
    this.onBookingSuccess,
    super.key,
  });

  final Room room;
  final DateTimeRange? initialDates;
  final int initialGuests;
  final ApiClient? apiClient;
  final void Function(Booking booking)? onBookingSuccess;

  @override
  State<BookingFlowSheet> createState() => _BookingFlowSheetState();
}

class _BookingFlowSheetState extends State<BookingFlowSheet> {
  late final ApiClient _apiClient;
  final _formKey = GlobalKey<FormState>();

  late DateTimeRange _dates;
  late int _adults;
  int _children = 0;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passportController = TextEditingController();
  final _visaController = TextEditingController();
  final _residencePermitController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  String _nationality = 'Ethiopian';
  bool _isForeignGuest = false;

  bool _isLoadingPricing = false;
  String? _pricingError;
  Pricing? _pricing;

  bool _isSubmitting = false;
  String? _submissionError;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();

    final now = DateTime.now();
    _dates = widget.initialDates ??
        DateTimeRange(
          start: now.add(const Duration(days: 1)),
          end: now.add(const Duration(days: 3)),
        );
    _adults = widget.initialGuests.clamp(1, widget.room.capacity);

    // Pre-fill from active customer session if available
    final session = CustomerSession.instance;
    if (session.phone != null) _phoneController.text = session.phone!;
    if (session.name != null) _nameController.text = session.name!;
    if (session.email != null) _emailController.text = session.email!;

    _fetchPricing();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passportController.dispose();
    _visaController.dispose();
    _residencePermitController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _fetchPricing({bool isRetry = false}) async {
    setState(() {
      _isLoadingPricing = true;
      _pricingError = null;
    });

    try {
      final pricing = await _apiClient.calculatePricing(
        roomId: widget.room.id,
        checkIn: _dates.start,
        checkOut: _dates.end,
        adults: _adults,
        children: _children,
      );
      if (mounted) {
        setState(() {
          _pricing = pricing;
          _isLoadingPricing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Auto-retry once after a short delay on first failure
        if (!isRetry) {
          await Future<void>.delayed(const Duration(seconds: 3));
          if (mounted) {
            await _fetchPricing(isRetry: true);
          }
          return;
        }
        setState(() {
          _pricingError = e
              .toString()
              .replaceFirst('ApiException: ', '')
              .replaceFirst('NetworkException: ', '')
              .replaceFirst('TimeoutException: ', '');
          _isLoadingPricing = false;
        });
      }
    }
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _dates,
    );
    if (picked != null) {
      setState(() => _dates = picked);
      await _fetchPricing();
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isForeignGuest &&
        _passportController.text.trim().isEmpty &&
        _residencePermitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foreign guest records require passport or residence permit details.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      final request = BookingRequest(
        roomId: widget.room.id,
        checkIn: _dates.start,
        checkOut: _dates.end,
        adults: _adults,
        children: _children,
        guestName: _nameController.text.trim(),
        guestPhone: _phoneController.text.trim(),
        guestEmail: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        nationality: _nationality,
        isForeignGuest: _isForeignGuest,
        passportNumber: _passportController.text.trim().isNotEmpty
            ? _passportController.text.trim()
            : null,
        visaNumber: _visaController.text.trim().isNotEmpty
            ? _visaController.text.trim()
            : null,
        residencePermit: _residencePermitController.text.trim().isNotEmpty
            ? _residencePermitController.text.trim()
            : null,
        specialRequests: _specialRequestsController.text.trim().isNotEmpty
            ? _specialRequestsController.text.trim()
            : null,
      );

      final booking = await _apiClient.createBooking(request);

      // Save customer identity for session management
      CustomerSession.instance.setCustomer(
        phone: request.guestPhone,
        name: request.guestName,
        email: request.guestEmail,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close bottom sheet

        // Notify the parent (RoomDetailScreen) about the new booking so it can
        // switch to the Bookings tab and trigger an immediate reload.
        widget.onBookingSuccess?.call(booking);

        showDialog<void>(
          context: context,
          builder: (_) => BookingConfirmationDialog(
            booking: booking,
            onViewBookings: () {
              // onBookingSuccess already navigated to tab 2.  If the user
              // reaches this callback by tapping "View in My Bookings" in the
              // dialog, the tab switch has already happened (the shell is now
              // showing Bookings) so there is nothing extra to do here.
            },
          ),
        );
      }
    } on BookingConflictException catch (e) {
      if (mounted) {
        setState(() {
          _submissionError = e.message;
          _isSubmitting = false;
        });
      }
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() {
          _submissionError = e.message;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submissionError = e.toString().replaceFirst('ApiException: ', '');
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            shrinkWrap: true,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reserve Room',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          '${widget.room.name} • Room ${widget.room.number}',
                          style: const TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Section 1: Dates & Guests
              _buildDatesAndGuestsSection(),
              const SizedBox(height: 20),
              // Section 2: Live Server Price Breakdown in ETB
              _buildPriceBreakdownSection(),
              const SizedBox(height: 20),
              // Section 3: Guest Information Form
              _buildGuestFormSection(),
              if (_submissionError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red.shade800, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _submissionError!,
                          style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSubmitting ? null : _submitBooking,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: AppColors.burgundy,
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Text('Revalidating & Confirming...'),
                        ],
                      )
                    : Text(
                        _pricing != null
                            ? 'Confirm Booking (${formatEtb(_pricing!.totalEtb.round())} ETB)'
                            : 'Confirm Booking',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatesAndGuestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Stay Dates & Guests',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickDates,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.burgundy),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dates', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                            Text(
                              '${_dates.start.day}/${_dates.start.month} – ${_dates.end.day}/${_dates.end.month}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_outline_rounded, size: 18, color: AppColors.burgundy),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Adults', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                          DropdownButton<int>(
                            value: _adults,
                            isDense: true,
                            underline: const SizedBox(),
                            items: List.generate(
                              widget.room.capacity,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text('${i + 1} ${i == 0 ? "Adult" : "Adults"}'),
                              ),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _adults = val);
                                _fetchPricing();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Children:', style: TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(width: 10),
            DropdownButton<int>(
              value: _children,
              isDense: true,
              underline: const SizedBox(),
              items: [0, 1, 2, 3].map((c) => DropdownMenuItem(value: c, child: Text('$c Children'))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _children = val);
                  _fetchPricing();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceBreakdownSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '2. Price Breakdown (ETB)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.ink),
              ),
              if (_isLoadingPricing)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.burgundy),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isLoadingPricing && _pricing == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Calculating price…',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            )
          else if (_pricingError != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: AppColors.muted, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Unable to load price. Please check your connection.',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _isLoadingPricing ? null : _fetchPricing,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Retry', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.burgundy,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const Divider(height: 16),
                _priceRow(
                  'Nightly rate',
                  '${formatEtb(widget.room.pricePerNight)} ETB',
                ),
              ],
            )
          else if (_pricing != null) ...[
            _priceRow(
              '${formatEtb(_pricing!.nightlyRate.round())} ETB × ${_pricing!.nights} ${_pricing!.nights == 1 ? "night" : "nights"}',
              '${formatEtb(_pricing!.subtotal.round())} ETB',
            ),
            _priceRow(
              'VAT (${_pricing!.vatRate.toStringAsFixed(0)}%)',
              '${formatEtb(_pricing!.vatAmount.round())} ETB',
            ),
            if (_pricing!.municipalTax > 0)
              _priceRow('City Tax', '${formatEtb(_pricing!.municipalTax.round())} ETB'),
            if (_pricing!.serviceCharge > 0)
              _priceRow('Service Charge', '${formatEtb(_pricing!.serviceCharge.round())} ETB'),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  '${formatEtb(_pricing!.totalEtb.round())} ETB',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.burgundy,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuestFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. Guest Information',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            hintText: 'e.g. Abebe Bikila',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'Guest full name is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            hintText: '+251 91 123 4567',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'Phone number is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address (optional)',
            hintText: 'guest@example.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            const Text('Guest Nationality:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ChoiceChip(
              label: const Text('Ethiopian'),
              selected: !_isForeignGuest,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _isForeignGuest = false;
                    _nationality = 'Ethiopian';
                  });
                }
              },
            ),
            ChoiceChip(
              label: const Text('Foreign Guest'),
              selected: _isForeignGuest,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _isForeignGuest = true;
                    _nationality = 'Foreign';
                  });
                }
              },
            ),
          ],
        ),
        if (_isForeignGuest) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _passportController,
            decoration: const InputDecoration(
              labelText: 'Passport Number *',
              hintText: 'e.g. A12345678',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _visaController,
            decoration: const InputDecoration(
              labelText: 'Visa Number (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _residencePermitController,
            decoration: const InputDecoration(
              labelText: 'Residence Permit (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextFormField(
          controller: _specialRequestsController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Special Requests (optional)',
            hintText: 'e.g. Late check-in, quiet room',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
