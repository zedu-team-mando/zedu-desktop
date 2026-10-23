import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zedu/core/core.dart';
import 'package:zedu/features/auth/data/auth_repository.dart';
import 'package:zedu/features/auth/presentation/providers/auth_notifier.dart';
import 'package:zedu/features/auth/data/models/models.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockAuthInterceptor extends Mock implements AuthInterceptor {}

void main() {
  group('AuthNotifier - login', () {
    late MockAuthRepository mockRepository;
    late MockSecureStorageService mockStorage;
    late MockAuthInterceptor mockInterceptor;

    setUp(() {
      mockRepository = MockAuthRepository();
      mockStorage = MockSecureStorageService();
      mockInterceptor = MockAuthInterceptor();

      when(() => mockStorage.getAccessToken()).thenAnswer((_) async => null);
      when(() => mockRepository.getCurrentUser()).thenAnswer((_) async => const Failure(message: 'No session'));
      when(() => mockInterceptor.onUnauthorized).thenAnswer((_) => null);
    });

    test('shows generic error message for failed login to prevent user enumeration', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
          secureStorageProvider.overrideWithValue(mockStorage),
          authInterceptorProvider.overrideWithValue(mockInterceptor),
        ],
      );

      // Mock failed login
      when(() => mockRepository.login(email: any(), password: any()))
          .thenAnswer((_) async => const Failure(message: 'User not found'));

      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.login(email: 'test@example.com', password: 'wrongpassword');

      final state = container.read(authNotifierProvider);
      expect(state.error, equals('Invalid email or password'));
      expect(state.error, isNot(equals('User not found')));
      expect(state.error, isNot(equals('Invalid password')));
    });

    test('shows generic error message for failed login with invalid password', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
          secureStorageProvider.overrideWithValue(mockStorage),
          authInterceptorProvider.overrideWithValue(mockInterceptor),
        ],
      );

      // Mock failed login
      when(() => mockRepository.login(email: any(), password: any()))
          .thenAnswer((_) async => const Failure(message: 'Invalid password'));

      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.login(email: 'test@example.com', password: 'wrongpassword');

      final state = container.read(authNotifierProvider);
      expect(state.error, equals('Invalid email or password'));
      expect(state.error, isNot(equals('Invalid password')));
    });

    test('successful login does not set error', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
          secureStorageProvider.overrideWithValue(mockStorage),
          authInterceptorProvider.overrideWithValue(mockInterceptor),
        ],
      );

      // Mock successful login
      final authSession = AuthSession(
        accessToken: 'test-token',
        user: User(
          id: 'user-1',
          firstName: 'Test',
          lastName: 'User',
          fullName: 'Test User',
          email: 'test@example.com',
          username: 'testuser',
          isVerified: true,
          isOnboarded: true,
          createdAt: DateTime.now(),
          currentOrg: 'org-1',
          currentOrganisationSlug: 'test-org',
          avatarUrl: '',
          defaultAvatarUrl: '',
        ),
      );

      when(() => mockRepository.login(email: any(), password: any()))
          .thenAnswer((_) async => Success(authSession));
      when(() => mockStorage.saveAccessToken(any())).thenAnswer((_) async {});

      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.login(email: 'test@example.com', password: 'correctpassword');

      final state = container.read(authNotifierProvider);
      expect(state.status, equals(AuthStatus.authenticated));
      expect(state.user?.email, equals('test@example.com'));
      expect(state.error, isNull);
    });
  });
}