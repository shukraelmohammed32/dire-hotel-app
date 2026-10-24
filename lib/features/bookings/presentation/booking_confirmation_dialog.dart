import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/price_formatter.dart';
import '../domain/booking.dart';

class BookingConfirmationDialog extends StatelessWidget {
  const BookingConfirmationDialog({
    required this.booking,
    this.onViewBookings,
    super.key,
  });

  final Booking booking;
  final VoidCallback? onViewBookings;

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
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2E7D32),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Thank you, ${booking.guestName}. Your reservation is confirmed at Ras Hotel.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 18),
            // Confirmation reference box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.blush,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined, color: AppColors.burgundy, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Reference',
                          style: TextStyle(fontSize: 11, color: AppColors.muted),
                        ),
                        SelectableText(
                          booking.confirmationNo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: .5,
                            color: AppColors.burgundy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.burgundy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: booking.confirmationNo));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking reference copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Reservation detail rows
            _detailRow('Room', '${booking.room.type} (Room ${booking.room.number})'),
            _detailRow(
              'Stay Dates',
              '${booking.checkInDate.day}/${booking.checkInDate.month} – ${booking.checkOutDate.day}/${booking.checkOutDate.month} (${booking.nights} ${booking.nights == 1 ? "night" : "nights"})',
            ),
            _detailRow('Guests', '${booking.adults} Adults${booking.children > 0 ? ", ${booking.children} Children" : ""}'),
            _detailRow('Total (inc. VAT)', '${formatEtb(booking.totalEtb.round())} ETB'),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onViewBookings?.call();
                },
                child: const Text('View in My Bookings'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
        ],
      ),
    );
  }
}
