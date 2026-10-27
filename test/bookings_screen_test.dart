import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/customer_session.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/bookings/presentation/bookings_screen.dart';
import 'package:mobile/features/bookings/presentation/controllers/bookings_controller.dart';

import 'bookings_controller_test.dart';

void main() {
  testWidgets('BookingsScreen renders customer bookings and tabs', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = BookingsController(apiClient: MockSuccessApiClient());
    CustomerSession.instance.setCustomer(phone: '+251911223344');
    await controller.loadBookings();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: BookingsScreen(controller: controller),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('Active (1)'), findsOneWidget);
    expect(find.text('Past (0)'), findsOneWidget);
    expect(find.text('Cancelled (1)'), findsOneWidget);

    // Active booking card
    expect(find.text('RAS-2026-ACTIVE1'), findsOneWidget);
    expect(find.text('Standard Room (Room 101)'), findsOneWidget);
    expect(find.text('CONFIRMED'), findsOneWidget);
    expect(find.text('Cancel Stay'), findsOneWidget);

    // Switch to Cancelled tab
    await tester.tap(find.text('Cancelled (1)'));
    await tester.pumpAndSettle();

    expect(find.text('RAS-2026-CANCELLED1'), findsOneWidget);
    expect(find.text('Superior King Suite (Room 201)'), findsOneWidget);
    expect(find.text('CANCELLED'), findsOneWidget);
  });
}
