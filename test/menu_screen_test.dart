import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/menu/presentation/menu_screen.dart';

void main() {
  testWidgets('MenuScreen shows menu items and filters by category', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: MenuScreen()),
      ),
    );

    expect(find.text('Our menu'), findsOneWidget);
    expect(find.text('Ras Breakfast Plate'), findsOneWidget);
    expect(find.text('Doro Wot'), findsOneWidget);

    await tester.tap(find.text('Ethiopian'));
    await tester.pump();

    expect(find.text('Doro Wot'), findsOneWidget);
    expect(find.text('Ras Breakfast Plate'), findsNothing);
  });

  testWidgets('MenuScreen searches by dish name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: MenuScreen()),
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      'coffee',
    );
    await tester.pumpAndSettle();

    expect(find.text('Ethiopian Coffee Ceremony'), findsOneWidget);
  });
}
