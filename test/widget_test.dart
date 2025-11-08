import 'package:flutter_test/flutter_test.dart';
import 'package:photo_quest/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PhotoQuestApp());

    // Verify that the app contains PhotoQuest text
    expect(find.text('PhotoQuest'), findsOneWidget);
  });
}
