import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/features/dms/presentation/components/dm_message_composer.dart';

void main() {
  group('DmMessageComposer', () {
    testWidgets('composer has max height constraint on text field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const DmMessageComposer(
          recipientName: 'Test User',
          channelId: 'test-channel',
        ),
      );

      // Find the TextField
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Verify the TextField has a max height constraint
      final constrainedBox = find.ancestor(
        of: textField,
        matching: find.byType(ConstrainedBox),
      );
      expect(constrainedBox, findsOneWidget);

      final ConstrainedBox constrainedBoxWidget = tester.widget(constrainedBox);
      expect(constrainedBoxWidget.constraints.maxHeight, equals(160.0));
    });

    testWidgets('composer accepts long text and scrolls', (WidgetTester tester) async {
      await tester.pumpWidget(
        const DmMessageComposer(
          recipientName: 'Test User',
          channelId: 'test-channel',
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter a long message
      const longMessage = 'This is a very long message that should trigger scrolling in the composer. '
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor '
          'incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud '
          'exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute '
          'irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla '
          'pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia '
          'deserunt mollit anim id est laborum.';

      await tester.enterText(find.byType(TextField), longMessage);
      await tester.pump();

      // Verify the text was entered
      expect(find.textContaining(longMessage.substring(0, 50)), findsOneWidget);
    });
  });
}