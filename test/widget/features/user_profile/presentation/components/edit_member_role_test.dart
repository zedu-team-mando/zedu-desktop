import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

Future<void> openMemberEditor(
  WidgetTester tester,
  String role,
  ValueChanged<TeamMember> onUpdate,
) async {
  await tester.pumpWidget(
    buildTestMaterialApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showEditMemberDialog(
              context,
              TeamMember(
                id: 'test-member',
                email: 'test@example.com',
                role: role,
                dateJoined: 'Oct 1',
                status: TeamMemberStatus.active,
              ),
              onUpdate,
            ),
            child: const Text('Edit'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Edit'));
  await tester.pumpAndSettle();
}

void main() {
  for (final role in [
    'Project Lead',
    'Guess',
    '',
    'Administrator',
    'Manager',
    'User',
  ]) {
    testWidgets('opens and preserves existing role "$role" when saved', (
      tester,
    ) async {
      TeamMember? saved;
      await openMemberEditor(tester, role, (value) => saved = value);
      expect(tester.takeException(), isNull);
      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>),
      );
      expect(dropdown.initialValue, role);
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(saved?.role, role);
      expect(saved?.id, 'test-member');
      expect(saved?.email, 'test@example.com');
    });
  }

  testWidgets('explicitly selecting a supported replacement updates the role', (
    tester,
  ) async {
    TeamMember? saved;
    await openMemberEditor(tester, 'Project Lead', (value) => saved = value);
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manager').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(saved?.role, 'Manager');
  });

  testWidgets('cancel after selecting another role does not update member', (
    tester,
  ) async {
    TeamMember? saved;
    await openMemberEditor(tester, 'Project Lead', (value) => saved = value);
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('User').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(saved, isNull);
  });
}
