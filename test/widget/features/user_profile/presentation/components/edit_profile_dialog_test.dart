import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

ProfileAccount buildAccount({String country = 'Nigeria'}) {
  return ProfileAccount(
    name: 'Ada Okafor',
    email: 'ada@zedu.chat',
    timezone: 'Africa/Lagos',
    country: country,
  );
}

Widget buildDialogTrigger({
  required ProfileAccount account,
  required ValueChanged<ProfileAccount> onSave,
}) {
  return Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showEditProfileDialog(context, account, onSave),
          child: const Text('Edit profile'),
        ),
      ),
    ),
  );
}

/// The country field is the only widget with this key, so find it by key.
Finder countryFieldFinder() => find.byKey(const ValueKey('country_field'));

void main() {
  group('Edit profile country field', () {
    testWidgets(
      'submits a country typed without selecting a suggestion',
      (tester) async {
        ProfileAccount? saved;
        await tester.pumpWidget(
          ProviderScope(
            child: buildTestMaterialApp(
              buildDialogTrigger(
                account: buildAccount(country: 'Nigeria'),
                onSave: (account) => saved = account,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Edit profile'));
        await tester.pumpAndSettle();

        final countryField = countryFieldFinder();
        expect(countryField, findsOneWidget);

        // Type a new country without picking an autocomplete suggestion.
        await tester.enterText(countryField, 'Ghana');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save Changes'));
        await tester.pumpAndSettle();

        expect(saved, isNotNull);
        expect(saved?.country, 'Ghana');
      },
    );

    testWidgets(
      'rejects an empty country instead of submitting a stale value',
      (tester) async {
        ProfileAccount? saved;
        await tester.pumpWidget(
          ProviderScope(
            child: buildTestMaterialApp(
              buildDialogTrigger(
                account: buildAccount(country: 'Nigeria'),
                onSave: (account) => saved = account,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Edit profile'));
        await tester.pumpAndSettle();

        final countryField = countryFieldFinder();
        expect(countryField, findsOneWidget);

        // Clear the field.
        await tester.enterText(countryField, '');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save Changes'));
        await tester.pumpAndSettle();

        // The stale value must not be submitted and an inline error shows.
        expect(saved, isNull);
        expect(find.text('Select a country'), findsOneWidget);
      },
    );

    testWidgets(
      'submits a country chosen from an autocomplete suggestion',
      (tester) async {
        ProfileAccount? saved;
        await tester.pumpWidget(
          ProviderScope(
            child: buildTestMaterialApp(
              buildDialogTrigger(
                account: buildAccount(country: 'Nigeria'),
                onSave: (account) => saved = account,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Edit profile'));
        await tester.pumpAndSettle();

        final countryField = countryFieldFinder();
        expect(countryField, findsOneWidget);

        // Type part of a country to filter the suggestions, then pick one.
        await tester.enterText(countryField, 'Gha');
        await tester.pumpAndSettle();

        // Pick Ghana from the filtered suggestion list.
        await tester.tap(find.text('Ghana').first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save Changes'));
        await tester.pumpAndSettle();

        expect(saved, isNotNull);
        expect(saved?.country, 'Ghana');
      },
    );
  });
}
