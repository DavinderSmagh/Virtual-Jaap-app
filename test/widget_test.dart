import 'package:flutter_test/flutter_test.dart';
import 'package:website/main.dart'; // Depending on the package name

void main() {
  testWidgets('Jaap counter test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VirtualJaapApp());

    // Verify that our animation overlay is present
    expect(find.text('Tap anywhere to start'), findsOneWidget);

    // Tap anywhere (the overlay text works) to dismiss the overlay
    await tester.tap(find.text('Tap anywhere to start'));
    await tester.pumpAndSettle();

    // Verify that our counter is now visible and at 0.
    expect(find.text('0'), findsWidgets); // Bead box and counter

    // Tap the center of the screen 108 times to trigger the dialog
    for (int i = 0; i < 108; i++) {
        await tester.tapAt(const Offset(400, 300)); // Tap anywhere
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
