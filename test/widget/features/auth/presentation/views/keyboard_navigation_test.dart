import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class _TestAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {}
}

Future<void> _pumpAuthView(WidgetTester tester, Widget view) async {
  await tester.binding.setSurfaceSize(const Size(1440, 1024));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authNotifierProvider.overrideWith(_TestAuthNotifier.new)],
      child: MaterialApp(home: view),
    ),
  );
  await tester.pumpAndSettle();
}

FocusNode _fieldFocusNode(WidgetTester tester, int index) {
  final field = find.byType(TextFormField).at(index);
  final editable = find.descendant(
    of: field,
    matching: find.byType(EditableText),
  );
  return tester.widget<EditableText>(editable).focusNode;
}

Future<void> _pressShiftTab(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
}

void main() {
  group('auth form keyboard navigation', () {
    testWidgets('login Tab moves directly between fields in both directions', (
      tester,
    ) async {
      await _pumpAuthView(tester, const LoginView());
      final emailFocus = _fieldFocusNode(tester, 0);
      final passwordFocus = _fieldFocusNode(tester, 1);

      await tester.tap(find.byType(TextFormField).at(0));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(FocusManager.instance.primaryFocus, same(passwordFocus));

      await _pressShiftTab(tester);
      expect(FocusManager.instance.primaryFocus, same(emailFocus));
    });

    testWidgets(
      'registration Tab moves through username, email, and password directly',
      (tester) async {
        await _pumpAuthView(tester, const SignUpView());
        final usernameFocus = _fieldFocusNode(tester, 0);
        final emailFocus = _fieldFocusNode(tester, 1);
        final passwordFocus = _fieldFocusNode(tester, 2);

        await tester.tap(find.byType(TextFormField).at(0));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        expect(FocusManager.instance.primaryFocus, same(emailFocus));

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        expect(FocusManager.instance.primaryFocus, same(passwordFocus));

        await _pressShiftTab(tester);
        expect(FocusManager.instance.primaryFocus, same(emailFocus));
        await _pressShiftTab(tester);
        expect(FocusManager.instance.primaryFocus, same(usernameFocus));
      },
    );
  });
}
