import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('Ras Hotel opens its splash experience', (tester) async {
    await tester.pumpWidget(const RasHotelApp());

    expect(find.text('RAS HOTEL'), findsOneWidget);
    expect(find.text('A considered stay in Dire Dawa'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Your stay,\nthoughtfully made.'), findsOneWidget);
  });
}
