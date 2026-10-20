import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mind_care/Features/Authentication/Data/Data_Sources/auth_local_data_source.dart';
import 'package:mind_care/Features/Authentication/Data/Data_Sources/auth_remote_data_source.dart';
import 'package:mind_care/Features/Authentication/Data/Data_Sources/auth_remote_data_source_impl.dart';
import 'package:mind_care/Features/Authentication/Data/Repositories/auth_repository_impl.dart';
import 'package:mind_care/Features/Authentication/Domain/Entities/auth_session.dart';

class MockAuthLocalDataSource extends Mock
    implements AuthLocalDataSource {}

class MockAuthRemoteDataSource extends Mock
    implements AuthRemoteDataSource {}

void main() {
  late MockAuthLocalDataSource localDataSource;
  late MockAuthRemoteDataSource remoteDataSource;
  late AuthRepositoryImpl repository;

  const session = AuthSession(
    userId: 'user-1',
    email: 'test@example.com',
    accessToken: 'access-token',
  );

  setUp(() {
    localDataSource = MockAuthLocalDataSource();
    remoteDataSource = MockAuthRemoteDataSource();

    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
  });

  group('logout', () {
    test('should clear local session after successful logout', () async {
      when(() => localDataSource.getSession())
          .thenAnswer((_) async => session);

      when(
            () => remoteDataSource.logout(
          accessToken: session.accessToken,
        ),
      ).thenAnswer((_) async {});

      when(() => localDataSource.clearSession())
          .thenAnswer((_) async {});

      await repository.logout();

      verify(
            () => remoteDataSource.logout(
          accessToken: session.accessToken,
        ),
      ).called(1);

      verify(() => localDataSource.clearSession()).called(1);
    });

    test(
      'should clear local session even if remote logout fails',
          () async {
        when(() => localDataSource.getSession())
            .thenAnswer((_) async => session);

        when(
              () => remoteDataSource.logout(
            accessToken: session.accessToken,
          ),
        ).thenThrow(
          const AuthApiException(
            'Logout failed',
            statusCode: 500,
          ),
        );

        when(() => localDataSource.clearSession())
            .thenAnswer((_) async {});

        await expectLater(
          repository.logout(),
          completes,
        );

        verify(() => localDataSource.clearSession()).called(1);
      },
    );

    test(
      'should attempt to clear local session when reading saved session fails',
          () async {
        when(() => localDataSource.getSession())
            .thenThrow(StateError('Read error'));

        when(() => localDataSource.clearSession())
            .thenAnswer((_) async {});

        await expectLater(
          repository.logout(),
          throwsA(isA<StateError>()),
        );

        verify(() => localDataSource.clearSession()).called(1);
      },
    );

    test(
      'should propagate error if clearing local session fails',
          () async {
        when(() => localDataSource.getSession())
            .thenAnswer((_) async => session);

        when(
              () => remoteDataSource.logout(
            accessToken: session.accessToken,
          ),
        ).thenAnswer((_) async {});

        when(() => localDataSource.clearSession())
            .thenThrow(StateError('Storage error'));

        await expectLater(
          repository.logout(),
          throwsA(isA<StateError>()),
        );
      },
    );

    test(
      'should clear local session without calling remote logout '
          'when no saved session exists',
          () async {
        when(() => localDataSource.getSession())
            .thenAnswer((_) async => null);

        when(() => localDataSource.clearSession())
            .thenAnswer((_) async {});

        await repository.logout();

        verifyNever(
              () => remoteDataSource.logout(
            accessToken: any(named: 'accessToken'),
          ),
        );

        verify(() => localDataSource.clearSession()).called(1);
      },
    );
  });

  group('getCurrentSession', () {
    test(
      'should clear local session and return null when server '
          'rejects the session with 401',
          () async {
        when(() => localDataSource.getSession())
            .thenAnswer((_) async => session);

        when(
              () => remoteDataSource.getCurrentSession(
            accessToken: session.accessToken,
          ),
        ).thenThrow(
          const AuthApiException(
            'Unauthorized',
            statusCode: 401,
          ),
        );

        when(() => localDataSource.clearSession())
            .thenAnswer((_) async {});

        final result = await repository.getCurrentSession();

        expect(result, isNull);

        verify(() => localDataSource.clearSession()).called(1);
      },
    );

    test(
      'should clear local session and return null when server '
          'rejects the session with 403',
          () async {
        when(() => localDataSource.getSession())
            .thenAnswer((_) async => session);

        when(
              () => remoteDataSource.getCurrentSession(
            accessToken: session.accessToken,
          ),
        ).thenThrow(
          const AuthApiException(
            'Forbidden',
            statusCode: 403,
          ),
        );

        when(() => localDataSource.clearSession())
            .thenAnswer((_) async {});

        final result = await repository.getCurrentSession();

        expect(result, isNull);

        verify(() => localDataSource.clearSession()).called(1);
      },
    );

    test(
      'should return null without calling remote API when no '
          'local session exists',
          () async {
        when(() => localDataSource.getSession())
            .thenAnswer((_) async => null);

        final result = await repository.getCurrentSession();

        expect(result, isNull);

        verifyNever(
              () => remoteDataSource.getCurrentSession(
            accessToken: any(named: 'accessToken'),
          ),
        );

        verifyNever(() => localDataSource.clearSession());
      },
    );
  });
}
