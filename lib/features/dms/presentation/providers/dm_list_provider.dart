import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

Color _iconBackground(WidgetTester tester, IconData icon) {
  final iconContainer = find
      .ancestor(
        of: find.byIcon(icon),
        matching: find.byWidgetPredicate((widget) {
          if (widget is! Container || widget.decoration is! BoxDecoration) {
            return false;
          }
          final decoration = widget.decoration! as BoxDecoration;
          return decoration.borderRadius == BorderRadius.circular(7);
        }),
      )
      .first;
  final decoration =
      tester.widget<Container>(iconContainer).decoration! as BoxDecoration;
  return decoration.color ?? Colors.transparent;
}

class _FakeDmListNotifier extends DmListNotifier {
  _FakeDmListNotifier(this._conversations);

  final List<DmConversation> _conversations;

  @override
  Future<List<DmConversation>> build() async => _conversations;
}

DmConversation _conversation(String id, int unread) {
  return DmConversation(
    channelId: 'channel-$id',
    username: 'User $id',
    participantId: 'participant-$id',
    previewMessage: 'Hello',
    unreadCount: unread,
  );
}

Future<void> _pumpRail(
  WidgetTester tester,
  List<DmConversation> conversations,
) async {
  await tester.pumpWidget(
    buildTestMaterialApp(
      ProviderScope(
        overrides: [
          dmListProvider.overrideWith(
            () => _FakeDmListNotifier(conversations),
          ),
        ],
        child: const Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: AppSidebarRail.width,
              height: 600,
              child: AppSidebarRail(activeType: HomeSidebarType.home),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets(
    'rail icons highlight on hover without clearing the active icon',
    (tester) async {
      await tester.pumpWidget(
        buildTestMaterialApp(
          ProviderScope(
            child: const Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: AppSidebarRail.width,
                  height: 600,
                  child: AppSidebarRail(activeType: HomeSidebarType.home),
                ),
              ),
            ),
          ),
        ),
      );

      final activeColor = AppPalette.light.primary.withValues(alpha: 0.95);
      const railIcons = [
        Icons.home_filled,
        Icons.chat_bubble_outline,
        Icons.people_outline,
        Icons.folder_open_outlined,
        Icons.phone_outlined,
        Icons.notifications_none_outlined,
        Icons.settings_outlined,
      ];

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(200, 500));
      addTearDown(gesture.removePointer);
      await tester.pump();

      for (final icon in railIcons) {
        await gesture.moveTo(tester.getCenter(find.byIcon(icon)));
        await tester.pump();

        expect(_iconBackground(tester, icon), activeColor);

        await gesture.moveTo(const Offset(200, 500));
        await tester.pump();

        expect(
          _iconBackground(tester, icon),
          icon == Icons.home_filled ? activeColor : Colors.transparent,
        );
        expect(_iconBackground(tester, Icons.home_filled), activeColor);
      }
    },
  );

  testWidgets('DMs icon shows the total unread count across conversations', (
    tester,
  ) async {
    await _pumpRail(tester, [_conversation('a', 3), _conversation('b', 4)]);

    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('DMs icon shows no badge when every conversation is read', (
    tester,
  ) async {
    await _pumpRail(tester, [_conversation('a', 0), _conversation('b', 0)]);

    final badge = find.byWidgetPredicate(
      (widget) =>
          widget is Text && RegExp(r'^\d+\+?$').hasMatch(widget.data ?? ''),
    );
    expect(badge, findsNothing);
  });

  testWidgets('DMs icon caps the unread badge at 99+', (tester) async {
    await _pumpRail(tester, [_conversation('a', 60), _conversation('b', 50)]);

    expect(find.text('99+'), findsOneWidget);
  });
}
