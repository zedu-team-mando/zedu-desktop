import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/features/features.dart';

import '../../../../../../helpers/helpers.dart';

void main() {
  group('DmProfileCard', () {
    testWidgets('opens a profile dialog when tapping View Profile', (
      tester,
    ) async {
      final conversation = DmConversation(
        channelId: 'channel-1',
        username: 'Jane Doe',
        participantId: 'user-1',
        participantEmail: 'jane.doe@example.com',
        previewMessage: 'Hey there',
        unreadCount: 0,
      );

      await tester.pumpWidget(
        buildTestMaterialApp(
          Scaffold(
            body: DmProfileCard(conversation: conversation),
          ),
        ),
      );

      await tester.tap(find.text('View Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('@Jane_Doe'), findsOneWidget);
      expect(find.text('jane.doe@example.com'), findsOneWidget);
    });
  });
}
