import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/services/customer_session.dart';
import 'package:mobile/features/bookings/domain/booking.dart';
import 'package:mobile/features/bookings/presentation/controllers/bookings_controller.dart';
import 'package:mobile/features/home/domain/pricing.dart';
import 'package:mobile/features/home/domain/room.dart';

class MockSuccessApiClient extends ApiClient {
  final List<Booking> sampleBookings = [
    Booking(
      id: 'res-1',
      confirmationNo: 'RAS-2026-ACTIVE1',
      status: 'CONFIRMED',
      checkInDate: DateTime.now().add(const Duration(days: 2)),
      checkOutDate: DateTime.now().add(const Duration(days: 4)),
      nights: 2,
      adults: 2,
      children: 0,
      createdAt: DateTime.now(),
      pricing: Pricing(
        roomId: 'room-101',
        roomType: 'Standard Room',
        roomNumber: '101',
        floor: 1,
        capacity: 2,
        checkIn: DateTime.now(),
        checkOut: DateTime.now(),
        nights: 2,
        adults: 2,
        children: 0,
        nightlyRate: 2800,
        subtotal: 5600,
        vatRate: 15,
        vatAmount: 840,
        municipalRate: 0,
        municipalTax: 0,
        serviceRate: 0,
        serviceCharge: 0,
        totalEtb: 6440,
        currency: 'ETB',
      ),
      room: const Room(
        id: 'room-101',
        number: '101',
        floor: 1,
        type: 'Standard Room',
      ),
      guestName: 'Abebe Bikila',
      guestPhone: '+251911223344',
      totalEtb: 6440,
    ),
    Booking(
      id: 'res-2',
      confirmationNo: 'RAS-2026-CANCELLED1',
      status: 'CANCELLED',
      checkInDate: DateTime.now().add(const Duration(days: 5)),
      checkOutDate: DateTime.now().add(const Duration(days: 7)),
      nights: 2,
      adults: 1,
      children: 0,
      createdAt: DateTime.now(),
      pricing: Pricing(
        roomId: 'room-201',
        roomType: 'Superior King Suite',
        roomNumber: '201',
        floor: 2,
        capacity: 2,
        checkIn: DateTime.now(),
        checkOut: DateTime.now(),
        nights: 2,
        adults: 1,
        children: 0,
        nightlyRate: 4500,
        subtotal: 9000,
        vatRate: 15,
        vatAmount: 1350,
        municipalRate: 0,
        municipalTax: 0,
        serviceRate: 0,
        serviceCharge: 0,
        totalEtb: 10350,
        currency: 'ETB',
      ),
      room: const Room(
        id: 'room-201',
        number: '201',
        floor: 2,
        type: 'Superior King Suite',
      ),
      guestName: 'Abebe Bikila',
      guestPhone: '+251911223344',
      totalEtb: 10350,
    ),
  ];

  @override
  Future<List<Booking>> getCustomerBookings({required String phone, String? email}) async {
    return sampleBookings;
  }

  @override
  Future<bool> cancelBooking({required String confirmationNo, required String phone, String? reason}) async {
    return true;
  }
}

class MockErrorApiClient extends ApiClient {
  @override
  Future<List<Booking>> getCustomerBookings({required String phone, String? email}) async {
    throw const AuthorizationException('Unauthorized access to reservations');
  }

  @override
  Future<bool> cancelBooking({required String confirmationNo, required String phone, String? reason}) async {
    throw const AuthorizationException('Not permitted to cancel this reservation');
  }
}

void main() {
  group('BookingsController Tests', () {
    test('loadBookings updates bookings and categorizes active vs cancelled', () async {
      final controller = BookingsController(apiClient: MockSuccessApiClient());
      CustomerSession.instance.setCustomer(phone: '+251911223344');

      await controller.loadBookings();

      expect(controller.isLoading, false);
      expect(controller.bookings.length, 2);
      expect(controller.activeBookings.length, 1);
      expect(controller.activeBookings.first.confirmationNo, 'RAS-2026-ACTIVE1');
      expect(controller.cancelledBookings.length, 1);
      expect(controller.cancelledBookings.first.confirmationNo, 'RAS-2026-CANCELLED1');
    });

    test('cancelBooking invokes cancellation and reloads bookings', () async {
      final controller = BookingsController(apiClient: MockSuccessApiClient());
      final success = await controller.cancelBooking(
        confirmationNo: 'RAS-2026-ACTIVE1',
        phone: '+251911223344',
      );

      expect(success, true);
      expect(controller.isCancelling, false);
      expect(controller.cancelError, isNull);
    });

    test('loadBookings handles AuthorizationException appropriately', () async {
      final controller = BookingsController(apiClient: MockErrorApiClient());
      await controller.loadBookings(phone: '+251911223344');

      expect(controller.isLoading, false);
      expect(controller.bookings, isEmpty);
      expect(controller.errorMessage, contains('Unauthorized'));
    });
  });
}
