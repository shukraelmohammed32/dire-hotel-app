import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';
import '../../events/domain/event_booking.dart';

class EventBookingConfirmationDialog extends StatelessWidget {
  const EventBookingConfirmationDialog({
    required this.booking,
    required this.onViewBookings,
    super.key,
  });

  final EventBooking booking;
  final VoidCallback onViewBookings;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.burgundy.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 36,
                color: AppColors.burgundy,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Event Request Submitted!',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your event enquiry has been received. Our events team will contact you shortly to discuss your requirements.',
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.confirmation_number_outlined, 'Booking Reference', booking.confirmationNo),
                  const Divider(height: 16),
                  _infoRow(Icons.business_outlined, 'Organization', booking.organization),
                  const Divider(height: 16),
                  _infoRow(Icons.event_outlined, 'Event Type', booking.eventType),
                  const Divider(height: 16),
                  _infoRow(Icons.calendar_today_outlined, 'Preferred Date', '${booking.date.day}/${booking.date.month}/${booking.date.year}'),
                  const Divider(height: 16),
                  _infoRow(Icons.people_outline_rounded, 'Expected Guests', '${booking.guests}'),
                  if (booking.details != null && booking.details!.isNotEmpty) ...[
                    const Divider(height: 16),
                    _infoRow(Icons.description_outlined, 'Details', booking.details!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Done'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onViewBookings();
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppColors.burgundy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('View My Events'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.burgundy),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}