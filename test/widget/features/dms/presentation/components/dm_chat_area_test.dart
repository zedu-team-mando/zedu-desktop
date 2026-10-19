import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

/// Stands in for [ChatHistoryNotifier] so the test doesn't hit the
/// repository or start polling.
class _FakeChatHistory extends Fake
    with ChangeNotifier
    implements ChatHistoryNotifier {
  @override
  List<Map<String, dynamic>> messages = [
    {
      'id': 'm2',
      'user_id': 'me',
      'content': 'sent **bold** text',
      'created_at': '2026-10-19T10:01:00Z',
    },
    {
      'id': 'm1',
      'user_id': 'user-2',
      'content': 'received *italic* ~~old~~ `code`',
      'created_at': '2026-10-19T10:00:00Z',
    },
  ];

  @override
  bool isLoading = false;

  @override
  bool hasMore = false;

  @override
  String get currentUserName => 'Me';

  @override
  String? get currentUserAvatarUrl => null;

  @override
  bool isMyMessage(Map<String, dynamic> message) => message['user_id'] == 'me';
}

final _conversation = DmConversation(
  channelId: 'channel-1',
  username: 'Ada',
  participantId: 'user-2',
  previewMessage: '',
  unreadCount: 0,
);

void main() {
  group('DmChatArea message text', () {
    Future<void> pumpChatArea(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chatHistoryProvider.overrideWith((ref, _) => _FakeChatHistory()),
          ],
          child: buildTestMaterialApp(
            Scaffold(body: DmChatArea(conversation: _conversation)),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    SelectableText bodyContaining(WidgetTester tester, String plainText) {
      return tester
          .widgetList<SelectableText>(find.byType(SelectableText))
          .singleWhere((w) => w.textSpan?.toPlainText() == plainText);
    }

    testWidgets('renders sent and received bodies as selectable text', (
      tester,
    ) async {
      await pumpChatArea(tester);

      // Throws unless exactly one SelectableText holds each message body.
      bodyContaining(tester, 'sent bold text');
      bodyContaining(tester, 'received italic old code');

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('keeps formatting spans and drops markdown symbols', (
      tester,
    ) async {
      await pumpChatArea(tester);

      final sentSpans = bodyContaining(
        tester,
        'sent bold text',
      ).textSpan!.children!.cast<TextSpan>();
      expect(
        sentSpans.firstWhere((s) => s.text == 'bold').style?.fontWeight,
        FontWeight.bold,
      );

      final receivedSpans = bodyContaining(
        tester,
        'received italic old code',
      ).textSpan!.children!.cast<TextSpan>();
      expect(
        receivedSpans.firstWhere((s) => s.text == 'italic').style?.fontStyle,
        FontStyle.italic,
      );
      expect(
        receivedSpans.firstWhere((s) => s.text == 'old').style?.decoration,
        TextDecoration.lineThrough,
      );
      expect(
        receivedSpans.firstWhere((s) => s.text == 'code').style?.fontFamily,
        'monospace',
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('select all and Ctrl+C copies plain text without markdown', (
      tester,
    ) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await pumpChatArea(tester);

      await tester.tap(find.text('received italic old code'));
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(copied, 'received italic old code');

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
