import 'package:flutter/material.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/services/customer_session.dart';
import 'package:mobile/core/theme/app_theme.dart';
import '../../events/domain/event_booking.dart';
import '../../events/domain/event_booking_request.dart';
import 'event_booking_confirmation_dialog.dart';

class EventBookingFlowSheet extends StatefulWidget {
  const EventBookingFlowSheet({
    this.initialDate,
    this.initialGuests = 10,
    this.apiClient,
    this.onBookingSuccess,
    super.key,
  });

  final DateTime? initialDate;
  final int initialGuests;
  final ApiClient? apiClient;
  final void Function(EventBooking booking)? onBookingSuccess;

  @override
  State<EventBookingFlowSheet> createState() => _EventBookingFlowSheetState();
}

class _EventBookingFlowSheetState extends State<EventBookingFlowSheet> {
  late final ApiClient _apiClient;
  final _formKey = GlobalKey<FormState>();

  late DateTime _date;
  int _guests = 10;
  String _eventType = 'Conference';

  final _nameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _detailsController = TextEditingController();

  static const List<String> _eventTypes = [
    'Conference',
    'Meeting',
    'Workshop',
    'Wedding',
    'Private celebration',
    'Other',
  ];

  bool _isSubmitting = false;
  String? _submissionError;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();

    final now = DateTime.now();
    _date = widget.initialDate ?? now.add(const Duration(days: 7));
    _guests = widget.initialGuests.clamp(1, 500);

    // Pre-fill from active customer session if available
    final session = CustomerSession.instance;
    if (session.phone != null) _phoneController.text = session.phone!;
    if (session.name != null) _nameController.text = session.name!;
    if (session.email != null) _emailController.text = session.email!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      initialDate: _date,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      final request = EventBookingRequest(
        name: _nameController.text.trim(),
        organization: _organizationController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        date: _date,
        eventType: _eventType,
        guests: _guests,
        details: _detailsController.text.trim().isNotEmpty
            ? _detailsController.text.trim()
            : null,
      );

      final booking = await _apiClient.createEventBooking(request);

      // Save customer identity for session management
      CustomerSession.instance.setCustomer(
        phone: request.phone,
        name: request.name,
        email: request.email,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close bottom sheet

        widget.onBookingSuccess?.call(booking);

        showDialog<void>(
          context: context,
          builder: (_) => EventBookingConfirmationDialog(
            booking: booking,
            onViewBookings: () {
              // onBookingSuccess already navigated
            },
          ),
        );
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
                          'Plan an Event',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        const Text(
                          'Ras Hotel Events',
                          style: TextStyle(color: AppColors.muted, fontSize: 13),
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
              // Section 1: Event Details
              _buildEventDetailsSection(),
              const SizedBox(height: 20),
              // Section 2: Contact Information
              _buildContactSection(),
              const SizedBox(height: 20),
              // Section 3: Event Details
              _buildDetailsSection(),
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
                          Text('Submitting Request…'),
                        ],
                      )
                    : const Text('Submit Event Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Event Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickDate,
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
                            const Text('Preferred Date', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                            Text(
                              '${_date.day}/${_date.month}/${_date.year}',
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
                    const Icon(Icons.event_outlined, size: 18, color: AppColors.burgundy),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Event Type *', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                          DropdownButton<String>(
                            value: _eventType,
                            isDense: true,
                            underline: const SizedBox(),
                            items: _eventTypes.map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _eventType = val);
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
        const SizedBox(height: 10),
        Container(
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
                    const Text('Expected Guests *', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    DropdownButton<int>(
                      value: _guests,
                      isDense: true,
                      underline: const SizedBox(),
                      items: [10, 20, 30, 40, 50, 75, 100, 150, 200, 300, 500]
                          .map((g) => DropdownMenuItem(value: g, child: Text('$g Guests')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _guests = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Contact Information',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Your Name *',
            hintText: 'e.g. Abebe Bikila',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'Your name is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _organizationController,
          decoration: const InputDecoration(
            labelText: 'Organization *',
            hintText: 'Company or organization name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business_outlined),
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'Organization is required' : null,
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
            hintText: 'organizer@example.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. Event Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _detailsController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Event Details *',
            hintText: 'Describe your event requirements: setup, catering, AV equipment, timeline, etc.',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'Event details are required' : null,
        ),
      ],
    );
  }
}