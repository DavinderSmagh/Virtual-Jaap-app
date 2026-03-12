import 'package:flutter_test/flutter_test.dart';
import 'package:website/main.dart'; // Depending on the package name

void main() {
  testWidgets('Jaap counter test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VirtualJaapApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget); // The large TAP counter
    expect(find.text('TAP'), findsOneWidget);

    // Tap the central area 108 times to trigger the dialog
    for (int i = 0; i < 108; i++) {
        await tester.tap(find.text('TAP'));
        await tester.pump();
    }

    // Verify that our completion dialog appears.
    expect(find.text('Jaap Completed!'), findsOneWidget); 
    
    // Tap the OK button
    await tester.tap(find.text('OK'));
    await tester.pump();
    
    // Counter should be back to 0
    expect(find.text('0'), findsWidgets);
  });
}
