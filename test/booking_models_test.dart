import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/bookings/domain/booking.dart';
import 'package:mobile/features/bookings/domain/booking_request.dart';
import 'package:mobile/features/home/domain/pricing.dart';

void main() {
  group('Pricing Model', () {
    test('parses server pricing JSON correctly', () {
      final json = {
        'roomId': 'room-201',
        'roomType': 'Superior King Suite',
        'roomNumber': '201',
        'floor': 2,
        'capacity': 2,
        'checkIn': '2026-11-01T12:00:00.000Z',
        'checkOut': '2026-11-03T10:00:00.000Z',
        'nights': 2,
        'adults': 2,
        'children': 0,
        'nightlyRate': 4500.0,
        'subtotal': 9000.0,
        'vatRate': 15.0,
        'vatAmount': 1350.0,
        'municipalRate': 0.0,
        'municipalTax': 0.0,
        'serviceRate': 0.0,
        'serviceCharge': 0.0,
        'totalEtb': 10350.0,
        'currency': 'ETB',
      };

      final pricing = Pricing.fromJson(json);

      expect(pricing.roomId, 'room-201');
      expect(pricing.nights, 2);
      expect(pricing.nightlyRate, 4500.0);
      expect(pricing.subtotal, 9000.0);
      expect(pricing.vatAmount, 1350.0);
      expect(pricing.totalEtb, 10350.0);
      expect(pricing.currency, 'ETB');
    });
  });

  group('Booking Model', () {
    test('parses server booking response with reference and invoice', () {
      final json = {
        'id': 'res-123',
        'confirmationNo': 'RAS-2026-X8K123',
        'status': 'CONFIRMED',
        'checkInDate': '2026-11-01T12:00:00.000Z',
        'checkOutDate': '2026-11-03T10:00:00.000Z',
        'nights': 2,
        'adults': 2,
        'children': 0,
        'specialRequests': 'Late check-in',
        'createdAt': '2026-10-24T20:00:00.000Z',
        'pricing': {
          'roomId': 'room-201',
          'roomType': 'Superior King Suite',
          'roomNumber': '201',
          'floor': 2,
          'capacity': 2,
          'checkIn': '2026-11-01T12:00:00.000Z',
          'checkOut': '2026-11-03T10:00:00.000Z',
          'nights': 2,
          'adults': 2,
          'children': 0,
          'nightlyRate': 4500.0,
          'subtotal': 9000.0,
          'vatRate': 15.0,
          'vatAmount': 1350.0,
          'municipalRate': 0.0,
          'municipalTax': 0.0,
          'serviceRate': 0.0,
          'serviceCharge': 0.0,
          'totalEtb': 10350.0,
          'currency': 'ETB',
        },
        'room': {
          'id': 'room-201',
          'number': '201',
          'floor': 2,
          'type': 'Superior King Suite',
          'capacity': 2,
          'baseRate': 4500.0,
          'status': 'AVAILABLE',
        },
        'guest': {
          'id': 'guest-1',
          'name': 'Abebe Bikila',
          'phone': '+251911223344',
          'email': 'abebe@example.com',
        },
        'invoice': {
          'id': 'inv-1',
          'invoiceNo': 'RAS-2026-98765',
          'total': 10350.0,
          'status': 'PENDING',
        },
      };

      final booking = Booking.fromJson(json);

      expect(booking.id, 'res-123');
      expect(booking.confirmationNo, 'RAS-2026-X8K123');
      expect(booking.status, 'CONFIRMED');
      expect(booking.isCancellable, true);
      expect(booking.isActive, true);
      expect(booking.isCancelled, false);
      expect(booking.guestName, 'Abebe Bikila');
      expect(booking.guestPhone, '+251911223344');
      expect(booking.totalEtb, 10350.0);
      expect(booking.invoiceNo, 'RAS-2026-98765');
      expect(booking.room.number, '201');
    });

    test('BookingRequest converts to server JSON payload', () {
      final request = BookingRequest(
        roomId: 'room-101',
        checkIn: DateTime(2026, 11, 1),
        checkOut: DateTime(2026, 11, 3),
        adults: 2,
        children: 1,
        guestName: 'Almaz Ayana',
        guestPhone: '+251922334455',
        guestEmail: 'almaz@example.com',
        nationality: 'Ethiopian',
        specialRequests: 'Quiet room please',
      );

      final json = request.toJson();

      expect(json['roomId'], 'room-101');
      expect(json['checkIn'], '2026-11-01');
      expect(json['checkOut'], '2026-11-03');
      expect(json['guestName'], 'Almaz Ayana');
      expect(json['guestPhone'], '+251922334455');
      expect(json['guestEmail'], 'almaz@example.com');
      expect(json['adults'], 2);
      expect(json['children'], 1);
      expect(json['specialRequests'], 'Quiet room please');
    });
  });
}
