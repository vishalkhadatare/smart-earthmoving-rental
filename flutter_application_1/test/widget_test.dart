import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('HeavyEquip Pro App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HeavyEquipProApp());

    // Verify that onboarding screen is displayed.
    expect(find.text('Welcome to HeavyEquip Pro'), findsOneWidget);
  });
}
