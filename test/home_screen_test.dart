import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/home/presentation/controllers/rooms_controller.dart';
import 'package:mobile/features/home/presentation/home_screen.dart';

import 'rooms_controller_test.dart';

void main() {
  testWidgets('HomeScreen renders featured rooms from controller', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = RoomsController(repository: MockSuccessRoomRepository());
    await controller.loadRooms();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HomeScreen(controller: controller),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Find your signature stay.'), findsOneWidget);
    expect(find.text('Featured stays'), findsOneWidget);
    expect(find.text('Connected to Ras Hotel API'), findsOneWidget);
    expect(find.text('Check availability & rooms'), findsOneWidget);

    // In MockSuccessRoomRepository, room 201 is isFeatured: true
    expect(find.text('SUPERIOR'), findsOneWidget);
  });
}
