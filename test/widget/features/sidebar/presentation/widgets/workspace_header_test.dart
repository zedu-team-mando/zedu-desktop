import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';
import '../../../../../helpers/helpers.dart';

// Fake notifier that avoids GetIt/locator setup and records retries.
class FakeWorkspaceNotifier extends WorkspaceNotifier {
  FakeWorkspaceNotifier(this._initial);

  final WorkspaceState _initial;
  int fetchCalls = 0;

  @override
  WorkspaceState build() => _initial;

  @override
  Future<void> fetchWorkspaces() async {
    fetchCalls++;
  }
}

Widget buildHeaderUnderTest(FakeWorkspaceNotifier notifier) {
  return ProviderScope(
    overrides: [workspaceProvider.overrideWith(() => notifier)],
    child: buildTestMaterialApp(
      const Scaffold(body: WorkspaceSwitcherHeader()),
    ),
  );
}

// Tests render text in a very wide placeholder font, which overflows the
// menu footer. A smaller text scale keeps the layout checks meaningful.
Future<void> useTestWindow(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1440, 1024));
  tester.platformDispatcher.textScaleFactorTestValue = 0.5;
  addTearDown(() {
    tester.binding.setSurfaceSize(null);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

void main() {
  group('WorkspaceSwitcherHeader', () {
    const defaultWorkspace = Workspace(
      id: '1',
      name: 'commabuster',
      avatar: '',
      membersCount: 12,
    );

    testWidgets('shows the selected organisation name', (tester) async {
      const workspace = Workspace(
        id: 'org-1',
        name: 'Riverside Academy',
        avatar: '',
      );
      await tester.pumpWidget(
        buildHeaderUnderTest(
          FakeWorkspaceNotifier(
            const WorkspaceState(
              workspaces: [workspace],
              selectedWorkspace: workspace,
            ),
          ),
        ),
      );

      expect(find.text('Riverside Academy'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('shows the error and retries when loading failed', (
      tester,
    ) async {
      final notifier = FakeWorkspaceNotifier(
        const WorkspaceState(errorMessage: WorkspaceNotifier.loadErrorMessage),
      );
      await tester.pumpWidget(buildHeaderUnderTest(notifier));

      expect(find.text(WorkspaceNotifier.loadErrorMessage), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(notifier.fetchCalls, 1);
    });

    testWidgets('shows nothing while there is no organisation and no error', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildHeaderUnderTest(
          FakeWorkspaceNotifier(const WorkspaceState(isLoading: true)),
        ),
      );

      expect(find.text('Retry'), findsNothing);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('opens the menu under the name and flips the arrow', (
      tester,
    ) async {
      await useTestWindow(tester);

      await tester.pumpWidget(
        buildHeaderUnderTest(
          FakeWorkspaceNotifier(
            const WorkspaceState(
              workspaces: [defaultWorkspace],
              selectedWorkspace: defaultWorkspace,
            ),
          ),
        ),
      );
      await tester.pump();

      final headerRect = tester.getRect(find.byType(WorkspaceSwitcherHeader));
      final nameRect = tester.getRect(find.text('commabuster'));
      expect(
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
        0,
      );

      await tester.tap(find.text('commabuster'));
      await tester.pumpAndSettle();

      final menuRect = tester.getRect(find.byType(WorkspaceSwitcherList));
      expect(find.text('Switch Workspaces'), findsOneWidget);
      expect(menuRect.left, nameRect.left - 8);
      expect(menuRect.top, headerRect.bottom + 10);
      expect(
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
        0.5,
      );
    });

    testWidgets('closes when tapping outside and flips the arrow back', (
      tester,
    ) async {
      await useTestWindow(tester);

      await tester.pumpWidget(
        buildHeaderUnderTest(
          FakeWorkspaceNotifier(
            const WorkspaceState(
              workspaces: [defaultWorkspace],
              selectedWorkspace: defaultWorkspace,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('commabuster'));
      await tester.pumpAndSettle();
      expect(find.byType(WorkspaceSwitcherList), findsOneWidget);

      await tester.tapAt(const Offset(1300, 900));
      await tester.pumpAndSettle();

      expect(find.byType(WorkspaceSwitcherList), findsNothing);
      expect(
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
        0,
      );
    });

    testWidgets(
      'scrolls the whole menu in a short window instead of overflowing',
      (tester) async {
        await useTestWindow(tester);
        // A short window: MediaQuery reads the view size, which sets the cap.
        await tester.binding.setSurfaceSize(const Size(1440, 260));
        tester.view.physicalSize = const Size(1440, 260);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          buildHeaderUnderTest(
            FakeWorkspaceNotifier(
              const WorkspaceState(
                workspaces: [defaultWorkspace],
                selectedWorkspace: defaultWorkspace,
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('commabuster'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final footer = find.text('Add a new organization');
        await tester.scrollUntilVisible(
          footer,
          50,
          scrollable: find
              .descendant(
                of: find.byType(SingleChildScrollView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        // The footer is now inside the visible, height-capped menu.
        final menuRect = tester.getRect(find.byType(SingleChildScrollView));
        final footerRect = tester.getRect(footer);
        expect(footerRect.top, greaterThanOrEqualTo(menuRect.top));
        expect(footerRect.bottom, lessThanOrEqualTo(menuRect.bottom));
        expect(menuRect.bottom, lessThanOrEqualTo(260));
      },
    );
  });
}
