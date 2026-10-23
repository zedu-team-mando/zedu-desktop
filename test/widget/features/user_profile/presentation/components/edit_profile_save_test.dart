import 'dart:async';

import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

const _account = ProfileAccount(
  name: 'Ada Lovelace',
  email: 'ada@example.test',
  timezone: '(UTC+01:00) West Central Africa',
);

Future<void> _openDialog(
  WidgetTester tester,
  Future<bool> Function(ProfileAccount) onSave,
) async {
  tester.view.physicalSize = const Size(1400, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    buildTestMaterialApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showEditProfileDialog(context, _account, onSave),
            child: const Text('Edit profile'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Edit profile'));
  await tester.pumpAndSettle();
}

Finder _field(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (widget) => widget is AppTextField && widget.label == label,
  ),
  matching: find.byType(TextFormField),
);

void main() {
  testWidgets('waits for success and prevents repeated submissions', (
    tester,
  ) async {
    final result = Completer<bool>();
    final saved = <ProfileAccount>[];
    await _openDialog(tester, (account) {
      saved.add(account);
      return result.future;
    });
    await tester.enterText(_field('Full Name'), 'Ada Updated');
    final saveButton = tester.widget<AppButton>(
      find.widgetWithText(AppButton, 'Save Changes'),
    );
    saveButton.onPressed!();
    saveButton.onPressed!();
    await tester.pump();

    expect(find.text('Edit your profile'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.testTextInput.hasAnyClients, isFalse);
    expect(saved, hasLength(1));
    expect(saved.single.name, 'Ada Updated');
    await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
    await tester.pump();
    expect(find.text('Edit your profile'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
          .onPressed,
      isNull,
    );

    result.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('Edit your profile'), findsNothing);
  });

  testWidgets('failure retains the draft and allows retry', (tester) async {
    final result = Completer<bool>();
    final saved = <ProfileAccount>[];
    await _openDialog(tester, (account) {
      saved.add(account);
      return saved.length == 1 ? result.future : Future.value(true);
    });
    await tester.enterText(_field('Full Name'), 'Grace Hopper');
    await tester.enterText(_field('Display Name'), 'Amazing Grace');
    await tester.tap(find.text('Save Changes'));
    await tester.pump();
    result.complete(false);
    await tester.pumpAndSettle();

    expect(find.text('Edit your profile'), findsOneWidget);
    expect(find.text('Grace Hopper'), findsOneWidget);
    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(
      find.text('Could not save your changes. Please try again.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(saved, hasLength(2));
    expect(saved.last.name, 'Grace Hopper');
    expect(saved.last.displayName, 'Amazing Grace');
    expect(find.text('Edit your profile'), findsNothing);
  });

  testWidgets('an unexpected save error retains the editor for retry', (
    tester,
  ) async {
    await _openDialog(tester, (_) async => throw StateError('Unavailable'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Edit your profile'), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(
      find.text('Could not save your changes. Please try again.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
