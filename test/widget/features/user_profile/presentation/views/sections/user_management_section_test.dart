import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';
import '../../../../../../helpers/helpers.dart';

Widget buildUnderTest(List<TeamMember> members) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: UserManagementSection(
            members: members,
            isSaving: false,
            onInvite: ({required email, required role}) async {},
            onUpdate: (_) {},
            onRemove: (_) {},
          ),
        ),
      ),
    ),
  );
}

List<TeamMember> createMembers(int count) {
  return List.generate(
    count,
    (i) => TeamMember(
      id: '$i',
      email: 'member$i@example.com',
      name: 'Member $i',
      role: i % 2 == 0 ? 'User' : 'Administrator',
      dateJoined: 'Oct 1, 2026',
      status: TeamMemberStatus.active,
    ),
  );
}

void main() {
  group('UserManagementSection empty state and pagination', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('shows a message and hides pagination with no members', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildUnderTest(const []));
      await tester.pump();

      expect(find.text('No members found.'), findsOneWidget);
      expect(find.text('Previous'), findsNothing);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets(
      'shows the member and hides pagination when there is only one page',
      (tester) async {
        tester.view.physicalSize = const Size(1400, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildUnderTest(const [
            TeamMember(
              id: '1',
              email: 'member@example.com',
              role: 'User',
              dateJoined: 'Oct 1, 2026',
              status: TeamMemberStatus.active,
            ),
          ]),
        );
        await tester.pump();

        expect(find.text('No members found.'), findsNothing);
        expect(find.text('member@example.com'), findsWidgets);
        expect(find.text('Previous'), findsNothing);
        expect(find.text('Next'), findsNothing);
      },
    );

    testWidgets('shows a search message when the filter matches nothing', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildUnderTest(const [
          TeamMember(
            id: '1',
            email: 'member@example.com',
            role: 'User',
            dateJoined: 'Oct 1, 2026',
            status: TeamMemberStatus.active,
          ),
        ]),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();

      expect(find.text('No members match your search.'), findsOneWidget);
      expect(find.text('Previous'), findsNothing);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('shows pagination and supports multi-page navigation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final members = createMembers(15);
      await tester.pumpWidget(buildUnderTest(members));
      await tester.pump();

      // Page 1
      expect(find.text('No members found.'), findsNothing);
      expect(find.text('member0@example.com'), findsWidgets);
      expect(find.text('member14@example.com'), findsNothing);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('user_management_page_number')))
            .data,
        '1',
      );

      final prevBtnPage1 = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Previous'),
      );
      final nextBtnPage1 = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Next'),
      );
      expect(prevBtnPage1.disabled, isTrue);
      expect(nextBtnPage1.disabled, isFalse);

      // Navigate to Page 2
      await tester.tap(find.widgetWithText(AppButton, 'Next'));
      await tester.pump();

      expect(find.text('member0@example.com'), findsNothing);
      expect(find.text('member14@example.com'), findsWidgets);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('user_management_page_number')))
            .data,
        '2',
      );

      final prevBtnPage2 = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Previous'),
      );
      final nextBtnPage2 = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Next'),
      );
      expect(prevBtnPage2.disabled, isFalse);
      expect(nextBtnPage2.disabled, isTrue);

      // Navigate back to Page 1
      await tester.tap(find.widgetWithText(AppButton, 'Previous'));
      await tester.pump();

      expect(find.text('member0@example.com'), findsWidgets);
      expect(find.text('member14@example.com'), findsNothing);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('user_management_page_number')))
            .data,
        '1',
      );
    });

    testWidgets('resets to page 1 and updates empty state when searching', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final members = createMembers(15);
      await tester.pumpWidget(buildUnderTest(members));
      await tester.pump();

      // Navigate to Page 2
      await tester.tap(find.widgetWithText(AppButton, 'Next'));
      await tester.pump();
      expect(
        tester
            .widget<Text>(find.byKey(const Key('user_management_page_number')))
            .data,
        '2',
      );

      // Search for specific member
      await tester.enterText(find.byType(TextField), 'member0');
      await tester.pump();

      // Only 1 result matching member0, so pagination hides
      expect(find.text('member0@example.com'), findsWidgets);
      expect(find.text('Previous'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Pagination restores on page 1
      expect(
        tester
            .widget<Text>(find.byKey(const Key('user_management_page_number')))
            .data,
        '1',
      );
      expect(find.text('member0@example.com'), findsWidgets);
    });

    testWidgets('updates empty state when changing role filter', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Members only have 'User' role
      final members = [
        const TeamMember(
          id: '1',
          email: 'user@example.com',
          role: 'User',
          dateJoined: 'Oct 1, 2026',
          status: TeamMemberStatus.active,
        ),
      ];

      await tester.pumpWidget(buildUnderTest(members));
      await tester.pump();

      // Select 'Manager' which has no matching members
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Manager').last);
      await tester.pumpAndSettle();

      expect(find.text('No members match your search.'), findsOneWidget);
      expect(find.text('Previous'), findsNothing);

      // Reset to 'All Roles'
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All Roles').last);
      await tester.pumpAndSettle();

      expect(find.text('user@example.com'), findsWidgets);
      expect(find.text('No members match your search.'), findsNothing);
    });
  });

  group('UserManagementSection tab alignment (#211)', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    Future<void> pumpSection(
      WidgetTester tester, {
      List<TeamMember> members = const [],
      int invitesCount = 0,
      Size size = const Size(1400, 1000),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: UserManagementSection(
                  members: members,
                  isSaving: false,
                  invitesCount: invitesCount,
                  onInvite: ({required email, required role}) async {},
                  onUpdate: (_) {},
                  onRemove: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    // Both labels and both badges must sit on the same baselines. The badge is
    // keyed by its tab so the geometry can be measured directly.
    Finder badgeFor(String label) => find.byKey(Key('tab_badge_$label'));
    Finder labelFor(String label) => find.byKey(Key('tab_label_$label'));

    testWidgets('keeps both tab labels on the same baseline', (tester) async {
      await pumpSection(tester, members: createMembers(3));

      final membersLabel = tester.getRect(labelFor('Members'));
      final invitesLabel = tester.getRect(labelFor('Invites'));

      expect(
        membersLabel.center.dy,
        moreOrLessEquals(invitesLabel.center.dy, epsilon: 0.5),
        reason: 'label baselines must be aligned across tabs',
      );
      expect(membersLabel.height, moreOrLessEquals(invitesLabel.height));
    });

    testWidgets('keeps both count badges vertically centred on the label', (
      tester,
    ) async {
      await pumpSection(tester, members: createMembers(3));

      final membersLabel = tester.getRect(labelFor('Members'));
      final invitesLabel = tester.getRect(labelFor('Invites'));
      final membersBadge = tester.getRect(badgeFor('Members'));
      final invitesBadge = tester.getRect(badgeFor('Invites'));

      expect(
        membersBadge.center.dy,
        moreOrLessEquals(membersLabel.center.dy, epsilon: 1.0),
        reason: 'the Members badge must be centred on its label',
      );
      expect(
        invitesBadge.center.dy,
        moreOrLessEquals(invitesLabel.center.dy, epsilon: 1.0),
        reason: 'the Invites badge must be centred on its label',
      );
    });

    testWidgets('uses identical label-to-badge spacing on both tabs', (
      tester,
    ) async {
      await pumpSection(tester, members: createMembers(3));

      final membersGap =
          tester.getRect(badgeFor('Members')).left -
          tester.getRect(labelFor('Members')).right;
      final invitesGap =
          tester.getRect(badgeFor('Invites')).left -
          tester.getRect(labelFor('Invites')).right;

      expect(membersGap, moreOrLessEquals(invitesGap, epsilon: 1.0));
      expect(membersGap, greaterThan(0));
    });

    testWidgets('renders both tabs at the same width and height', (
      tester,
    ) async {
      await pumpSection(tester, members: createMembers(3));

      final membersTab = tester.getRect(
        find.ancestor(of: badgeFor('Members'), matching: find.byType(InkWell)),
      );
      final invitesTab = tester.getRect(
        find.ancestor(of: badgeFor('Invites'), matching: find.byType(InkWell)),
      );

      expect(
        membersTab.width,
        moreOrLessEquals(invitesTab.width, epsilon: 0.5),
        reason: 'both tabs must render at the same width',
      );
      expect(
        membersTab.height,
        moreOrLessEquals(invitesTab.height, epsilon: 0.5),
        reason: 'both tabs must render at the same height',
      );
      expect(membersTab.top, moreOrLessEquals(invitesTab.top, epsilon: 0.5));
    });

    testWidgets('does not shift the tab strip when switching tabs', (
      tester,
    ) async {
      await pumpSection(tester, members: createMembers(3), invitesCount: 2);

      final before = tester.getRect(labelFor('Members'));

      await tester.tap(find.text('Invites'));
      await tester.pumpAndSettle();

      final after = tester.getRect(labelFor('Members'));
      expect(
        after.top,
        moreOrLessEquals(before.top, epsilon: 0.5),
        reason: 'tabs must not move when the active tab changes',
      );
      expect(after.left, moreOrLessEquals(before.left, epsilon: 0.5));
    });

    testWidgets('does not shift the tab strip when counts change', (
      tester,
    ) async {
      await pumpSection(tester, members: createMembers(3), invitesCount: 0);
      final smallCount = tester.getRect(
        find.ancestor(of: badgeFor('Invites'), matching: find.byType(InkWell)),
      );

      await pumpSection(tester, members: createMembers(150), invitesCount: 999);
      final largeCount = tester.getRect(
        find.ancestor(of: badgeFor('Invites'), matching: find.byType(InkWell)),
      );

      expect(
        largeCount.top,
        moreOrLessEquals(smallCount.top, epsilon: 0.5),
        reason: 'wider count badges must not move the tab strip',
      );
      expect(
        largeCount.height,
        moreOrLessEquals(smallCount.height, epsilon: 0.5),
      );
    });

    testWidgets('stays aligned across different window sizes', (tester) async {
      for (final size in const [Size(1000, 800), Size(1600, 1000)]) {
        await pumpSection(tester, members: createMembers(3), size: size);

        final membersLabel = tester.getRect(labelFor('Members'));
        final invitesLabel = tester.getRect(labelFor('Invites'));
        expect(
          membersLabel.center.dy,
          moreOrLessEquals(invitesLabel.center.dy, epsilon: 0.5),
          reason: 'labels must stay aligned at $size',
        );
        expect(
          tester.getRect(badgeFor('Members')).center.dy,
          moreOrLessEquals(membersLabel.center.dy, epsilon: 1.0),
          reason: 'the badge must stay centred at $size',
        );
      }
    });

    testWidgets('shows the members table on the Members tab and switches '
        'to the invites view on tap', (tester) async {
      await pumpSection(tester, members: createMembers(3), invitesCount: 2);

      expect(find.text('member0@example.com'), findsWidgets);
      expect(find.text('2 pending invites.'), findsNothing);

      await tester.tap(find.text('Invites'));
      await tester.pumpAndSettle();

      expect(find.text('member0@example.com'), findsNothing);
      expect(find.text('2 pending invites.'), findsOneWidget);

      await tester.tap(find.text('Members'));
      await tester.pumpAndSettle();

      expect(find.text('member0@example.com'), findsWidgets);
      expect(find.text('2 pending invites.'), findsNothing);
    });
  });
}
