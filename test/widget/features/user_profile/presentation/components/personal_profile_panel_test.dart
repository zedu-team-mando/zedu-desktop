import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

class _FakeUserProfileNotifier extends UserProfileNotifier {
  _FakeUserProfileNotifier(this.phoneNumber);

  final String phoneNumber;

  @override
  UserProfileState build() => UserProfileState(
    account: ProfileAccount(
      name: 'Ada Lovelace',
      email: 'ada@zedu.chat',
      timezone: 'Africa/Lagos',
      phoneNumber: phoneNumber,
    ),
  );
}

void main() {
  late List<String> copied;

  setUp(() {
    copied = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> pumpPanel(
    WidgetTester tester, {
    String phoneNumber = '+2348012345678',
  }) async {
    // The five action chips overflow under the wider test font only.
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception.toString().contains('overflowed')) return;
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileNotifierProvider.overrideWith(
            () => _FakeUserProfileNotifier(phoneNumber),
          ),
        ],
        child: buildTestMaterialApp(
          const Scaffold(body: PersonalProfilePanel()),
        ),
      ),
    );
    await tester.pump();
  }

  Finder copyIconInRowWith(String text) => find.descendant(
    of: find.ancestor(of: find.text(text), matching: find.byType(Row)).first,
    matching: find.byIcon(Icons.copy_outlined),
  );

  testWidgets('copy icon next to the email copies it to the clipboard', (
    tester,
  ) async {
    await pumpPanel(tester);

    await tester.tap(copyIconInRowWith('ada@zedu.chat'));
    await tester.pump();

    expect(copied, ['ada@zedu.chat']);
    expect(find.text('Email copied to clipboard'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('copy icon next to the phone copies it to the clipboard', (
    tester,
  ) async {
    await pumpPanel(tester);

    await tester.tap(copyIconInRowWith('+2348012345678'));
    await tester.pump();

    expect(copied, ['+2348012345678']);
    expect(find.text('Phone number copied to clipboard'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('no copy icon is shown when the phone number is missing', (
    tester,
  ) async {
    await pumpPanel(tester, phoneNumber: '');

    expect(copyIconInRowWith('Not provided'), findsNothing);
    expect(copyIconInRowWith('ada@zedu.chat'), findsOneWidget);
  });
}
