import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/home/domain/room.dart';
import 'package:mobile/features/home/presentation/controllers/rooms_controller.dart';
import 'package:mobile/features/home/presentation/room_list_screen.dart';

import 'rooms_controller_test.dart';

void main() {
  testWidgets('RoomListScreen renders rooms and filter chips', (tester) async {
    final controller = RoomsController(repository: MockSuccessRoomRepository());
    await controller.loadRooms();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: RoomListScreen(initialController: controller),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('All rooms'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('Superior'), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);

    expect(find.text('Standard Room (Room 101)'), findsOneWidget);
    expect(find.text('Superior King Suite (Room 201)'), findsOneWidget);
    expect(find.text('Family Suite (Room 301)'), findsOneWidget);

    // Tap 'Standard' filter chip
    await tester.tap(find.text('Standard'));
    await tester.pumpAndSettle();

    expect(find.text('Standard Room (Room 101)'), findsOneWidget);
    expect(find.text('Superior King Suite (Room 201)'), findsNothing);
  });

  testWidgets('RoomListScreen displays initialRooms directly when provided', (tester) async {
    const customRooms = [
      Room(
        id: 'res-1',
        number: '105',
        floor: 1,
        type: 'Standard Room',
        baseRate: 2800,
        status: 'AVAILABLE',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const RoomListScreen(initialRooms: customRooms),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Available rooms'), findsOneWidget);
    expect(find.text('Standard Room (Room 105)'), findsOneWidget);
  });
}
