import 'package:flutter/material.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/services/customer_session.dart';
import 'package:mobile/core/theme/app_theme.dart';
import '../../dining/domain/dining_reservation.dart';
import '../../dining/domain/dining_reservation_request.dart';
import 'dining_confirmation_dialog.dart';

class DiningReservationFlowSheet extends StatefulWidget {
  const DiningReservationFlowSheet({
    this.initialDate,
    this.initialTime,
    this.initialGuests = 2,
    this.apiClient,
    this.onReservationSuccess,
    super.key,
  });

  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final int initialGuests;
  final ApiClient? apiClient;
  final void Function(DiningReservation reservation)? onReservationSuccess;

  @override
  State<DiningReservationFlowSheet> createState() => _DiningReservationFlowSheetState();
}

class _DiningReservationFlowSheetState extends State<DiningReservationFlowSheet> {
  late final ApiClient _apiClient;
  final _formKey = GlobalKey<FormState>();

  late DateTime _date;
  late TimeOfDay _time;
  int _guests = 2;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;
  String? _submissionError;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();

    final now = DateTime.now();
    _date = widget.initialDate ?? now.add(const Duration(days: 1));
    _time = widget.initialTime ?? const TimeOfDay(hour: 19, minute: 0);
    _guests = widget.initialGuests.clamp(1, 20);

    // Pre-fill from active customer session if available
    final session = CustomerSession.instance;
    if (session.phone != null) _phoneController.text = session.phone!;
    if (session.name != null) _nameController.text = session.name!;
    if (session.email != null) _emailController.text = session.email!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _date,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      final request = DiningReservationRequest(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        date: _date,
        time: _time.format(context),
        guests: _guests,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      final reservation = await _apiClient.createDiningReservation(request);

      // Save customer identity for session management
      CustomerSession.instance.setCustomer(
        phone: request.phone,
        name: request.name,
        email: request.email,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close bottom sheet

        widget.onReservationSuccess?.call(reservation);

        showDialog<void>(
          context: context,
          builder: (_) => DiningConfirmationDialog(
            reservation: reservation,
            onViewReservations: () {
              // onReservationSuccess already navigated
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
                          'Reserve a Table',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        const Text(
                          'Ras Restaurant & Bar',
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
              // Section 1: Date & Time
              _buildDateTimeSection(),
              const SizedBox(height: 20),
              // Section 2: Guest Count
              _buildGuestCountSection(),
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
                onPressed: _isSubmitting ? null : _submitReservation,
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
                    : const Text('Submit Reservation'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Date & Time',
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
                            const Text('Date', style: TextStyle(fontSize: 11, color: AppColors.muted)),
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
              child: InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_outlined, size: 18, color: AppColors.burgundy),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Time', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                            Text(
                              _time.format(context),
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
          ],
        ),
      ],
    );
  }

  Widget _buildGuestCountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Number of Guests',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink),
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
                    const Text('Guests', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    DropdownButton<int>(
                      value: _guests,
                      isDense: true,
                      underline: const SizedBox(),
                      items: List.generate(
                        20,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('${i + 1} ${i == 0 ? "Guest" : "Guests"}'),
                        ),
                      ),
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
          validator: (v) => v == null || v.trim().isEmpty ? 'Full name is required' : null,
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
        TextFormField(
          controller: _notesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Special Requests (optional)',
            hintText: 'e.g. Window seat, high chair, dietary restrictions',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}