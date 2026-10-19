import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';
import '../../../../../helpers/helpers.dart';

DmConversation _conversation(String name) => DmConversation(
  channelId: 'channel-$name',
  username: name,
  participantId: 'user-$name',
  previewMessage: 'Hi from $name',
  unreadCount: 0,
);

class FakeDmListNotifier extends DmListNotifier {
  @override
  Future<List<DmConversation>> build() async => [
    _conversation('Alice Johnson'),
    _conversation('Bob Smith'),
    _conversation('alicia keys'),
  ];
}

class FakeWorkspaceNotifier extends WorkspaceNotifier {
  @override
  WorkspaceState build() => const WorkspaceState(
    selectedWorkspace: Workspace(id: 'org-1', name: 'Workspace A', avatar: ''),
  );
}

void main() {
  group('DmSidebarList search', () {
    Future<void> pumpList(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dmListProvider.overrideWith(FakeDmListNotifier.new),
            workspaceProvider.overrideWith(FakeWorkspaceNotifier.new),
          ],
          child: buildTestMaterialApp(const Scaffold(body: DmSidebarList())),
        ),
      );
      await tester.pumpAndSettle();
    }

    Finder searchField() =>
        find.widgetWithText(TextField, 'Find a Conversation');

    testWidgets('filters by name, ignoring case and surrounding spaces', (
      tester,
    ) async {
      await pumpList(tester);
      expect(find.text('Bob Smith'), findsOneWidget);

      await tester.enterText(searchField(), '  ALI ');
      await tester.pump();

      expect(find.text('Alice Johnson'), findsOneWidget);
      expect(find.text('alicia keys'), findsOneWidget);
      expect(find.text('Bob Smith'), findsNothing);
      expect(find.text('No conversations match'), findsNothing);
    });

    testWidgets('shows an empty message when nothing matches', (tester) async {
      await pumpList(tester);

      await tester.enterText(searchField(), 'zzz');
      await tester.pump();

      expect(find.text('No conversations match'), findsOneWidget);
      expect(find.byType(DmListTile), findsNothing);
    });

    testWidgets('clearing the text restores the full list', (tester) async {
      await pumpList(tester);

      await tester.enterText(searchField(), 'bob');
      await tester.pump();
      expect(find.byType(DmListTile), findsOneWidget);

      await tester.enterText(searchField(), '');
      await tester.pump();

      expect(find.byType(DmListTile), findsNWidgets(3));
      expect(find.text('No conversations match'), findsNothing);
    });
  });
}
