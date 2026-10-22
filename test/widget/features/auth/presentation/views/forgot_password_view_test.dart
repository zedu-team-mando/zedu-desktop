import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';
import '../../../../../helpers/helpers.dart';

// Fake notifier that avoids GetIt/locator setup while remaining type-compatible
// with authNotifierProvider (NotifierProvider<AuthNotifier, AuthState>).
class FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);
}

Widget buildForgotPasswordViewUnderTest() {
  return ProviderScope(
    overrides: [
      authNotifierProvider.overrideWith(() => FakeAuthNotifier()),
    ],
    child: const MaterialApp(home: ForgotPasswordView()),
  );
}

void main() {
  group('ForgotPasswordView', () {
    testWidgets(
      'shows the redesigned heading, copy and reset button',
      (tester) async {
        await tester.pumpWidget(buildForgotPasswordViewUnderTest());
        await tester.pump();

        expect(find.text('Forgot your password?'), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
        expect(
          find.text(
            'Enter your email and we will send you instructions to reset your password.',
          ),
          findsOneWidget,
        );
        expect(find.text('Email address'), findsOneWidget);
        expect(find.text('Send reset instructions'), findsOneWidget);
        expect(find.text('Back to login'), findsOneWidget);

        // The old copy and actions are gone.
        expect(find.text('Forgot Password'), findsNothing);
        expect(find.text('Submit'), findsNothing);
      },
    );
  });
}
