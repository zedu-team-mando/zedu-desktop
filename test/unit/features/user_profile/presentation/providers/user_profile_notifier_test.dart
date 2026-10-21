import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class _FakeWorkspaceNotifier extends WorkspaceNotifier {
  @override
  WorkspaceState build() => const WorkspaceState(
    selectedWorkspace: Workspace(
      id: 'org-1',
      name: 'Test Workspace',
      avatar: '',
    ),
  );
}

void main() {
  group('UserProfileNotifier.inviteMember', () {
    late MockUserProfileRepository repository;

    setUp(() {
      registerFallbackValue('');
      repository = MockUserProfileRepository();

      locator.registerSingleton<AppConfig>(
        AppConfig(apiBaseUrl: 'https://api.example.com', usesMockData: false),
      );
      final mockStorage = MockSecureStorageService();
      when(() => mockStorage.readData(any())).thenAnswer((_) async => null);
      locator.registerSingleton<SecureStorageService>(mockStorage);

      // Stub every repository call made by the background load() microtask
      // scheduled in build() so it completes without errors.
      when(
        () => repository.getAccount(),
      ).thenAnswer((_) async => Success(ProfileAccount.empty()));
      when(
        () => repository.getNotificationPreferences(),
      ).thenAnswer((_) async => Success(NotificationPreferences.empty()));
      when(
        () => repository.getSecuritySessions(),
      ).thenAnswer((_) async => Success(<SecuritySession>[]));
      when(
        () => repository.getOrganization(),
      ).thenAnswer((_) async => Success(OrganizationProfile.empty()));
      when(
        () => repository.getTeamMembers(orgId: any(named: 'orgId')),
      ).thenAnswer((_) async => Success(<TeamMember>[]));
      when(
        () => repository.getRolesAndPermissions(),
      ).thenAnswer((_) async => Success(<RolePermission>[]));
      when(
        () => repository.getBillingInfo(),
      ).thenAnswer((_) async => Success(BillingInfo.empty()));
    });

    tearDown(() async {
      await locator.reset();
    });

    ProviderContainer makeContainer() {
      final container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repository),
          workspaceProvider.overrideWith(_FakeWorkspaceNotifier.new),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    /// Waits for the background [load] microtask (scheduled in [build])
    /// to finish before interacting with the notifier.
    Future<void> waitForLoad(ProviderContainer container) async {
      while (container.read(userProfileNotifierProvider).isLoading) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    test('stores the selected role name instead of the backend UUID '
        'returned by inviteMember', () async {
      final roleUuid = '019700d8-9085-7f7b-839a-fcbd08b9e26d';
      final invitedMember = TeamMember(
        id: 'new-member',
        email: 'invitee@example.com',
        role: roleUuid,
        dateJoined: '2026-01-01',
        status: TeamMemberStatus.pending,
      );
      when(
        () => repository.inviteMember(
          email: any(named: 'email'),
          role: any(named: 'role'),
          orgId: any(named: 'orgId'),
        ),
      ).thenAnswer((_) async => Success(invitedMember));

      final container = makeContainer();
      await waitForLoad(container);

      await container
          .read(userProfileNotifierProvider.notifier)
          .inviteMember(email: 'invitee@example.com', role: 'User');

      final state = container.read(userProfileNotifierProvider);
      expect(state.teamMembers, hasLength(1));
      expect(
        state.teamMembers.first.role,
        equals('User'),
        reason:
            'role should be the human-readable name passed to '
            'inviteMember, not the UUID returned by the backend',
      );
      expect(state.teamMembers.first.email, equals('invitee@example.com'));
      expect(state.teamMembers.first.id, equals('new-member'));
      expect(state.isSaving, isFalse);
      expect(state.successMessage, isNotNull);
    });

    test('does not add a member when the invitation fails', () async {
      when(
        () => repository.inviteMember(
          email: any(named: 'email'),
          role: any(named: 'role'),
          orgId: any(named: 'orgId'),
        ),
      ).thenAnswer(
        (_) async =>
            Failure<TeamMember>(ApiFailure(message: 'Unable to invite member')),
      );

      final container = makeContainer();
      await waitForLoad(container);

      await container
          .read(userProfileNotifierProvider.notifier)
          .inviteMember(email: 'invitee@example.com', role: 'User');

      final state = container.read(userProfileNotifierProvider);
      expect(state.teamMembers, isEmpty);
      expect(state.isSaving, isFalse);
      expect(state.error, isNotNull);
    });
  });
}
