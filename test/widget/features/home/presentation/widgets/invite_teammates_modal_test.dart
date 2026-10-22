import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

class FakeUserProfileNotifier extends UserProfileNotifier {
  @override
  UserProfileState build() => const UserProfileState();

  @override
  Future<List<Map<String, dynamic>>> fetchRegisteredUsers() async => [];
}

Widget buildModalTrigger({String? channelName}) {
  return Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => InviteTeammatesModal(channelName: channelName),
          ),
          child: const Text('Open invite'),
        ),
      ),
    ),
  );
}

void main() {
  group('InviteTeammatesModal', () {
    testWidgets(
      'shows workspace-level copy when opened from the Workspace Switcher',
      (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 0.5;
        addTearDown(
          tester.platformDispatcher.clearTextScaleFactorTestValue,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userProfileNotifierProvider.overrideWith(
                FakeUserProfileNotifier.new,
              ),
            ],
            child: buildTestMaterialApp(buildModalTrigger()),
          ),
        );

        await tester.tap(find.text('Open invite'));
        await tester.pumpAndSettle();

        expect(find.text('Add people to workspace'), findsOneWidget);
        expect(
          find.text('Search for people in your organisation to invite them.'),
          findsOneWidget,
        );
        expect(find.text('#general'), findsNothing);
      },
    );

    testWidgets(
      'shows the channel name when opened from a specific channel',
      (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 0.5;
        addTearDown(
          tester.platformDispatcher.clearTextScaleFactorTestValue,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userProfileNotifierProvider.overrideWith(
                FakeUserProfileNotifier.new,
              ),
            ],
            child: buildTestMaterialApp(buildModalTrigger(channelName: 'design')),
          ),
        );

        await tester.tap(find.text('Open invite'));
        await tester.pumpAndSettle();

        expect(find.text('Add people to #design'), findsOneWidget);
        expect(
          find.text(
            'Search for people in your organisation and add them to #design.',
          ),
          findsOneWidget,
        );
        expect(find.text('Add people to workspace'), findsNothing);
      },
    );
  });
}
