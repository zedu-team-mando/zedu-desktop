import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

class _FakeChatHistory extends ChangeNotifier implements ChatHistoryNotifier {
  _FakeChatHistory(this.messages);

  @override
  List<Map<String, dynamic>> messages;

  @override
  bool isLoading = false;

  @override
  bool hasMore = true;

  @override
  String get currentUserName => 'You';

  @override
  String? get currentUserAvatarUrl => null;

  @override
  bool isMyMessage(Map<String, dynamic> message) => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _message(String id, DateTime createdAt) => {
  'id': id,
  'content': 'message $id',
  'user_id': 'other-user',
  'created_at': createdAt.toIso8601String(),
};

void main() {
  testWidgets('shows a day divider above each day of DM messages', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    // Newest first, as the chat history keeps them.
    final history = _FakeChatHistory([
      _message('4', today.add(const Duration(minutes: 1))),
      _message('3', today),
      _message('2', yesterday.add(const Duration(hours: 12))),
      _message('1', DateTime(2020, 10, 12, 12)),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatHistoryProvider.overrideWith((ref, channelId) => history),
        ],
        child: buildTestMaterialApp(
          Scaffold(
            body: DmChatArea(
              conversation: DmConversation(
                channelId: 'channel-1',
                username: 'Ada Lovelace',
                participantId: 'other-user',
                previewMessage: '',
                unreadCount: 0,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(DmDayDivider), findsNWidgets(3));
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('12 Oct 2020'), findsOneWidget);

    double topOf(String text) =>
        tester.getTopLeft(find.text(text, findRichText: true)).dy;

    // On screen (oldest at the top) each divider sits above its day's messages.
    expect(topOf('12 Oct 2020'), lessThan(topOf('message 1')));
    expect(topOf('message 1'), lessThan(topOf('Yesterday')));
    expect(topOf('Yesterday'), lessThan(topOf('message 2')));
    expect(topOf('message 2'), lessThan(topOf('Today')));
    expect(topOf('Today'), lessThan(topOf('message 3')));
    expect(topOf('message 3'), lessThan(topOf('message 4')));
  });
}
