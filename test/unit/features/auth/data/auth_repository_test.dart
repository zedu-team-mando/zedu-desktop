import '../../../../helpers/helpers.dart';
import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  group('AuthRepositoryImpl', () {
    late MockAuthRemoteDataSource mockDatasource;
    late AuthRepositoryImpl repository;

    setUp(() {
      mockDatasource = MockAuthRemoteDataSource();
      repository = AuthRepositoryImpl(remote: mockDatasource);
    });

    group('login', () {
      test('returns Success<AuthSession> when datasource succeeds', () async {
        final mockResponse = LoginResponseModel.fromJson(
          LoginResponseModel.mockLoginResponse,
        );

        when(
          () => mockDatasource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockResponse);

        final result = await repository.login(
          email: 'test@example.com',
          password: 'Password123',
        );

        expect(result, isA<Success<AuthSession>>());
        final session = (result as Success<AuthSession>).value;
        expect(session.accessToken, mockResponse.accessToken);
        expect(session.user.email, mockResponse.user.email);
      });

      test('returns Failure when datasource throws ApiFailure', () async {
        when(
          () => mockDatasource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(
          const ApiFailure(
            message: 'Invalid credentials',
            kind: ApiFailureKind.client,
          ),
        );

        final result = await repository.login(
          email: 'test@example.com',
          password: 'wrongpass',
        );

        expect(result, isA<Failure<AuthSession>>());
      });

      test(
        'uses a generic credentials message for 400 client login failures',
        () async {
          when(
            () => mockDatasource.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(
            const ApiFailure(
              message: 'Invalid email and password supplied',
              statusCode: 400,
              path: '/auth/login',
              kind: ApiFailureKind.client,
            ),
          );

          final result = await repository.login(
            email: 'test@example.com',
            password: 'wrongpass',
          );

          expect(result, isA<Failure<AuthSession>>());
          final failure = (result as Failure<AuthSession>).error;
          expect(
            failure.friendlyMessage,
            'Invalid email or password. Please check your credentials and try again.',
          );
          expect(failure.statusCode, 400);
          expect(failure.path, '/auth/login');
        },
      );

      test(
        'uses a generic credentials message for 401 unauthorized login',
        () async {
          when(
            () => mockDatasource.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(
            const ApiFailure(
              message: 'Invalid credentials',
              statusCode: 401,
              path: '/auth/login',
              kind: ApiFailureKind.unauthorized,
            ),
          );

          final result = await repository.login(
            email: 'test@example.com',
            password: 'wrongpass',
          );

          expect(result, isA<Failure<AuthSession>>());
          expect(
            (result as Failure<AuthSession>).error.friendlyMessage,
            'Invalid email or password. Please check your credentials and try again.',
          );
        },
      );

      test('preserves 429 rate limit login failures', () async {
        when(
          () => mockDatasource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(
          const ApiFailure(
            message: 'Too many requests',
            statusCode: 429,
            path: '/auth/login',
            kind: ApiFailureKind.client,
          ),
        );

        final result = await repository.login(
          email: 'test@example.com',
          password: 'Password123',
        );

        expect(result, isA<Failure<AuthSession>>());
        expect(
          (result as Failure<AuthSession>).error.friendlyMessage,
          'Too many requests',
        );
      });

      test('preserves network failures during login', () async {
        when(
          () => mockDatasource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(
          const ApiFailure(
            message: 'connection failed',
            kind: ApiFailureKind.network,
          ),
        );

        final result = await repository.login(
          email: 'test@example.com',
          password: 'Password123',
        );

        expect(result, isA<Failure<AuthSession>>());
        expect(
          (result as Failure<AuthSession>).error.friendlyMessage,
          'No internet connection. Check your network and try again.',
        );
      });

      test('returns Failure for unexpected errors', () async {
        when(
          () => mockDatasource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('unexpected error'));

        final result = await repository.login(
          email: 'test@example.com',
          password: 'password',
        );

        expect(result, isA<Failure<AuthSession>>());
      });
    });

    group('getCurrentUser', () {
      test('returns Success<User> when datasource succeeds', () async {
        final mockUser = LoginResponseModel.fromJson(
          LoginResponseModel.mockLoginResponse,
        ).user;

        when(() => mockDatasource.me()).thenAnswer((_) async => mockUser);

        final result = await repository.getCurrentUser();

        expect(result, isA<Success<User>>());
        final user = (result as Success<User>).value;
        expect(user.email, mockUser.email);
      });

      test('returns Failure when datasource throws ApiFailure', () async {
        when(() => mockDatasource.me()).thenThrow(
          const ApiFailure(
            message: 'Unauthorized',
            kind: ApiFailureKind.unauthorized,
          ),
        );

        final result = await repository.getCurrentUser();

        expect(result, isA<Failure<User>>());
      });

      test('returns Failure for unexpected errors', () async {
        when(() => mockDatasource.me()).thenThrow(Exception('unexpected'));

        final result = await repository.getCurrentUser();

        expect(result, isA<Failure<User>>());
      });
    });
  });
}

