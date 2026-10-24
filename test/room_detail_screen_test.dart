import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/home/domain/room.dart';
import 'package:mobile/features/home/presentation/room_detail_screen.dart';

void main() {
  testWidgets('RoomDetailScreen renders real room info and disabled booking button', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const room = Room(
      id: 'detail-201',
      number: '201',
      floor: 2,
      type: 'Superior King Suite',
      capacity: 2,
      baseRate: 4500.0,
      status: 'AVAILABLE',
      notes: 'Quiet room with city and mountain view',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const RoomDetailScreen(room: room),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Superior King Suite (Room 201)'), findsOneWidget);
    expect(find.text('Quiet room with city and mountain view'), findsOneWidget);
    expect(find.text('2 guests'), findsOneWidget);
    expect(find.text('Floor 2'), findsOneWidget);
    expect(find.text('Room 201'), findsOneWidget);
    expect(find.text('4,500 ETB'), findsOneWidget);
    expect(find.text('AVAILABLE'), findsOneWidget);

    // Verify booking button is present and explains verification state
    final bookingButtonFinder = find.text('Book room (disabled during verification)');
    expect(bookingButtonFinder, findsOneWidget);

    // Tap button to verify snackbar notice
    await tester.tap(bookingButtonFinder);
    await tester.pump();

    expect(
      find.text('Booking creation will be enabled after room listing & availability are verified.'),
      findsOneWidget,
    );
  });
}
