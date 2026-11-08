import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';
import '../../dining/domain/dining_reservation.dart';

class DiningConfirmationDialog extends StatelessWidget {
  const DiningConfirmationDialog({
    required this.reservation,
    required this.onViewReservations,
    super.key,
  });

  final DiningReservation reservation;
  final VoidCallback onViewReservations;

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
              'Reservation Submitted!',
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
              'Your table request has been received. Our team will contact you shortly to confirm.',
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
                  _infoRow(Icons.confirmation_number_outlined, 'Confirmation', reservation.confirmationNo),
                  const Divider(height: 16),
                  _infoRow(Icons.calendar_today_outlined, 'Date', '${reservation.date.day}/${reservation.date.month}/${reservation.date.year}'),
                  const Divider(height: 16),
                  _infoRow(Icons.access_time_outlined, 'Time', reservation.time),
                  const Divider(height: 16),
                  _infoRow(Icons.people_outline_rounded, 'Guests', '${reservation.guests}'),
                  if (reservation.notes != null && reservation.notes!.isNotEmpty) ...[
                    const Divider(height: 16),
                    _infoRow(Icons.note_outlined, 'Notes', reservation.notes!),
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
                      onViewReservations();
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppColors.burgundy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('View My Reservations'),
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