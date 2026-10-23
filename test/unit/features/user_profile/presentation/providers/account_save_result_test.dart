import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

class _Repository extends Mock implements UserProfileRepository {}

class _Notifier extends UserProfileNotifier {
  // Exercise the real save method without starting unrelated profile requests.
  @override
  Future<void> load() async {}
}

void main() {
  const account = ProfileAccount(
    name: 'Ada Lovelace',
    email: 'ada@example.test',
    timezone: 'Africa/Lagos',
  );
  late _Repository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _Repository();
    container = ProviderContainer(
      overrides: [
        userProfileRepositoryProvider.overrideWithValue(repository),
        userProfileNotifierProvider.overrideWith(_Notifier.new),
      ],
    );
    addTearDown(container.dispose);
  });

  test('reports success only after saving the account', () async {
    when(
      () => repository.updateAccount(account),
    ).thenAnswer((_) async => const Success(account));

    final saved = await container
        .read(userProfileNotifierProvider.notifier)
        .updateAccount(account);

    expect(saved, isTrue);
    expect(container.read(userProfileNotifierProvider).account, same(account));
    expect(container.read(userProfileNotifierProvider).isSaving, isFalse);
  });

  test('reports failure without replacing the saved account', () async {
    when(
      () => repository.updateAccount(account),
    ).thenAnswer((_) async => const Success(account));
    final notifier = container.read(userProfileNotifierProvider.notifier);
    await notifier.updateAccount(account);
    final edited = account.copyWith(name: 'Unsaved Name');
    when(() => repository.updateAccount(edited)).thenAnswer(
      (_) async => const Failure<ProfileAccount>(
        ApiFailure(message: 'Save failed', kind: ApiFailureKind.client),
      ),
    );

    expect(await notifier.updateAccount(edited), isFalse);
    final state = container.read(userProfileNotifierProvider);
    expect(state.account, same(account));
    expect(state.isSaving, isFalse);
    expect(state.error, isNotNull);
  });
}
